%----Encoding:UTF-8-----------%
%----Created by: XXY----------%
%----Usage: calculate .RIP----%
clear all;
clc;

FullTitle = '';
cell = 'B'; %Please choose the cell type, very important!
prefix = 10; %THIS IS FOR REMOVING THE ULTRA POINTS IN THE CENTER
suffix = 2; %1/suffix the height's width
Tag = 'O';% I for Inlet, O for Outlet
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
        %z_mm(n,1) = {spinfo{1,1}{1,7}};%Ich weise nicht! Was die char* sind!
        z_mm = spinfo{1,1}{1,7};
        %deg(n,1) = spinfo{1,1}{1,9};
        if Tag == 'O'
            position = strcat(id,z_mm, 'mm from inlet');
            overlaytag = 'Position(mm) from inlet';
        end
        if Tag == 'I'
            position = strcat(id ,string(z_mm) , 'mm from outlet');
            overlaytag = 'Position(mm) from outlet';
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
        hh = mean(temp.data((len-100):len,2))/suffix;
        sn = find(temp.data(len-300:len+300,2)>=hh);
        l=length(sn);
        cleftx = temp.data(len-300+sn(1),1);
        crightx = temp.data(len-300+sn(l),1);
        cd(n) = crightx - cleftx;%core diameter
        cored = strcat('2a=', num2str(cd(n),3), 'mm');
        hold on
        plot ([cleftx, crightx], [hh, hh],'--r');
        text(crightx+0.1,hh,cored,'FontSize',14)
		text(cleftx,hh,'\leftarrow','FontSize',6,'Color','r');
        text(crightx,hh,'\rightarrow','FontSize',6,'Color','r','HorizontalAlignment','right');
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
            natemp = roundn(na(n),-4);
            dntemp = roundn(dn(n), -4);
            dntext = num2str(dntemp);
            natext = num2str(natemp);
            hold on
            plot([uleftx,urightx],[uppr,uppr],'--r');
            plot([uleftx,urightx],[lower,lower],'--r');
            plot([temp.data(len-1000,1),temp.data(len-1000,1)],[lower,uppr],'--r');
			text(temp.data(len-1000,1),uppr,'\leftarrow','FontSize',5,'Color','r','Rotation',270,'VerticalAlignment','baseline');
            text(temp.data(len-1000,1),lower,'\leftarrow','FontSize',5,'Color','r','Rotation',90,'VerticalAlignment','baseline'); 
            dntext = strcat('\Delta n=',dntext);
            natext = strcat('N.A.=',natext);
            text(temp.data(len-1000,1),uppr-1e-4,dntext,'FontSize',14)
            text(temp.data(len-1000,1),uppr-2.5e-4,natext,'FontSize',14)
            hold off
        end
        
        %%%%%%%%%%%%%%%%%%%%
        %OUTER DIAMETER
        %%%%%%%%%%%%%%%%%%%%
		if 1
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
		temph = min(ymax*1.2,edge_h);
        plot([oleftx,orightx],[temph,temph],'--r');
        text(-1.2,temph+1e-4,outd,'FontSize',14)
%        text(oleftx,temph,'\leftarrow','FontSize',5,'Color','r');
%        text(orightx,temph,'\rightarrow','FontSize',5,'Color','r','HorizontalAlignment','right');
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
    
%--Plot overlay---%
if 1
    figure(101)
    set(gca, 'fontsize', 22)
    hold all
    plot (temp.data(:,1), temp.data(:,2), 'LineWidth', 1)
    axis([xmin xmax ymin ymax*1.5]);
    if strcmp(FullTitle,'')
        OverlayTitle = id;
    else
        OverlayTitle = FullTitle;
    end
    title(OverlayTitle,'fontsize', 22);
    xlabel('Radius [mm]', 'fontsize', 26);
    ylabel('\Delta n', 'fontsize', 26);
    z_legend{n} = z_mm;      
     
end 
end  %end for read
    
    figure(101)
    text(xmax-13,ymax*1.42,overlaytag,'fontsize', 22);
    hleg1 = legend(z_legend);
    set(hleg1, 'Box', 'off')
    overpng = strcat(OverlayTitle, '_all.png');
    overfig = strcat(OverlayTitle, '_all.fig');
    saveas(gcf,overpng,'png')
    saveas(gcf,overfig,'fig')  

    %combine the vectors
    final = zeros(n,6);
    final(:,1) = cd;
    final(:,2) = od;
    final(:,3) = otc;
    final(:,4) = dn + 1.45702;
    final(:,5) = dn;
    final(:,6) = na;
end

save result.mat