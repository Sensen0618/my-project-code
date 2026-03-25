% Sample program
% The specific values can be adjusted according to the actual results

clc;
clear;
% [x y width height]
figure('visible','on','position',[350,200,800,600]);
subplot(2,1,1);
% data
Y = [26603,19153,14362.7,13800,13652.9];
color = [0 0 0;0 0 1;1 1 0;1 0 1;1 0 0];  
hold on
               
for i = 1:5
    b = bar(i,Y(i),0.6,'stacked');  
    set(b(1),'facecolor',color(i,:))
end
box on
grid on
axis([0.5 5.5 0 28000])
set(gca,'ytick',0:7000:280000)

set(gca,'XTick',[1 2 3 4 5]);
set(gca,'FontSize',12,'Fontname', 'Times New Roman');
set(gca,'XTickLabel',{'URA','OPA','JPABS','JAPA','ABPC'},'FontSize',12);
xlabel({'K=3','(c)'})
ylabel('Total transmit power(W)');

subplot(2,1,2);
Y = [49664,31594,29166.3845,28945.2];
color = [0 0 0;0 0 1;1 0 1;1 0 0];  
hold on              
for i = 1:4
    b = bar(i,Y(i),0.6,'stacked');  
    set(b(1),'facecolor',color(i,:))
end
box on
grid on
axis([0.5 4.5 0 60000])
set(gca,'ytick',0:15000:60000)
set(gca,'XTick',[1 2 3 4]);
set(gca,'FontSize',12,'Fontname', 'Times New Roman');
set(gca,'XTickLabel',{'URA','OPA','JAPA','ABPC'},'FontSize',12);
xlabel({'K=4','(d)'})
ylabel('Total transmit power(W)');