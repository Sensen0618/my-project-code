clear 
clc
x=[20,30,50,60];
y=[40,40,40,40];
% z=[20,20,20,20];
Tx=[20,30,50,60];
Ty=[0,0,0,0];
% Tz=[0,0,0,0];
L={'R1','R2','R3','R4','R5','R6','R7','R8'}; %10个标注
 T={'T1','T2','T3','T4','T5','T6','T7','T8'};
% L={'R1','R2','R3'}; %10个标注
% T={'T1','T2','T3','T4',};
plot(x,y,'p','MarkerSize',12,'MarkerFaceColor','c');
hold on
 plot(Tx,Ty,'ko','MarkerSize',12,'MarkerFaceColor','y');
grid on
 %画十个点
% plot(0,0,'.');
% text(2.0,0.1,'Target','FontSize',6,'FontName','Times New Roman');
 for ii=1:4
 text(x(ii)+2,y(ii),T{ii},'FontSize',10,'FontName','Times New Roman'); %利用百十个点的坐标添加对应标注
% %适当增加一些度距离，让文字和点分开会美观一些
 end
 for ii=1:4
   text(Tx(ii)+2,Ty(ii),L{ii},'FontSize',10,'FontName','Times New Roman');
     %text(TT(ii,1)/1000+2,TT(ii,2)/1000+0.1,T{ii},'FontSize',6,'FontName','Times New Roman'); %利用百十个点的坐标添加对应标注
% % %适当增加一些度距离，让文字和点分开会美观一些
  end
%legend('T-radar','R-radar','Target');
legend('\fontname{宋体}目标','\fontname{宋体}雷达');
xlabel('X/km')
ylabel('Y/km')
% zlabel('Z/km')
grid on
% zlim([0 35])
xlim([0 80])
ylim([-10 50])
set(gca,'FontName','Times New Roman');
 set(gca,'FontSize',10);
  xlabel('X(km)','Fontname','Times New Roman','Fontsize',10);
   ylabel('Z(km)','Fontname','Times New Roman','Fontsize',10);
   %   saveas(gcf,['4buju1','.emf']);
%     zlabel('Z Position (km)','Fontname','Times New Roman','Fontsize',10);
% set(gcf,'windowstyle','normal');
% set(gcf,'position',[458+420,342,290,210]);saveas(gca,['fig2','.eps'])
%set(gcf,'paperpositionmode','auto');
%print('-depsc','fig3.eps');