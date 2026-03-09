clc;
clear;
tic;
rng(1);
tar = 4;         % 4个目标  
rad = 4;         % 4部雷达
Psize = 5000;    % 种群大小
ssize = 200;     % 单起点种群个数
MaxIt = 1200;    % 最大迭代次数
sumA = 10000;    % 每部雷达阵元数目

%% 遗传算法参数
pc = 0.8;        % 交叉概率
pm = 0.15;       % 变异概率
elite_rate = 0.1; % 精英保留比例
selection_method = 'tournament'; % 选择方法
tournament_size = 3; % 锦标赛选择的大小

convergence_threshold = 1e-6;  % 收敛阈值
convergence_count = 0;         % 收敛计数器
max_convergence_count = 50;    % 连续收敛次数阈值

%% 生成所有满足条件的矩阵（每行每列恰好有三个1）
matrix = zeros(4);
valid_mum = 0;
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
                            valid_mum = valid_mum + 1;
                            valid_matrices(:, :, valid_mum) = matrix;
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

% 取反得到每行每列恰好有三个1的矩阵
valid_matrices = 1 - valid_matrices;

%%
% 初始化种群
P = 20000 * ones(rad, tar, ssize) + unidrnd(20000, rad, tar, ssize);
for i = 1:24
    P1 = (20000 * ones(rad, tar, ssize) + unidrnd(20000, rad, tar, ssize)) .* valid_matrices(:,:,i);
    P = cat(3, P, P1);
end

% 计算对应的阵元矩阵
a = sum(P, 2);
A = sumA .* P ./ a;

P_min = 0;
P_max = 40000000;    % 功率约束
A_min = 0;
A_max = sumA;        % 孔径约束

% 初始化适应度
fitness = inf * ones(Psize, 1);
PPbestfit = inf;

%%
% 初始化个体适应度
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

% 存储每个个体的有效矩阵索引
matrix_indices = zeros(Psize, 1);
for i = 1:Psize
    % 获取当前个体的有效矩阵索引
    non_zero_pattern = (P(:,:,i) > 0);
    for m = 1:24
        if isequal(non_zero_pattern, valid_matrices(:,:,m))
            matrix_indices(i) = m;
            break;
        end
    end
    if matrix_indices(i) == 0
        matrix_indices(i) = randi(24); % 如果没有匹配，随机分配一个
    end
end

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
    new_matrix_indices = zeros(size(matrix_indices));
    new_fitness = zeros(size(fitness));
    
    % 精英保留
    elite_num = round(elite_rate * Psize);
    [sorted_fit, sorted_idx] = sort(fitness);
    elite_indices = sorted_idx(1:elite_num);
    
    for i = 1:elite_num
        new_pop(:,:,i) = P(:,:,elite_indices(i));
        new_matrix_indices(i) = matrix_indices(elite_indices(i));
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
        idx1 = matrix_indices(parent1_idx);
        idx2 = matrix_indices(parent2_idx);
        
        % 交叉操作
        if rand() < pc
            % 算术交叉：当父代有相同的结构时
            if idx1 == idx2
                alpha = rand(size(parent1));
                child = alpha .* parent1 + (1 - alpha) .* parent2;
                new_idx = idx1;
            else
                % 如果结构不同，随机选择一种结构
                if rand() < 0.5
                    child = parent1;
                    new_idx = idx1;
                else
                    child = parent2;
                    new_idx = idx2;
                end
            end
        else
            % 不交叉，直接复制第一个父代
            child = parent1;
            new_idx = idx1;
        end
        
        % 变异操作
        if rand() < pm
            % 结构变异：随机改变有效矩阵（保持每行每列三个1）
            if rand() < 0.3  % 30%的概率改变结构
                new_idx = randi(24);
                pattern = valid_matrices(:,:,new_idx);
                
                % 创建新的功率矩阵，保持每行每列恰好三个非零值
                child = zeros(rad, tar);
                [row_idx, col_idx] = find(pattern);
                for k = 1:length(row_idx)
                    child(row_idx(k), col_idx(k)) = P_min + rand() * (P_max - P_min);
                end
            else
                % 值变异：保持结构，只改变功率值
                pattern = valid_matrices(:,:,new_idx);
                [row_idx, col_idx] = find(pattern);
                for k = 1:length(row_idx)
                    if rand() < 0.2  % 每个非零位置有20%的概率变异
                        mutation_strength = 0.2 * (P_max - P_min);
                        child(row_idx(k), col_idx(k)) = child(row_idx(k), col_idx(k)) + ...
                            mutation_strength * randn();
                        
                        % 边界处理
                        if child(row_idx(k), col_idx(k)) > P_max
                            child(row_idx(k), col_idx(k)) = P_max;
                        elseif child(row_idx(k), col_idx(k)) < P_min
                            child(row_idx(k), col_idx(k)) = P_min;
                        end
                    end
                end
            end
        end
        
        % 确保每行恰好有三个非零值（每行三个1的约束）
        pattern = valid_matrices(:,:,new_idx);
        child = child .* pattern;  % 确保只有指定位置有值
        
        % 存储新个体
        new_pop(:,:,i) = child;
        new_matrix_indices(i) = new_idx;
        
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
    matrix_indices = new_matrix_indices;
    fitness = new_fitness;
    
    % 更新所有个体的阵元矩阵
    for i = 1:Psize
        a_i = sum(P(:,:,i), 2);
        A(:,:,i) = sumA .* P(:,:,i) ./ a_i;
    end
    
    % 绘图
    plot(record(1:gen));
    title('遗传算法最优适应度进化过程(k=3)');
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
title('遗传算法收敛曲线(k=3)');
xlabel('迭代次数');
ylabel('总功率');
grid on;

record3 = record(1:gen);
save('case2_GA3_record.mat', 'record3');
toc;

%% 检测概率函数（k=3版本）
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
    
    K = 3;  % 秩K融合，K=3
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