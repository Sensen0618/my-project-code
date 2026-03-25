% Sample program
% The specific values can be adjusted according to the actual results

clc; clear;
figure('position',[150,100,800,600]) % [x y width height]

% data
Y=[234.0076,234.0076,234.0076,234.0076;
    1058.8,1064.9,1063.8,1059.6;
    3431.6,3389.9,3380.3,3451.1;
    7900,6413.9,6404.5,7926.8];
X=1:4;

h=bar(X,Y,0.8);  
grid on

set(gca,'XTickLabel',{'K=1','K=2','K=3','K=4'},'FontSize',12);
% color
set(h(1),'FaceColor',[255,0,0]/255)     
set(h(2),'FaceColor',[0,0,255]/255)    
set(h(3),'FaceColor',[255,255,0]/255)    
set(h(4),'FaceColor',[0,255,0]/255)    

ylim([0,9000]);      % y

ylabel('Transmit power(W)');
xlabel('The index of K'); 
legend({'radar 1','radar 2','radar 3','radar 4'},'FontSize',12);
