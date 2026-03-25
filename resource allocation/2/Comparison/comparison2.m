% Sample program
% The specific values can be adjusted according to the actual results

clc;
clear;
% [x y width height]
figure('visible','on','position',[350,200,800,600]);
subplot(2,1,1);
% data
Y = [105985,52848.6025,44481.7894,37486,37214];
color = [0 0 0;0 0 1;1 1 0;1 0 1;1 0 0];  
hold on
               
for i = 1:5
    b = bar(i,Y(i),0.6,'stacked');  
    set(b(1),'facecolor',color(i,:))
end
box on
grid on
axis([0.5 5.5 0 120000])
set(gca,'ytick',0:30000:120000)
set(gca,'XTick',[1 2 3 4 5]);
set(gca,'FontSize',12,'Fontname', 'Times New Roman');
set(gca,'XTickLabel',{'URA','OPA','JPABS','JAPA','ABPC'},'FontSize',12);
xlabel({'K=3','(c)'})
ylabel('Total transmit power(W)');
subplot(2,1,2);
Y = [186955,97125.2582,80756.4179,79048];
color = [0 0 0;0 0 1;1 0 1;1 0 0];  
hold on
             
for i = 1:4
    b = bar(i,Y(i),0.6,'stacked');  
    set(b(1),'facecolor',color(i,:))
end
box on
grid on
axis([0.5 4.5 0 200000])
set(gca,'ytick',0:40000:200000)
set(gca,'XTick',[1 2 3 4]);
set(gca,'FontSize',12,'Fontname', 'Times New Roman');
set(gca,'XTickLabel',{'URA','OPA','JAPA','ABPC'},'FontSize',12);
xlabel({'K=4','(d)'})
ylabel('Total transmit power(W)');