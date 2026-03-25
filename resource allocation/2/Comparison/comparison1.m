% Sample program
% The specific values can be adjusted according to the actual results

clc;
clear;
% [x y width height]
figure('visible','on','position',[350,200,800,600]);
subplot(2,1,1);
% data
Y = [24927,9283.5339,7364.2304,2980.1686,2980.1686];
color = [0 0 0;0 0 1;1 1 0;1 0 1;1 0 0];  
hold on
              
for i = 1:5
    b = bar(i,Y(i),0.6,'stacked');  
    set(b(1),'facecolor',color(i,:))
end
box on
grid on
axis([0.5 5.5 0 30000])
set(gca,'ytick',0:5000:30000)
set(gca,'XTick',[1 2 3 4 5]);
set(gca,'FontSize',12,'Fontname', 'Times New Roman');
set(gca,'XTickLabel',{'URA','OPA','JPABS','JAPA','ABPC'},'FontSize',12);
xlabel({'K=1','(a)'})
ylabel('Total transmit power(W)');

subplot(2,1,2);
Y = [65926,27479.0302,21180.8687,14048.0972,13979];
color = [0 0 0;0 0 1;1 1 0;1 0 1;1 0 0];  
hold on
             
for i = 1:5
    b = bar(i,Y(i),0.6,'stacked');  
    set(b(1),'facecolor',color(i,:))
end
box on
grid on
axis([0.5 5.5 0 72000])
set(gca,'ytick',0:12000:72000)
set(gca,'XTick',[1 2 3 4 5]);
set(gca,'FontSize',12,'Fontname', 'Times New Roman');
set(gca,'XTickLabel',{'URA','OPA','JPABS','JAPA','ABPC'},'FontSize',12);
xlabel({'K=2','(b)'})
ylabel('Total transmit power(W)');
