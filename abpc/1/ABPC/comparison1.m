clc;
clear;
%确定图片的位置和大小，[x y width height]
figure('visible','on','position',[350,200,800,600]);
subplot(2,1,1);
%准备数据
Y = [7527,3744,2808,936,936];
color = [0 0 0;0 0 1;1 1 0;1 0 1;1 0 0];  
hold on
% 添加5个柱子，facecolor用来修改颜色               
for i = 1:5
    b = bar(i,Y(i),0.6,'stacked');  
    set(b(1),'facecolor',color(i,:))
end
box on
grid on
axis([0.5 5.5 0 8000])
set(gca,'ytick',0:2000:10000)
%x轴每个柱子的横坐标
set(gca,'XTick',[1 2 3 4 5]);
set(gca,'FontSize',12,'Fontname', 'Times New Roman');
set(gca,'XTickLabel',{'平均分配','功率优化','功率波束优化','孔径功率优化','本章所提策略'},'FontSize',12,'FontName','宋体'); %修改横坐标名称、字体
xlabel({'\fontname{Times New Roman}\fontsize{12}K=1','(a)'})
ylabel('\fontname{宋体}\fontsize{12}总发射功率(W)');
%set(gca,'FontName','Times New Roman');
%设置纵坐标的数值范围
%set(gca,'YLim',[0 1000000]);
%修改大标签

subplot(2,1,2);
Y = [15993,8635.4575,6478.1362,4317,4247.1];
color = [0 0 0;0 0 1;1 1 0;1 0 1;1 0 0];  
hold on
% 添加5个柱子，facecolor用来修改颜色               
for i = 1:5
    b = bar(i,Y(i),0.6,'stacked');  
    set(b(1),'facecolor',color(i,:))
end
box on
grid on
axis([0.5 5.5 0 18000])
set(gca,'ytick',0:6000:18000)
%x轴每个柱子的横坐标
set(gca,'XTick',[1 2 3 4 5]);
set(gca,'FontSize',12,'Fontname', 'Times New Roman');
set(gca,'XTickLabel',{'平均分配','功率优化','功率波束优化','孔径功率优化','本章所提策略'},'FontSize',12,'FontName','宋体'); %修改横坐标名称、字体
xlabel({'\fontname{Times New Roman}\fontsize{12}K=2','(b)'})
ylabel('\fontname{宋体}\fontsize{12}总发射功率(W)');
%set(gca,'FontName','Times New Roman');
%设置纵坐标的数值范围
%set(gca,'YLim',[0 1000000]);
% saveas(gcf,['4.K=1、2','.emf']);
%set(gcf,'paperpositionmode','auto');
%print('-depsc','fig9.1.eps');