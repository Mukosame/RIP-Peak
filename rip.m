% -*- coding: UTF-8 -*-
% File: rip.m
% Author: Mukosame  <mukosame@gmail.com>
% https://github.com/Mukosame/RIP-Peak

%[ndata,filename,alldata]=xlsread('ripname.xlsx');

cell = 'B'; %Please choose the cell type, very important!
prefix = 10; %THIS IS FOR REMOVING THE ULTRA POINTS IN THE CENTER
suffix = 2; %1/suffix the height's width
Tag = 'I';% I for Inlet, O for Outlet

direction = '.\';
alldata = dir(fullfile(direction, '*.RIP'));
for i = 1:length(alldata)
    filename{i} = alldata(i).name;
end
z_mm = zeros(length(alldata),1);
cd = zeros(length(alldata),1);
dn = zeros(length(alldata),1);
na = zeros(length(alldata),1);
od = zeros(length(alldata),1);
otc = zeros(length(alldata),1);

if cell == 'B'
    ledge = 1000; redge = 2500;
    edgel = 5000; edger = 6500;
end

if cell == 'C'
    ledge = 1000; redge = 2500;
    edgel = 5000; edger = 6500;
end

if 1
    for n=1:length(filename)
        figure(n)
        temp = importdata(char(filename(n)),'	',2);
        info = temp.textdata(1,1);
        spinfo = regexp(info, '	', 'split');
        id = upper(spinfo{1,1}{1,2});
        time = spinfo{1,1}{1,5};
        %z_mm(n,1) = {spinfo{1,1}{1,7}};%OK...
        z_mm = spinfo{1,1}{1,7};
        %deg(n,1) = spinfo{1,1}{1,9};
        if Tag == 'O'
            position = strcat(id,z_mm, 'mm from inlet');
        end
        if Tag == 'I'
            position = strcat(id ,string(z_mm) , 'mm from outlet');
        end
        %plot??
        set(gca, 'fontsize', 22)
        linespace = temp.data(2,1)-temp.data(1,1); 
        ymax = max(temp.data(:,2));
        ymin = min (temp.data(3000:4150,2));
        plot (temp.data(:,1), temp.data(:,2), 'LineWidth', 1, 'Color', 'blue')
        len = round(length(temp.data(:,2))/2);
        %%%%%%%%%%%%%%%%%%%%%
        %?FIND CORE DIAMETER
        %%%%%%%%%%%%%%%%%%%%%
        if 1
        hh = mean(temp.data((len-100):len,2))/2;
        sn = find(temp.data(len-300:len+300,2)>=hh);
        l=length(sn);
        cleftx = temp.data(len-300+sn(1),1);
        crightx = temp.data(len-300+sn(l),1);
        cd(n) = crightx - cleftx;%core diameter
        cored = strcat('2a=', num2str(cd(n),3), 'mm');
        hold on
        %plot (cleftx:0.1:crightx,hh,'--r');
        plot ([cleftx, crightx], [hh, hh],'--r');
        text(crightx+0.1,hh,cored,'FontSize',16)
        hold off;
        end
        %%%%%%%%%%%%%%%%%%%%
        %calculate \Delta n
        %%%%%%%%%%%%%%%%%%%%
        if 1
            uppr = mean(temp.data((len-250+sn(1)):len-prefix,2));
            lower = mean(temp.data(len-1000:len-300,2));
            uleftx = temp.data(len-1100,1);
            urightx = temp.data(len-100,1);
            dn(n) = uppr - lower;
            na(n) = sqrt((dn(n)+1.45702)^2-1.45702^2);
            na(n) = roundn(na(n),-4);
            dn(n) = roundn(dn(n), -4);
            dntext = num2str(dn(n));
            natext = num2str(na(n));
            hold on
            plot([uleftx,urightx],[uppr,uppr],'--r');
            %plot(uleftx:0.5:urightx, lower,'--r');
            plot([uleftx,urightx],[lower,lower],'--r');
            plot([temp.data(len-1000,1),temp.data(len-1000,1)],[lower,uppr],'--r');
            dntext = strcat('\Delta n=',dntext);
            natext = strcat('N.A.=',natext);
            text(temp.data(len-1000,1),uppr-1e-4,dntext,'FontSize',16)
            text(temp.data(len-1000,1),uppr-2.5e-4,natext,'FontSize',16)
            hold off
        end
        if 1
        %%%%%%%%%%%%%%%%%%%%
        %OUTER DIAMETER
        %%%%%%%%%%%%%%%%%%%%
        edge_h = max(temp.data(ledge:redge,2));
        leftx = find(temp.data(ledge:redge,2)>=edge_h/1.5);
        leftx = leftx(length(leftx))+ledge;
        rightx = find(temp.data(edgel:edger,2)>=edge_h/1.5);
        rightx = rightx(1)+edgel;
        oleftx = temp.data(leftx,1);
        orightx = temp.data(rightx,1);
        od(n) = orightx - oleftx;%outer diameter
        otc(n) = od(n)/cd(n);
        outd = strcat('OD=', num2str(od(n),4), 'mm');
        ymax = max(temp.data(len-300:len,2));
        hold on
        %plot (oleftx:0.1:orightx,hh,'--r');
        plot([oleftx,orightx],[min(ymax*1.2,edge_h),min(ymax*1.2,edge_h)],'--r');
        text(-1.2,min(ymax*1.2,edge_h)+1e-4,outd,'FontSize',16)
        hold off
        end
        %save??
        xmin = oleftx-0.1;%need revise
        xmax = orightx+0.1;%need revise
        axis([xmin xmax ymin ymax*1.5]);
        title(position,'fontsize', 22);
        xlabel('Radius [mm]', 'fontsize', 26);
        ylabel('\Delta n', 'fontsize', 26);
        picname = strcat(position, '.png')
        figname = strcat(position, '.fig');
        saveas(gcf,picname,'png')
        saveas(gcf,figname,'fig')
        
    %figure(101)
    %hold on 
    %plot (temp.data(:,1), temp.data(:,2), 'LineWidth', 1)
    %title(id,'fontsize', 22);
    %xlabel('Radius [mm]', 'fontsize', 26);
    %ylabel('\Delta n', 'fontsize', 26);
    %hold off
    end
    %combine the vectors
    final = zeros(n,6);
    final(:,1) = cd;
    final(:,2) = od;
    final(:,3) = otc;
    final(:,4) = dn + 1.45702;
    final(:,5) = dn;
    final(:,6) = na;
end