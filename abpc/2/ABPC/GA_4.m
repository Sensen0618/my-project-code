clc;
clear;
tic;
rng(1);
tar = 4;         % 4个目标  
rad = 4;         % 4部雷达
Psize = 5000;    % 种群大小
MaxIt = 2500;    % 最大迭代次数
sumA = 10000;    % 每部雷达阵元数目

%% 遗传算法参数
pc = 0.8;         % 交叉概率
pm = 0.1;        % 变异概率
elite_rate = 0.1; % 精英保留比例
selection_method = 'tournament'; % 选择方法
tournament_size = 3; % 锦标赛选择的大小

convergence_threshold = 1e-6;  % 收敛阈值
convergence_count = 0;         % 收敛计数器
max_convergence_count = 50;    % 连续收敛次数阈值

%% 初始化种群
P = 30000 * ones(rad, tar, Psize) + unidrnd(30000, rad, tar, Psize);
a = sum(P, 2);
A = sumA .* P ./ a;  % 由功率矩阵更新阵元矩阵

P_min = 0;
P_max = 80000000;    % 功率约束
A_min = 0;
A_max = sumA;        % 孔径约束

%% 初始化适应度
fitness = inf * ones(Psize, 1);
PPbestfit = inf;

% 计算初始适应度
for i = 1:Psize
    PDK1 = DP(P(:,:,i), A(:,:,i));
    res = (PDK1 >= 0.95);
    if length(find(res == 1)) == tar
        fitness(i) = sum(P(:,:,i), [1 2]);
    else
        fitness(i) = 1e10;  % 不可行解给一个大惩罚值
    end
end

% 初始化全局最优
Gpbest = [];
Gabest = [];
PPbestfit = inf;

% 记录每一代的最佳适应度
record = zeros(MaxIt, 1);

%% 遗传算法主循环
for gen = 1:MaxIt
    % 计算每个个体的适应度
    for i = 1:Psize
        PDK1 = DP(P(:,:,i), A(:,:,i));
        res = (PDK1 >= 0.95);
        if length(find(res == 1)) == tar
            current_fit = sum(P(:,:,i), [1 2]);
            if current_fit < fitness(i)
                fitness(i) = current_fit;
            end
        else
            fitness(i) = 1e10;  % 不可行解
        end
    end
    
    % 找到当前代的最优解
    [min_fit, min_idx] = min(fitness);
    if min_fit < PPbestfit && min_fit < 1e9  % 确保是可行解
        Gpbest = P(:,:,min_idx);
        Gabest = A(:,:,min_idx);
        PPbestfit = min_fit;
    end
    
    record(gen) = PPbestfit;
    
    % 显示进度
    if mod(gen, 50) == 0
        fprintf('Generation %d, Best Fitness: %.2f\n', gen, PPbestfit);
    end
    
    % 收敛性检查
    if gen > 1
        fitness_change = abs(record(gen-1) - record(gen));
        if fitness_change < convergence_threshold
            convergence_count = convergence_count + 1;
        else
            convergence_count = 0;
        end
        
        if convergence_count >= max_convergence_count
            fprintf('Early convergence at generation %d\n', gen);
            break;
        end
    end
    
    %% 遗传操作
    new_pop = zeros(size(P));
    new_fitness = zeros(size(fitness));
    
    % 精英保留
    elite_num = round(elite_rate * Psize);
    [sorted_fit, sorted_idx] = sort(fitness);
    elite_indices = sorted_idx(1:elite_num);
    
    for i = 1:elite_num
        new_pop(:,:,i) = P(:,:,elite_indices(i));
        new_fitness(i) = fitness(elite_indices(i));
    end
    
    % 生成剩余个体
    for i = (elite_num+1):Psize
        % 选择操作
        if strcmp(selection_method, 'roulette')
            % 轮盘赌选择
            if min(fitness) < 0
                adjusted_fit = fitness - min(fitness) + 1;
            else
                adjusted_fit = max(fitness) - fitness + 1;
            end
            prob = adjusted_fit / sum(adjusted_fit);
            cum_prob = cumsum(prob);
            r = rand();
            parent1_idx = find(cum_prob >= r, 1);
            
            % 选择第二个父代
            r = rand();
            parent2_idx = find(cum_prob >= r, 1);
            
        else
            % 锦标赛选择
            tournament1 = randperm(Psize, tournament_size);
            [~, best1_idx] = min(fitness(tournament1));
            parent1_idx = tournament1(best1_idx);
            
            tournament2 = randperm(Psize, tournament_size);
            [~, best2_idx] = min(fitness(tournament2));
            parent2_idx = tournament2(best2_idx);
        end
        
        parent1 = P(:,:,parent1_idx);
        parent2 = P(:,:,parent2_idx);
        
        % 交叉操作
        if rand() < pc
            % 算术交叉
            alpha = rand(size(parent1));
            child = alpha .* parent1 + (1 - alpha) .* parent2;
        else
            % 不交叉，直接复制第一个父代
            child = parent1;
        end
        
        % 变异操作
        for r = 1:rad
            for t = 1:tar
                if rand() < pm
                    % 高斯变异
                    mutation_strength = 0.1 * (P_max - P_min);
                    child(r,t) = child(r,t) + mutation_strength * randn();
                    
                    % 边界处理
                    if child(r,t) > P_max
                        child(r,t) = P_max;
                    elseif child(r,t) < P_min
                        child(r,t) = P_min;
                    end
                end
            end
        end
        
        % 存储新个体
        new_pop(:,:,i) = child;
        
        % 计算子代的阵元矩阵
        a_child = sum(child, 2);
        A_child = sumA .* child ./ a_child;
        
        % 评估子代适应度
        PDK_child = DP(child, A_child);
        res_child = (PDK_child >= 0.95);
        if length(find(res_child == 1)) == tar
            new_fitness(i) = sum(child, [1 2]);
        else
            new_fitness(i) = 1e10;
        end
    end
    
    % 更新种群
    P = new_pop;
    fitness = new_fitness;
    
    % 更新所有个体的阵元矩阵
    for i = 1:Psize
        a_i = sum(P(:,:,i), 2);
        A(:,:,i) = sumA .* P(:,:,i) ./ a_i;
    end
    
    % 绘图
    plot(record(1:gen));
    title('遗传算法最优适应度进化过程(k=4)');
    xlabel('迭代次数');
    ylabel('总功率');
    grid on;
    pause(0.0001);
end

%%
% 输出结果
PDK3 = DP(Gpbest, Gabest);
disp('最优功率分配矩阵:');
disp(Gpbest);
disp('最优阵元分配矩阵:');
disp(Gabest);
disp(['总功率最优值：', num2str(PPbestfit)]);
disp(['最终检测概率：', num2str(PDK3)]);

% 绘制最终收敛曲线
figure;
plot(record(1:gen));
title('遗传算法收敛曲线(k=4)');
xlabel('迭代次数');
ylabel('总功率');
grid on;

record4 = record(1:gen);
save('case2_GA4_record.mat', 'record4');
toc;

%% 检测概率函数（k=4版本）
function DD = DP(P, A)
    rad = 4;
    Pfa = 10^(-8);          % 虚警概率
    L = 10^(0.5/10);        % 系统损耗 
    k = 1.38*10^(-23);      % 玻尔兹曼常数
    F = 10^(0.5/10);        % 噪声系数
    B = 0.5*10^6;           % 频谱宽度
    T = 290;                % 系统温度
    lamda = repmat(0.04, 4, 4);
    sigma = [10 10 10 10
            10 10 10 10
            10 10 10 10
            10 10 10 10];
    
    Tx=[-10,20,40,70];
    Ty=[40,70,40,60];
    Rx=[10,20,25,40];
    Ry=[0,20,5,0];
    
    for i = 1:4
        for j = 1:4
            R(i,j) = ((Tx(j) - Rx(i)).^2 + (Ty(j) - Ry(i)).^2)^0.5;    
        end
    end
    
    SNR = (10000 * P .* A .* lamda.^2 .* sigma) ./ (4^3 * pi^3 * L * k * F * B * T .* R.^4 .* 10^12);
    PD = 0.5 .* erfc(((-log(Pfa))^0.5 - (0.5 + SNR).^0.5));
    
    nsize = 4;
    n = 2^nsize;
    W = zeros(n, nsize);
    for m = 1:n
        W(m,:) = bitget(m-1, nsize:-1:1); 
    end
    
    K = 4;  % 秩K融合，K=4
    h = 0;
    for i = 1:2^rad
        z = W(i,:) == ones(1, rad);
        if length(find(z == 1)) >= K
            h = h + 1;
            Q(h,:) = W(i,:);
        end
    end
    
    for i = 1:h
        PDFEI = 1 - PD;
        Y = (Q(i,:) == ones(1, rad)).';
        PDFEI(Y,:) = PD(Y,:);
        b(i,:) = prod(PDFEI);
    end
    
    DD = sum(b, 1);
end