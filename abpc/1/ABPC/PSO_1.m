clc;
clear;
tic;
rng(1);
tar = 4;         %4个目标  
rad = 4;         %4部雷达
Psize = 5000;    %种群个数
ssize=200;       %单起点种群个数
MaxIt = 1000;    %迭代次数
sumA = 10000;    %每部雷达阵元数目
c1 = 2;          %算法参数
c2 = 2;          %算法参数
wmax = 0.6;      %惯性因子
wmin = 0.2;      %惯性因子
PPbestfit=inf;

convergence_threshold = 1e-6;  % 收敛阈值
convergence_count = 0;         % 收敛计数器
max_convergence_count = 50;    % 连续收敛次数阈值
%%
% 多起点
% 初始化一个空的4x4矩阵
matrix = zeros(4);
valid_mum=0;
% 记录所有满足条件的矩阵
valid_matrices = [];

% 外层循环遍历第一行的位置
for col1 = 1:4
    % 在第一行放置1
    matrix(1, col1) = 1;
    
    % 内层循环遍历第二行的位置
    for col2 = 1:4
        % 在第二行放置1
        matrix(2, col2) = 1;
        
        % 检查第二行是否有效（每行每列只有一个1）
        if sum(matrix(2,:)) == 1 && sum(matrix(:,col2)) == 1
            % 内层循环遍历第三行的位置
            for col3 = 1:4
                % 在第三行放置1
                matrix(3, col3) = 1;
                
                % 检查第三行是否有效（每行每列只有一个1）
                if sum(matrix(3,:)) == 1 && sum(matrix(:,col3)) == 1
                    % 内层循环遍历第四行的位置
                    for col4 = 1:4
                        % 在第四行放置1
                        matrix(4, col4) = 1;
                        
                        % 检查第四行是否有效（每行每列只有一个1）
                        if sum(matrix(4,:)) == 1 && sum(matrix(:,col4)) == 1
                            % 将当前矩阵添加到有效矩阵列表中
                             valid_mum=valid_mum+1 ;
                            valid_matrices(:, :,  valid_mum) = matrix;
                        end
                        
                        % 重置第四行
                        matrix(4, col4) = 0;
                    end
                end
                
                % 重置第三行
                matrix(3, col3) = 0;
            end
        end
        
        % 重置第二行
        matrix(2, col2) = 0;
    end
    
    % 重置第一行
    matrix(1, col1) = 0;
end

% 打印所有满足条件的矩阵
%disp(valid_matrices); 
%%
P = 10000*ones(rad,tar,ssize)+unidrnd(10000,rad,tar,ssize);
for i=1:24
    P1 = (10000*ones(rad,tar,ssize)+unidrnd(10000,rad,tar,ssize)).*valid_matrices(:,:,i);   %功率矩阵
    P = cat(3,P,P1);
end
a = sum(P,2);
A = sumA.*P./a;       %由功率矩阵更新阵元矩阵
v_min = -120;
v_max = 120;           % 功率粒子的速度限制
v = v_min + rand(rad,tar,ssize)*(v_max - v_min);
for i=1:24
    v1= (v_min + rand(rad,tar,ssize)*(v_max - v_min)).*valid_matrices(:,:,i);
     v = cat(3,v,v1);
end
P_min = 0;
P_max = 10000000;         %功率约束
A_min = 0;
A_max = sumA;           %孔径约束
%%
%%%%%%%%%%初始化个体最优位置和最优值%%%%%%%%%%%% 
ppbest = P;
pabest = A;
pfit = ones(Psize,1);
for i=1:Psize
    pfit(i)= sum(P(:,:,i),[1 2]);
end

%%
%%%%%%%%%初始化全局最优位置和最优值%%%%%%%%%
gpbest=ones(rad,tar,Psize/ssize);
gabest=ones(rad,tar,Psize/ssize);
pbestfit = inf*ones(Psize/ssize,1);
for i=1:Psize
    PDK1 = DP(P(:,:,i),A(:,:,i));
    res=(PDK1>=0.95);
    if (length(find(res==1))==tar && pfit(i)<pbestfit(ceil(i/ssize),1))
       gpbest(:,:,ceil(i/ssize)) = P(:,:,i);
       gabest(:,:,ceil(i/ssize)) = A(:,:,i);
       pbestfit(ceil(i/ssize),1) = pfit(i);
    end
end

%%
%%%%%%%%%迭代循环%%%%%%%%%
for i=1:MaxIt
%%%%%%%%%功率%%%%%%%%
    for j = 1:Psize
        PDK2 = DP(P(:,:,j),A(:,:,j));
        res=(PDK2>=0.95);
        %%%%%%%%更新功率个体最优位置和最优值%%%%%%
        if (length(find(res==1))==tar && sum(P(:,:,j),[1 2])<=pfit(j))
            ppbest(:,:,j) = P(:,:,j);
            pabest(:,:,j) = A(:,:,j);
            pfit(j) = sum(P(:,:,j),[1 2]);
        end
        %%%%%%%%更新功率全局最优位置和最优值%%%%%%
        if (length(find(res==1))==tar && pfit(j)<=pbestfit(ceil(j/ssize),1))
            gpbest(:,:,ceil(j/ssize)) = P(:,:,j);
            gabest(:,:,ceil(j/ssize)) = A(:,:,j);
            pbestfit(ceil(j/ssize),1) = pfit(j);
        end
        %%%%%%%计算动态惯性权重值%%%%%%%%%%
        w=wmax-(wmax-wmin)*i/MaxIt;    %% 权值更新
        %%%%%%更新功率位置和速度值%%%%%%
        v(:,:,j) = w*v(:,:,j) + c1*rand(1)*(ppbest(:,:,j)-P(:,:,j))+c2*rand(1)*(gpbest(:,:,ceil(j/ssize))-P(:,:,j));
        P(:,:,j) = P(:,:,j) + v(:,:,j);
%         v1(:,:,j) = w*v1(:,:,j) + c1*rand(1)*(pabest(:,:,j) - A(:,:,j))+c2*rand(1)*(gabest - A(:,:,j));
%         A(:,:,j) = A(:,:,j) + v1(:,:,j);
        %%%%%边界条件处理%%%%%%%
        for ii=1:rad
            for jj=1:tar
                if(v(ii,jj,j) > v_max)
                    v(ii,jj,j) = v_min + rand(1)*(v_max - v_min);
                end
                if(v(ii,jj,j) < v_min)
                     v(ii,jj,j) = v_min + rand(1)*(v_max - v_min);
                end
            end
        end
        
        for ii=1:rad
            for jj=1:tar
                if(P(ii,jj,j) > P_max )
                    P(ii,jj,j) = P_max;
                end
                if( P(ii,jj,j) < P_min)
                    P(ii,jj,j) =  P_min;
                end
%                 if(v1(ii,jj,i) > v1_max || v1(ii,jj,i) < v1_min)
%                     v1(ii,jj,i) = rand*(v1_max-v1_min)+v1_min;
%                 end
            end
        end
        a = sum(P(:,:,j),2);
        A(:,:,j) = sumA.*P(:,:,j)./a;
    end
    
    for mm=1:Psize/ssize
        PP=sum(gpbest(:,:,mm),[1 2]);
        if PP<PPbestfit
            Gpbest=gpbest(:,:,mm);
            Gabest=gabest(:,:,mm);
            PPbestfit=PP;
        end
    end   
    record(i) = PPbestfit;
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
    title('最优适应度进化过程(k=1)')
    pause(0.0001) 
end

PDK3 = DP(Gpbest,Gabest);
disp('最优功率分配矩阵:');
disp(Gpbest);
disp('最优阵元分配矩阵:');
disp(Gabest);
disp(['总功率最优值：',num2str(PPbestfit)]);
disp(['最终检测概率：', num2str(PDK3)]);
toc;

% %% 计算优化后的信噪比矩阵
% % 定义信噪比计算参数（与DP函数中相同）
% Pfa = 10^(-8);          %虚警概率
% L = 10^(0.5/10);        %系统损耗 
% k = 1.38*10^(-23);      %玻尔兹曼常数
% F = 10^(0.5/10);        %噪声系数
% B = 0.5*10^6;           %频谱宽度
% T = 290;                %系统温度
% lamda = repmat(0.04,4,4);
% sigma = [10 10 10 10
%         10 10 10 10
%         10 10 10 10
%         10 10 10 10];
% Tx=[20,30,50,60];
% Ty=[40,40,40,40];
% Rx=[20,30,50,60];
% Ry=[0,0,0,0];
% 
% % 计算距离矩阵
% R = zeros(4,4);
% for i=1:4
%     for j=1:4
%         R(i,j)=((Tx(j)-Rx(i)).^2+(Ty(j)-Ry(i)).^2)^0.5;    
%     end
% end
% 
% % 使用最优解计算信噪比
% SNR_optimal = (10000*Gpbest.*Gabest.*lamda.^2.*sigma)./(4^3*pi^3*L*k*F*B*T.*R.^4.*10^12);
% 
% % 输出信噪比矩阵
% disp('优化后的信噪比矩阵(SNR):');
% disp(SNR_optimal);
% 
% % 输出各雷达对目标的平均信噪比
% disp('各雷达对各目标的信噪比统计:');
% for i=1:rad
%     for j=1:tar
%         fprintf('雷达%d对目标%d的信噪比: %.4f dB\n', i, j, 10*log10(SNR_optimal(i,j)));
%     end
% end
%%
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
% sigma = [10 9 8 7
%         10 9 8 7
%         10 9 8 7
%         10 9 8 7];
Tx=[20,30,50,60];
Ty=[40,40,40,40];
Rx=[20,30,50,60];
Ry=[0,0,0,0];

for i=1:4
    for j=1:4
    R(i,j)=((Tx(j)-Rx(i)).^2+(Ty(j)-Ry(i)).^2)^0.5;    
    end
end
SNR = (10000*P.*A.*lamda.^2.*sigma)./(4^3*pi^3*L*k*F*B*T.*R.^4.*10^12);   %信噪比
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
% save('PSO1_record.mat', 'record');