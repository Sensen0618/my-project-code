clc;
clear;
tic;
rng(1);
tar = 4;         % 4 targets  
rad = 4;         % 4 radars
Psize = 5000;    % population size
ssize = 200;     % single-start population size
MaxIt = 1000;    % maximum number of iterations
sumA = 10000;    % number of array elements per radar

%% GA parameters
pc = 0.8;        % crossover probability
pm = 0.1;        % mutation probability
elite_rate = 0.1; % elite retention ratio
selection_method = 'tournament'; % selection method: 'roulette' or 'tournament'
tournament_size = 3; % tournament selection size

convergence_threshold = 1e-6;  % convergence threshold
convergence_count = 0;         % convergence counter
max_convergence_count = 50;    % maximum consecutive convergence count

%%
% Multiple starting points
% Initialize an empty 4x4 matrix
matrix = zeros(4);
valid_mum = 0;
% Store all matrices that satisfy the condition
valid_matrices = [];

% Outer loop for positions in row 1
for col1 = 1:4
    % Place 1 in row 1
    matrix(1, col1) = 1;
    
    % Inner loop for positions in row 2
    for col2 = 1:4
        % Place 1 in row 2
        matrix(2, col2) = 1;
        
        % Check if row 2 is valid (exactly one 1 per row and column)
        if sum(matrix(2,:)) == 1 && sum(matrix(:,col2)) == 1
            % Inner loop for positions in row 3
            for col3 = 1:4
                % Place 1 in row 3
                matrix(3, col3) = 1;
                
                % Check if row 3 is valid
                if sum(matrix(3,:)) == 1 && sum(matrix(:,col3)) == 1
                    % Inner loop for positions in row 4
                    for col4 = 1:4
                        % Place 1 in row 4
                        matrix(4, col4) = 1;
                        
                        % Check if row 4 is valid
                        if sum(matrix(4,:)) == 1 && sum(matrix(:,col4)) == 1
                            % Add current matrix to the list of valid matrices
                            valid_mum = valid_mum + 1;
                            valid_matrices(:, :, valid_mum) = matrix;
                        end
                        
                        % Reset row 4
                        matrix(4, col4) = 0;
                    end
                end
                
                % Reset row 3
                matrix(3, col3) = 0;
            end
        end
        
        % Reset row 2
        matrix(2, col2) = 0;
    end
    
    % Reset row 1
    matrix(1, col1) = 0;
end

%%
% Initialize population
P = 10000 * ones(rad, tar, ssize) + unidrnd(10000, rad, tar, ssize);
for i = 1:24
    P1 = (10000 * ones(rad, tar, ssize) + unidrnd(10000, rad, tar, ssize)) .* valid_matrices(:,:,i);
    P = cat(3, P, P1);
end

% Compute corresponding array element matrix
a = sum(P, 2);
A = sumA .* P ./ a;  % update array element matrix from power matrix

P_min = 0;
P_max = 10000000;    % power constraint
A_min = 0;
A_max = sumA;        % aperture constraint

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
        fitness(i) = 1e10;  % large penalty for infeasible solutions
    end
end

% Initialize global optimum
Gpbest = [];
Gabest = [];
PPbestfit = inf;

% Record best fitness of each generation
record = zeros(MaxIt, 1);

%%
%%%%%%%%% GA main loop %%%%%%%%%
for gen = 1:MaxIt
    % Compute fitness of each individual
    for i = 1:Psize
        PDK1 = DP(P(:,:,i), A(:,:,i));
        res = (PDK1 >= 0.95);
        if length(find(res == 1)) == tar
            current_fit = sum(P(:,:,i), [1 2]);
            if current_fit < fitness(i)
                fitness(i) = current_fit;
            end
        else
            fitness(i) = 1e10;  % infeasible solution
        end
    end
    
    % Find the best solution of the current generation
    [min_fit, min_idx] = min(fitness);
    if min_fit < PPbestfit && min_fit < 1e9  % ensure feasible solution
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
    
    %%% Genetic operations %%%
    
    % 1. Selection operation
    new_pop = zeros(size(P));
    new_fitness = zeros(size(fitness));
    
    % Elitism
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
            % Roulette wheel selection
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
            
            % Select second parent
            r = rand();
            parent2_idx = find(cum_prob >= r, 1);
            parent2 = P(:,:,parent2_idx);
            
        else
            % Tournament selection
            % Select first parent
            tournament = randperm(Psize, tournament_size);
            [~, best_idx] = min(fitness(tournament));
            parent1 = P(:,:,tournament(best_idx));
            
            % Select second parent
            tournament = randperm(Psize, tournament_size);
            [~, best_idx] = min(fitness(tournament));
            parent2 = P(:,:,tournament(best_idx));
        end
        
        % 2. Crossover operation
        if rand() < pc
            % Arithmetic crossover
            alpha = rand(size(parent1));
            child = alpha .* parent1 + (1 - alpha) .* parent2;
        else
            child = parent1;  % No crossover, direct copy
        end
        
        % 3. Mutation operation
        for r = 1:rad
            for t = 1:tar
                if rand() < pm
                    % Gaussian mutation
                    mutation_strength = 0.1 * (P_max - P_min);
                    child(r,t) = child(r,t) + mutation_strength * randn();
                    
                    % Boundary handling
                    if child(r,t) > P_max
                        child(r,t) = P_max;
                    elseif child(r,t) < P_min
                        child(r,t) = P_min;
                    end
                end
            end
        end
        
        % Ensure at least one non-zero value per row
        for r = 1:rad
            if sum(child(r,:)) == 0
                random_tar = randi(tar);
                child(r, random_tar) = P_min + rand() * (P_max - P_min);
            end
        end
        
        new_pop(:,:,i) = child;
        
        % Compute array element matrix for the offspring
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
    
    % Update array element matrices for all individuals
    for i = 1:Psize
        a_i = sum(P(:,:,i), 2);
        A(:,:,i) = sumA .* P(:,:,i) ./ a_i;
    end
    
    % Plotting
    plot(record(1:gen));
    title('Evolution of Optimal Fitness in GA');
    xlabel('Iteration');
    ylabel('Total Power');
    grid on;
    pause(0.0001);
end

%%
% Output results
PDK3 = DP(Gpbest, Gabest);
disp('Optimal power allocation matrix:');
disp(Gpbest);
disp('Optimal array element allocation matrix:');
disp(Gabest);
disp(['Optimal total power: ', num2str(PPbestfit)]);
disp(['Final detection probability: ', num2str(PDK3)]);

% Plot final convergence curve
figure;
plot(record(1:gen));
title('GA Convergence Curve (k=1)');
xlabel('Iteration');
ylabel('Total Power');
grid on;

record1 = record(1:gen);
save('GA1_record.mat', 'record1');
toc;

%% Detection probability function (unchanged)
function DD = DP(P, A)
    rad = 4;
    Pfa = 10^(-8);          % false alarm probability
    L = 10^(0.5/10);        % system loss 
    k = 1.38*10^(-23);      % Boltzmann constant
    F = 10^(0.5/10);        % noise figure
    B = 0.5*10^6;           % bandwidth
    T = 290;                % system temperature
    lamda = repmat(0.04, 4, 4);
    sigma = [10 10 10 10
            10 10 10 10
            10 10 10 10
            10 10 10 10];
    
    Tx = [20, 30, 50, 60];
    Ty = [40, 40, 40, 40];
    Rx = [20, 30, 50, 60];
    Ry = [0, 0, 0, 0];
    
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