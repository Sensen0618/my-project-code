clear
clc
%% Construct simulation scenarios
Tx=[-10,20,40,70];
Ty=[40,70,40,60];

Rx=[10,20,25,40];
Ry=[0,20,5,0];
for i=1:4
    for j=1:4
    R(i,j)=((Tx(j)-Rx(i)).^2+(Ty(j)-Ry(i)).^2)^0.5;    
    end
end

figure(1)
L={'target1','target2','target3','target4',};
T={'radar1','radar2','radar3','radar4'};
plot(Tx,Ty,'*');
hold on
plot(Rx,Ry,'H');
xlabel('X/km')
ylabel('Y/km')
zlabel('Z/km')
% set(gca,'FontName','Times New Roman');
set(gca,'FontSize',10);
zlim([0 35])
grid on
   for ii=1:4
     text(Tx(ii)+4,Ty(ii)+0.1,L{ii},'FontSize',10); 
   end
   for ii=1:4
     text(Rx(ii)+4,Ry(ii)+0.1,T{ii},'FontSize',10);
   end
h=legend('target','radar');
set(h,'FontSize',10);

hold off
%%  Construct a target selection matrix
RCS=10;
for i=1:4
    for j=1:4
    R(i,j)=((Tx(j)-Rx(i)).^2+(Ty(j)-Ry(i)).^2)^0.5;    
    end
end
W=RCS./R.^4;
s=zeros(4,4);
WW=W;
% target selection
for i=1:4
    [W_max,W_d]=max(W,[],1);
    W_1 =[W_max;W_d];
    W_max_re=sort(W_max);
    [index,indey]=find(W_max==W_max_re(i));
    indey=indey(1);
    W_e=W_1(2,indey);
    s(W_e,indey)=1;
    W(:,indey)=0;
    W1=sum(s,2)==3;
    W=~W1.*W;
end
%% Plot the results of target selection
figure(2)
imagesc(s);
c=colorbar;
set(c,'Ytick',0:1:1);
maymap=[0,0,0;1,0,0];
colormap(maymap)
xlabel('target serial number','fontsize',13);
ylabel('radar serial number','fontsize',13);
set(gca,'Xtick',[1,2,3,4]);
set(gca,'Ytick',[1,2,3,4]);
% saveas(gcf,['the results of target selection (K=1)','.emf']);

%  k=2
ss=~s;
W=WW.*ss;
W1=sum(s,2)==3;
W=~W1.*W;
for i=1:4
    [W_max,W_d]=max(W,[],1);
    W_1 =[W_max;W_d];
    W_max_re=sort(W_max);
    [index,indey]=find(W_max==W_max_re(i));
    indey=indey(1);
    W_e=W_1(2,indey);
    s(W_e,indey)=1;
    W(:,indey)=0;
    W1=sum(s,2)==3;
    W=~W1.*W;
end
%%
figure(3)
imagesc(s);
c=colorbar;
set(c,'Ytick',0:1:1);
maymap=[0,0,0;1,0,0];
colormap(maymap)
xlabel('target serial number','fontsize',13);
ylabel('radar serial number','fontsize',13);
set(gca,'Xtick',[1,2,3,4]);
set(gca,'Ytick',[1,2,3,4]);
% saveas(gcf,['the results of target selection (K=2)','.emf']);

%  k=3
ss=~s;
W=WW.*ss;
W1=sum(s,2)==3;
W=~W1.*W;
for i=1:4
    [W_max,W_d]=max(W,[],1);
    W_1 =[W_max;W_d];
    W_max_re=sort(W_max);
    [index,indey]=find(W_max==W_max_re(i));
    indey=indey(1);
    W_e=W_1(2,indey);
    s(W_e,indey)=1;
    W(:,indey)=0;
    W1=sum(s,2)==3;
    W=~W1.*W;
end
%% 目标选择结果作图
figure(4)
imagesc(s);
c=colorbar;
set(c,'Ytick',0:1:1);
maymap=[0,0,0;1,0,0];
colormap(maymap)
xlabel('target serial number','fontsize',13);
ylabel('radar serial number','fontsize',13);
set(gca,'Xtick',[1,2,3,4]);
set(gca,'Ytick',[1,2,3,4]);
% saveas(gcf,['the results of target selection (K=3)','.emf']);

