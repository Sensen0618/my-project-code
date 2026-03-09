close all   % close all windows
clear       % clear workspace
clc         % clear command window
f=300e6;    %carrier frequency (Hz)
n=100;       %number of array elements
l=0.04*3e8/f;    %wave length (m)
sa=361;     %sampling
d=l/2;
p=0:d:d*(n-1);
angle=[-90,90];
angle_m=[-26.5 8 37
        -56.5 0  51.5
         -4.5 23 39
        -51.5 0 26.5];
Rat=[sqrt(1) sqrt(1) sqrt(1) 
    sqrt(1) sqrt(1) sqrt(1) 
    sqrt(1) sqrt(1) sqrt(1) 
    sqrt(1) sqrt(1) sqrt(1) ]'; %ratio
s_m=size(angle_m,2);
theta_list = linspace(angle(1, 1), angle(1, 2), 361);
steering_matrixe=exp(-1j*p'*2*pi/l*sin(theta_list*pi/180));
for i=1:4
    m_steering(:,:,i)=exp(-1j*p'*2*pi/l*sin(angle_m(i,:)*pi/180));
    R=[m_steering(:,:,i)] * [m_steering(:,:,i)]';
    RRR=det(R);
    R_inv = pinv(R);
    C=[m_steering(:,:,i)];
    w(:,i)=R_inv*C/(C'*R_inv*C)*Rat(:,i);
end

for it = 1:sa
      a = steering_matrixe(:, it);
      bp1(1, it) = abs(w(:,1)' * a);
      bp2(1, it) = abs(w(:,2)' * a);
      bp3(1, it) = abs(w(:,3)' * a);
      bp4(1, it) = abs(w(:,4)' * a);
end
  % Normalize.
bp1 = 20 * log10(bp1 / max(bp1));
bp2 = 20 * log10(bp2 / max(bp2));
bp3 = 20 * log10(bp3 / max(bp3));
bp4 = 20 * log10(bp4 / max(bp4));

for i = 1:s_m
    gain_m1(1,i) = abs(w(:,1)' * (m_steering(:,i,1)*m_steering(:,i,1)')* w(:,1)) / abs(w(:,1)'*w(:,1));
end

for i = 1:s_m
     gain_m2(1,i) = abs(w(:,2)' * (m_steering(:,i,2)*m_steering(:,i,2)')* w(:,2)) / abs(w(:,2)'*w(:,2));
end

for i = 1:s_m
     gain_m3(1,i) = abs(w(:,3)' * (m_steering(:,i,3)*m_steering(:,i,3)')* w(:,3)) / abs(w(:,3)'*w(:,3));
end

for i = 1:s_m
     gain_m4(1,i) = abs(w(:,4)' * (m_steering(:,i,4)*m_steering(:,i,4)')* w(:,4)) / abs(w(:,4)'*w(:,4));
end
gain=[gain_m1;gain_m2;gain_m3;gain_m4];


%%%%%画图
figure('position',[150,100,1000,750])%确定图片的位置和大小，[x y width height]

subplot(2,2,1);
plot(theta_list,bp1,'LineWidth',1);
grid on;
hold on;
delta = (angle(1, 2) - angle(1, 1)) / 6;
set(gca, 'xlim',[angle(1,1)-10, angle(1, 2)+10],'FontSize',15,'FontName','Times New Roman');
set(gca, 'xtick',angle(1, 1):delta: angle(1, 2),'FontSize',15,'FontName','Times New Roman'); 
%%%坐标
    DB11=bp1(angle_m(1,1)/0.5+181);
    DB11=roundn(DB11,-2); 
    plot(angle_m(1,1),DB11,'r*')
    text(angle_m(1,1)-10,DB11+3,[num2str(DB11)],'FontSize',8,'FontName','Times New Roman')

    DB12=bp1(angle_m(1,2)/0.5+181);
    DB12=roundn(DB12,-2); 
    plot(angle_m(1,2),DB12,'r*')
    text(angle_m(1,2)-5,DB12+3,[num2str(DB12)],'FontSize',8,'FontName','Times New Roman')

    DB13=bp1(angle_m(1,3)/0.5+181);
    DB13=roundn(DB13,-2); 
    plot(angle_m(1,3),DB13,'r*')
    text(angle_m(1,3)-10,DB13+3,[num2str(DB13)],'FontSize',8,'FontName','Times New Roman')

    

xlabel({'\fontname{Times New Roman}\fontsize{15}Azimuth Angle (deg)','\fontname{Times New Roman}\fontsize{17}(R1)'});
ylabel('\fontname{Times New Roman}\fontsize{15}Normalized Beam Pattern (dB)');
set(gca, 'YLim', [-70,5],'FontSize',15,'FontName','Times New Roman');


subplot(2,2,2);
plot(theta_list,bp2,'LineWidth',1);
grid on;
hold on;
delta = (angle(1, 2) - angle(1, 1)) / 6;
set(gca, 'xlim',[angle(1,1)-10, angle(1, 2)+10],'FontSize',15,'FontName','Times New Roman');
set(gca, 'xtick',angle(1, 1):delta: angle(1, 2),'FontSize',15,'FontName','Times New Roman');  

    DB21=bp2(angle_m(2,1)/0.5+181);
    DB21=roundn(DB21,-2); 
    plot(angle_m(2,1),DB21,'r*')
    text(angle_m(2,1)-10,DB21+3,[num2str(DB21)],'FontSize',8,'FontName','Times New Roman')

    DB22=bp2(angle_m(2,2)/0.5+181);
    DB22=roundn(DB22,-2); 
    plot(angle_m(2,2),DB22,'r*')
    text(angle_m(2,2)-5,DB22+3,[num2str(DB22)],'FontSize',8,'FontName','Times New Roman')

    DB23=bp2(angle_m(2,3)/0.5+181);
    DB23=roundn(DB23,-2); 
    plot(angle_m(2,3),DB23,'r*')
    text(angle_m(2,3)-10,DB23+3,[num2str(DB23)],'FontSize',8,'FontName','Times New Roman')

  

xlabel({'\fontname{Times New Roman}\fontsize{15}Azimuth Angle (deg)','\fontname{Times New Roman}\fontsize{17}(R2)'});
ylabel('\fontname{Times New Roman}\fontsize{15}Normalized Beam Pattern (dB)');
set(gca, 'YLim', [-70,5],'FontSize',15,'FontName','Times New Roman');


subplot(2,2,3);
plot(theta_list,bp3,'LineWidth',1);
grid on;
hold on;
delta = (angle(1, 2) - angle(1, 1)) / 6;
set(gca, 'xlim',[angle(1,1)-10, angle(1, 2)+10],'FontSize',15,'FontName','Times New Roman');
set(gca, 'xtick',angle(1, 1):delta: angle(1, 2),'FontSize',15,'FontName','Times New Roman');    

    DB31=bp3(angle_m(3,1)/0.5+181);
    DB31=roundn(DB31,-2); 
    plot(angle_m(3,1),DB31,'r*')
    text(angle_m(3,1)-2,DB31+3,[num2str(DB31)],'FontSize',8,'FontName','Times New Roman')

    DB32=bp3(angle_m(3,2)/0.5+181);
    DB32=roundn(DB32,-2); 
    plot(angle_m(3,2),DB32,'r*')
    text(angle_m(3,2)-5,DB32+3,[num2str(DB32)],'FontSize',8,'FontName','Times New Roman')

    DB33=bp3(angle_m(3,3)/0.5+181);
    DB33=roundn(DB33,-2); 
    plot(angle_m(3,3),DB33,'r*')
    text(angle_m(3,3)-10,DB33+3,[num2str(DB33)],'FontSize',8,'FontName','Times New Roman')

   
xlabel({'\fontname{Times New Roman}\fontsize{15}Azimuth Angle (deg)','\fontname{Times New Roman}\fontsize{17}(R3)'});
ylabel('\fontname{Times New Roman}\fontsize{15}Normalized Beam Pattern (dB)');
set(gca, 'YLim', [-70,5],'FontSize',15,'FontName','Times New Roman');


subplot(2,2,4);
plot(theta_list,bp4,'LineWidth',1);
grid on;
hold on;
delta = (angle(1, 2) - angle(1, 1)) / 6;
set(gca, 'xlim',[angle(1,1)-10, angle(1, 2)+10],'FontSize',15,'FontName','Times New Roman');
set(gca, 'xtick',angle(1, 1):delta: angle(1, 2),'FontSize',15,'FontName','Times New Roman');   

    DB41=bp4(angle_m(4,1)/0.5+181);
    DB41=roundn(DB41,-2); 
    plot(angle_m(4,1),DB41,'r*')
    text(angle_m(4,1)-2,DB41+3,[num2str(DB41)],'FontSize',8,'FontName','Times New Roman')

    DB42=bp4(angle_m(4,2)/0.5+181);
    DB42=roundn(DB42,-2); 
    plot(angle_m(4,2),DB42,'r*')
    text(angle_m(4,2)-4,DB42+3,[num2str(DB42)],'FontSize',8,'FontName','Times New Roman')

    DB43=bp4(angle_m(4,3)/0.5+181);
    DB43=roundn(DB43,-2); 
    plot(angle_m(4,3),DB43,'r*')
    text(angle_m(4,3)-8,DB43+3,[num2str(DB43)],'FontSize',8,'FontName','Times New Roman')

    

xlabel({'\fontname{Times New Roman}\fontsize{15}Azimuth Angle (deg)','\fontname{Times New Roman}\fontsize{17}(R4)'});
ylabel('\fontname{Times New Roman}\fontsize{15}Normalized Beam Pattern (dB)');
set(gca, 'YLim', [-70,5],'FontSize',15,'FontName','Times New Roman');

%saveas(gcf,['K=4','.emf']);

