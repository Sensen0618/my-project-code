clc;
clear;
tic;
rng(1);
tar = 4;         %4个目标  
rad = 4;         %4部雷达
Psize = 5000;    %种群个数
% Psize = 18200;
MaxIt = 1200;    %迭代次数
sumA = 10000;    %每部雷达阵元数目
% c1 = 1.5;        %算法参数
% c2 = 1.5;        %算法参数
% wmax = 1.2;      %惯性因子
% wmin = 0.8;      %惯性因子(k=4)
c1 = 2;          
c2 = 2;         
wmax = 0.6;     
wmin = 0.2;      % (k=1,3)
% c1 = 2;          
% c2 = 2;          
% wmax = 1.2;      
% wmin = 0.2;        % (k=2)

convergence_threshold = 1e-6;  % 收敛阈值
convergence_count = 0;         % 收敛计数器
max_convergence_count = 50;    % 连续收敛次数阈值

P = (50000*ones(rad,tar,Psize)+unidrnd(50000,rad,tar,Psize)).*[1 1 1 0;1 1 0 1;1 0 1 1;0 1 1 1];    %功率矩阵
% a = sum(P,2);
A =[3333.33 3333.33 3333.33 3333.33]'.*ones(4,4,Psize).*[1 1 1 0;1 1 0 1;1 0 1 1;0 1 1 1];        %由功率矩阵更新阵元矩阵
% v_min = -200;
% v_max = 200;           % 功率粒子的速度限制
v_min = -120;
v_max = 120;
v = (v_min + rand(rad,tar,Psize)*(v_max - v_min)).*[1 1 1 0;1 1 0 1;1 0 1 1;0 1 1 1];
% v1_min = -100;
% v1_max = 100;          % 孔径粒子的速度限制
% v1 = v1_min + rand(rad,tar,Psize)*(v1_max - v1_min);
P_min = 0;
% P_max = 90000000000;         %功率约束
P_max = 10000000; 
A_min = 0;
A_max = sumA;           %孔径约束
%%%%%%%%%%初始化个体最优位置和最优值%%%%%%%%%%%% 
ppbest = P;
pabest = A;
pfit = ones(Psize,1);
for i=1:Psize
    pfit(i)= sum(P(:,:,i),[1 2]);
end
%%%%%%%%%初始化全局最优位置和最优值%%%%%%%%%
gpbest=ones(rad,tar);
gabest=ones(rad,tar);
pbestfit = inf;
for i=1:Psize
    PDK1 = DP(P(:,:,i),A(:,:,i));
    res=(PDK1>=0.95);
    if (length(find(res==1))==tar && pfit(i)<pbestfit)
       gpbest = P(:,:,i);
       gabest = A(:,:,i);
       pbestfit = pfit(i);
    end
end
%%%%%%%%%迭代循环%%%%%%%%%
for i=1:MaxIt
%%%%%%%%%功率%%%%%%%%
    for j = 1:Psize
        PDK2 = DP(P(:,:,j),A(:,:,j));
        res=(PDK2>=0.95);
        %%%%%%%%更新功率个体最优位置和最优值%%%%%%
        if (length(find(res==1))==tar && sum(P(:,:,j),[1 2])<pfit(j))
            ppbest(:,:,j) = P(:,:,j);
            pabest(:,:,j) = A(:,:,j);
            pfit(j) = sum(P(:,:,j),[1 2]);
        end
        %%%%%%%%更新功率全局最优位置和最优值%%%%%%
        if (length(find(res==1))==tar && pfit(j)<pbestfit)
            gpbest = P(:,:,j);
            gabest = A(:,:,j);
            pbestfit = pfit(j);
            PDK3 = DP(gpbest,gabest);
        end
        %%%%%%%计算动态惯性权重值%%%%%%%%%%
        w=wmax-(wmax-wmin)*i/MaxIt;    %% 权值更新
        %%%%%%更新功率位置和速度值%%%%%%
        v(:,:,j) = w*v(:,:,j) + c1*rand(1)*(ppbest(:,:,j) - P(:,:,j))+c2*rand(1)*(gpbest - P(:,:,j));
        P(:,:,j) = P(:,:,j) + v(:,:,j);
%         v1(:,:,j) = w*v1(:,:,j) + c1*rand(1)*(pabest(:,:,j) - A(:,:,j))+c2*rand(1)*(gabest - A(:,:,j));
%         A(:,:,j) = A(:,:,j) + v1(:,:,j);
        %%%%%边界条件处理%%%%%%%
        for ii=1:rad
            for jj=1:tar
                if(v(ii,jj,j) > v_max || v(ii,jj,j) < v_min)
                    v(ii,jj,j) = rand*(v_max-v_min)+v_min;
                end
                if(P(ii,jj,j) > P_max )
                    P(ii,jj,j) = P_max;
                end
                if( P(ii,jj,j) < P_min)
                    P(ii,jj,j) =  P_min;
                end
%                 if(v1(ii,jj,i) > v1_max || v1(ii,jj,i) < v1_min)
%                     v1(ii,jj,i) = rand*(v1_max-v1_min)+v1_min;
%                 end
%                 if(A(ii,jj,j) > A_max)
%                     A(ii,jj,j) = A_max;
%                 end
%                 if(A(ii,jj,j) < A_min)
%                     A(ii,jj,j) = A_min;
%                 end
%                 if (P(ii,jj,j)==0)
%                     A(ii,jj,j) = 0;
%                 end
%                 if (A(ii,jj,j)==0)
%                     P(ii,jj,j) = 0;
%                 end
            end
        end
%         for iii=1:rad
%             if (P(iii,:,j)==zeros(1,4))
%                 P(iii,:,j) = unidrnd(90000,1,tar);
%             end
%             if (A(iii,:,j)==zeros(1,5))
%             A(iii,:,j) = unidrnd(10000,1,tar);
%             end
%         end
%         a = sum(P(:,:,j),2);
%         A(:,:,j) = sumA.*P(:,:,j)./a;
    end
    record(i) = pbestfit;
    if i>1
        % 计算适应度变化
        fitness_change = abs(record(i-1) - record(i));

        % 判断是否小于收敛阈值
        if fitness_change < convergence_threshold
            convergence_count = convergence_count + 1;
        else
            convergence_count = 0;  % 重置
        end

        % 达到连续收敛条件时提前结束
        if convergence_count >= max_convergence_count
            break;
        end
    end
    plot(record);
    title('最优适应度进化过程')
     pause(0.0001) 
end
PDK4 = DP(gpbest,gabest);
 ptotal=sum(gpbest,'all');
 aaaa=sum(gpbest./gabest,1);
disp(gpbest);
disp(gabest);
disp(['总功率最优值：',num2str(pbestfit)]);
disp(aaaa(1))
toc;

%%%%%%%秩K融合检测概率%%%%%%%
function DD = DP(P,A)
rad=4;
Pfa = 10^(-8);          %虚警概率
L = 10^(0.5/10);        %系统损耗 
k = 1.38*10^(-23);      %玻尔兹曼常数
F = 10^(0.5/10);        %噪声系数
B = 0.5*10^6;           %频谱宽度
T = 290;                %系统温度
lamda = repmat(0.04,4,4);
sigma = [10 10 10 10
        10 10 10 10
        10 10 10 10
        10 10 10 10];
Tx=[20,30,50,60];
Ty=[40,40,40,40];
Rx=[20,30,50,60];
Ry=[0,0,0,0];

for i=1:4
    for j=1:4
    R(i,j)=((Tx(j)-Rx(i)).^2+(Ty(j)-Ry(i)).^2)^0.5;    
    end
end
SNR = (10000*P.*A.*lamda.^2.*sigma)./(4^3*pi.^3*L*k*F*B*T.*R.^4.*10^12);   %信噪比
PD = 0.5.*erfc(((-log(Pfa))^0.5-(0.5+SNR).^0.5));                    %每个单部雷达对每个目标的检测概率
nsize=4;
n=2^nsize;               %矩阵的行数
W=zeros(n,nsize);        %产生结果矩阵
     for m = 1:n              %二进制有序矩阵的产生
      W(m,:) = bitget(m-1,nsize:-1:1); 
     end
K = 1;
h=0;
for i=1:2^rad
    z=W(i,:)==ones(1,rad);
    if length(find(z==1))>=K
    h=h+1;
    Q(h,:)=W(i,:);
    end
end
for i=1:h
    PDFEI=1-PD;
    Y=(Q(i,:)==ones(1,rad)).';
    PDFEI(Y,:)=PD(Y,:);
    b(i,:)=prod(PDFEI);
end
 DD = sum(b,1); %秩k融合后组网雷达对每个目标的探测概率         
end