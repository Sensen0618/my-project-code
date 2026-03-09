clear;
clc;
figure('position',[150,100,800,600])%确定图片的位置和大小，[x y width height]
%准备数据

Y=[365.6,571.3,192.2,1851;
   4591.3,1541.5,4196,3650.3;
    9447.8,6503.8,8369.5,12892;
    27410,8731.7,18579,24328];
X=1:4;
 %画出4组柱状图，宽度1
h=bar(X,Y,0.8);  
grid on
 %修改横坐标名称、字体
set(gca,'XTickLabel',{'K=1','K=2','K=3','K=4'},'FontSize',15,'FontName','Times New Roman');
% 设置柱子颜色,颜色为RGB三原色，每个值在0~1之间即可
set(h(1),'FaceColor',[255,0,0]/255)     
set(h(2),'FaceColor',[0,0,255]/255)    
set(h(3),'FaceColor',[255,255,0]/255)    
set(h(4),'FaceColor',[0,255,0]/255)    
ylim([0,30000]);      %y轴刻度
%修改x,y轴标签
ylabel('\fontname{宋体}\fontsize{15}发射功率 (W)');
xlabel('\fontname{宋体}\fontsize{15}K值'); 
%修改图例
legend({'\fontname{宋体}雷达 1','\fontname{宋体}雷达 2','\fontname{宋体}雷达 3','\fontname{宋体}雷达 4'},'FontSize',15);
 %print('-depsc','fig15.eps');
 % saveas(gcf,['42gonglv','.emf']);