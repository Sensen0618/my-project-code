% Sample program
% The specific values can be adjusted according to the actual results

clear;
clc;
figure('position',[150,100,800,600]) % [x y width height]

% data
Y=[365.6,571.3,192.2,1851;
   4591.3,1541.5,4196,3650.3;
    9447.8,6503.8,8369.5,12892;
    27410,8731.7,18579,24328];
X=1:4;

h=bar(X,Y,0.8);  
grid on

set(gca,'XTickLabel',{'K=1','K=2','K=3','K=4'},'FontSize',12);
% color
set(h(1),'FaceColor',[255,0,0]/255)     
set(h(2),'FaceColor',[0,0,255]/255)    
set(h(3),'FaceColor',[255,255,0]/255)    
set(h(4),'FaceColor',[0,255,0]/255)    
ylim([0,30000]);      % y 

ylabel('Transmit power(W)');
xlabel('The index of K'); 
legend({'radar 1','radar 2','radar 3','radar 4'},'FontSize',12);
