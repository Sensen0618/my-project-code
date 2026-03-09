clear 
clc


Tx=[-10,20,40,70];
Ty=[40,70,40,60];
% z=[20,20,20,20];
Rx=[10,20,25,40];
Ry=[0,20,5,0];
for i=1:4
    for j=1:4
    R(i,j)=((Tx(j)-Rx(i)).^2+(Ty(j)-Ry(i)).^2)^0.5;    
    end
end
% Tz=[0,0,0,0];
L={'R1','R2','R3','R4','R5','R6','R7','R8'}; %10个标注
 T={'T1','T2','T3','T4','T5','T6','T7','T8'};
% L={'R1','R2','R3'}; %10个标注
% T={'T1','T2','T3','T4',};
plot(Tx,Ty,'p','MarkerSize',12,'MarkerFaceColor','c');
hold on
 plot(Rx,Ry,'ko','MarkerSize',12,'MarkerFaceColor','y');
grid on
 %画十个点
% plot(0,0,'.');
% text(2.0,0.1,'Target','FontSize',6,'FontName','Times New Roman');
 for ii=1:4
 text(Tx(ii)+3,Ty(ii),T{ii},'FontSize',10,'FontName','Times New Roman'); %利用百十个点的坐标添加对应标注
% %适当增加一些度距离，让文字和点分开会美观一些
 end
 for ii=1:4
   text(Rx(ii)+3,Ry(ii),L{ii},'FontSize',10,'FontName','Times New Roman');
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
xlim([-20 80])
ylim([-20 80])
set(gca,'FontName','Times New Roman');
 set(gca,'FontSize',10);
  xlabel('X(km)','Fontname','Times New Roman','Fontsize',10);
   ylabel('Z(km)','Fontname','Times New Roman','Fontsize',10);
   %   saveas(gcf,['42buju1','.emf']);
%     zlabel('Z Position (km)','Fontname','Times New Roman','Fontsize',10);
% set(gcf,'windowstyle','normal');
% set(gcf,'position',[458+420,342,290,210]);saveas(gca,['fig2','.eps'])
%set(gcf,'paperpositionmode','auto');
%print('-depsc','fig10.eps');