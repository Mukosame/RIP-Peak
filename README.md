RIP-Peak: 自动处理RIP文件
=======================


Author: [Mukosame](https://github.com/mukosame)

E-mail: <mukosame@gmail.com>

Update: 02/01 2016


介绍
----
RIP-Peak采用matlab编写，用于处理PK2600/PK2610测量所得的`*.RIP`文件。

使用
----
将`rip.m`复制到待处理的`*.RIP`文件目录下，并将待处理的文件名添加至`ripname.xlsx`中，运行该脚本即可。

输出文件
----
* `preform_id + position[mm].png`
* `preform_id + position[mm].fig`

输出数据
----
* z_mm : 所有计算过的点的位置

* cd ： 各点处芯径

* dn ： 各点处折射率差

* na ： 各点处数值孔径
 
* od ： 各点处外径

* otc ： 各点处包芯比 