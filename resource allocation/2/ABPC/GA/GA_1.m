clc;
clear;
tic;
rng(1);
tar = 4;         % 4 targets 
rad = 4;         % 4 radars
Psize = 5000;    % Number of populations
ssize = 200;     % Number of single starting point populations
MaxIt = 1200;    % iteration count
sumA = 10000;    % Number of elements per radar array

%% Genetic algorithm parameters
pc = 0.8;        % crossover probability
pm = 0.1;        % mutation probability
elite_rate = 0.1; % Elite retention ratio
selection_method = 'tournament';  % 'roulette'或'tournament'
tournament_size = 3; % Size of tournament selection

convergence_threshold = 1e-6;  % convergence threshold
convergence_count = 0;         % Convergence counter
max_convergence_count = 50;    % Continuous convergence threshold

%%
% Multiple starting points
% Initialize an empty 4x4 matrix
matrix = zeros(4);
valid_mum = 0;
% Record all matrices that meet the conditions
valid_matrices = [];

% The outer loop traverses the position of the first row
for col1 = 1:4
    % Place 1 on the first line
    matrix(1, col1) = 1;
    
    % The inner loop traverses the position of the second row
    for col2 = 1:4
        % Place 1 on the second line
        matrix(2, col2) = 1;
        
        % Check if the second row is valid (each row and column has only one 1)
        if sum(matrix(2,:)) == 1 && sum(matrix(:,col2)) == 1
            % The inner loop traverses the position of the third row
            for col3 = 1:4
                % Place 1 on the third line
                matrix(3, col3) = 1;
                
                % Check if the third row is valid (each row and column has only one 1)
                if sum(matrix(3,:)) == 1 && sum(matrix(:,col3)) == 1
                    % The inner loop traverses the position of the fourth row
                    for col4 = 1:4
                        % Place 1 on the fourth line
                        matrix(4, col4) = 1;
                        
                        % Check if the fourth row is valid (each row and column has only one 1)
                        if sum(matrix(4,:)) == 1 && sum(matrix(:,col4)) == 1
                            % Add the current matrix to the list of valid matrices
                             valid_mum = valid_mum + 1;
                            valid_matrices(:, :, valid_mum) = matrix;
                        end
                        
                        % Reset the fourth line
                        matrix(4, col4) = 0;
                    end
                end
                
                % Reset the third line
                matrix(3, col3) = 0;
            end
        end
        
        % Reset the second line
        matrix(2, col2) = 0;
    end
    
    % Reset the first line
    matrix(1, col1) = 0;
end

%%
% Initialize population
P = 20000 * ones(rad, tar, ssize) + unidrnd(20000, rad, tar, ssize);
for i = 1:24
    P1 = (20000 * ones(rad, tar, ssize) + unidrnd(20000, rad, tar, ssize)) .* valid_matrices(:,:,i);
    P = cat(3, P, P1);
end

% Calculate the corresponding matrix of elements
a = sum(P, 2);
A = sumA .* P ./ a;  % Update the element matrix from the power matrix

P_min = 0;
P_max = 10000000;    % Power constraint
A_min = 0;
A_max = sumA;        % Aperture constraint

% Initialize fitness
fitness = inf * ones(Psize, 1);
PPbestfit = inf;

%%
% Initialize individual fitness
for i = 1:Psize
    PDK1 = DP(P(:,:,i), A(:,:,i));
    res = (PDK1 >= 0.95);
    if length(find(res == 1)) == tar
        fitness(i) = sum(P(:,:,i), [1 2]);
    else
        fitness(i) = 1e10;  % Impossible solution with a large penalty value
    end
end

% Initialize global optimum
Gpbest = [];
Gabest = [];
PPbestfit = inf;

% Record the best fitness of each generation
record = zeros(MaxIt, 1);

%%
% Main loop of genetic algorithm
for gen = 1:MaxIt
    % Calculate the fitness of each individual
    for i = 1:Psize
        PDK1 = DP(P(:,:,i), A(:,:,i));
        res = (PDK1 >= 0.95);
        if length(find(res == 1)) == tar
            current_fit = sum(P(:,:,i), [1 2]);
            if current_fit < fitness(i)
                fitness(i) = current_fit;
            end
        else
            fitness(i) = 1e10;  % Infeasible solution
        end
    end
    
    % Find the optimal solution for the current generation
    [min_fit, min_idx] = min(fitness);
    if min_fit < PPbestfit && min_fit < 1e9  % Ensure it is a feasible solution
        Gpbest = P(:,:,min_idx);
        Gabest = A(:,:,min_idx);
        PPbestfit = min_fit;
    end
    
    record(gen) = PPbestfit;
    
    % Display progress
    if mod(gen, 50) == 0
        fprintf('Generation %d, Best Fitness: %.2f\n', gen, PPbestfit);
    end
    
    % Convergence check
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
    
    % genetic manipulation
    
    % 1. selection operation
    new_pop = zeros(size(P));
    new_fitness = zeros(size(fitness));
    
    % elite retention
    elite_num = round(elite_rate * Psize);
    [sorted_fit, sorted_idx] = sort(fitness);
    elite_indices = sorted_idx(1:elite_num);
    
    for i = 1:elite_num
        new_pop(:,:,i) = P(:,:,elite_indices(i));
        new_fitness(i) = fitness(elite_indices(i));
    end
    
    % Generate remaining individuals
    for i = (elite_num+1):Psize
        if strcmp(selection_method, 'roulette')
            % roulette wheel selection 
            if min(fitness) < 0
                adjusted_fit = fitness - min(fitness) + 1;
            else
                adjusted_fit = max(fitness) - fitness + 1;
            end
            prob = adjusted_fit / sum(adjusted_fit);
            cum_prob = cumsum(prob);
            r = rand();
            parent_idx = find(cum_prob >= r, 1);
            
            parent1 = P(:,:,parent_idx);
            
            % Choose the second parent
            r = rand();
            parent2_idx = find(cum_prob >= r, 1);
            parent2 = P(:,:,parent2_idx);
            
        else
            % tournament selection 
            % Select the first parent
            tournament = randperm(Psize, tournament_size);
            [~, best_idx] = min(fitness(tournament));
            parent1 = P(:,:,tournament(best_idx));
            
            % Choose the second parent
            tournament = randperm(Psize, tournament_size);
            [~, best_idx] = min(fitness(tournament));
            parent2 = P(:,:,tournament(best_idx));
        end
        
        % 2. crossover operation
        if rand() < pc
            % Arithmetic Crossover 
            alpha = rand(size(parent1));
            child = alpha .* parent1 + (1 - alpha) .* parent2;
        else
            child = parent1;  % Do not cross, copy directly
        end
        
        % 3. mutation operation
        for r = 1:rad
            for t = 1:tar
                if rand() < pm
                    % Gaussian mutation
                    mutation_strength = 0.1 * (P_max - P_min);
                    child(r,t) = child(r,t) + mutation_strength * randn();
                    
                    % boundary handling
                    if child(r,t) > P_max
                        child(r,t) = P_max;
                    elseif child(r,t) < P_min
                        child(r,t) = P_min;
                    end
                end
            end
        end
        
        % Ensure that each row has at least one non-zero value
        for r = 1:rad
            if sum(child(r,:)) == 0
                random_tar = randi(tar);
                child(r, random_tar) = P_min + rand() * (P_max - P_min);
            end
        end
        
        new_pop(:,:,i) = child;
        
        % Calculate the element matrix of the offspring
        a_child = sum(child, 2);
        A_child = sumA .* child ./ a_child;
        
        % Evaluate offspring fitness
        PDK_child = DP(child, A_child);
        res_child = (PDK_child >= 0.95);
        if length(find(res_child == 1)) == tar
            new_fitness(i) = sum(child, [1 2]);
        else
            new_fitness(i) = 1e10;
        end
    end
    
    % Update population
    P = new_pop;
    fitness = new_fitness;
    
    % Update the matrix of all individual elements
    for i = 1:Psize
        a_i = sum(P(:,:,i), 2);
        A(:,:,i) = sumA .* P(:,:,i) ./ a_i;
    end
    
    % 绘图
    plot(record(1:gen));
    title('Evolution process of optimal fitness of genetic algorithm');
    xlabel('iteration count');
    ylabel('total power');
    grid on;
    pause(0.0001);
end

%%
% Output result
PDK3 = DP(Gpbest, Gabest);
disp('Optimal power allocation matrix:');
disp(Gpbest);
disp('Optimal Element Allocation Matrix:');
disp(Gabest);
disp(['Optimal value of total power：', num2str(PPbestfit)]);
disp(['Final detection probability：', num2str(PDK3)]);

% Draw the final convergence curve
figure;
plot(record(1:gen));
title('Convergence curve of genetic algorithm(k=1)');
xlabel('iteration count');
ylabel('total power');
grid on;

record1 = record(1:gen);
save('case2_GA1_record.mat', 'record1');
toc;

%% Detecting probability function
function DD = DP(P, A)
    rad = 4;
    Pfa = 10^(-8);          % False alarm probability
    L = 10^(0.5/10);        % System loss 
    k = 1.38*10^(-23);      % Boltzmann constant
    F = 10^(0.5/10);        % Noise Figure
    B = 0.5*10^6;           % Spectrum width
    T = 290;                % system temperature
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
    
    K = 1;
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