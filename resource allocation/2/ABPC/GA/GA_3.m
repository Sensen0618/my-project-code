clc;
clear;
tic;
rng(1);
tar = 4;         % 4 targets  
rad = 4;         % 4 radars
Psize = 5000;    % population size
ssize = 200;     % single-start population size
MaxIt = 1200;    % maximum number of iterations
sumA = 10000;    % number of array elements per radar

%% GA parameters
pc = 0.8;        % crossover probability
pm = 0.15;       % mutation probability
elite_rate = 0.1; % elite retention ratio
selection_method = 'tournament'; % selection method
tournament_size = 3; % tournament selection size

convergence_threshold = 1e-6;  % convergence threshold
convergence_count = 0;         % convergence counter
max_convergence_count = 50;    % maximum consecutive convergence count

%% Generate all matrices satisfying the condition (exactly three 1s per row and per column)
matrix = zeros(4);
valid_mum = 0;
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

% Invert to obtain matrices with exactly three 1s per row and per column
valid_matrices = 1 - valid_matrices;

%%
% Initialize population
P = 20000 * ones(rad, tar, ssize) + unidrnd(20000, rad, tar, ssize);
for i = 1:24
    P1 = (20000 * ones(rad, tar, ssize) + unidrnd(20000, rad, tar, ssize)) .* valid_matrices(:,:,i);
    P = cat(3, P, P1);
end

% Compute corresponding array element matrix
a = sum(P, 2);
A = sumA .* P ./ a;

P_min = 0;
P_max = 40000000;    % power constraint
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

% Store the valid matrix index for each individual
matrix_indices = zeros(Psize, 1);
for i = 1:Psize
    % Obtain the valid matrix index of the current individual
    non_zero_pattern = (P(:,:,i) > 0);
    for m = 1:24
        if isequal(non_zero_pattern, valid_matrices(:,:,m))
            matrix_indices(i) = m;
            break;
        end
    end
    if matrix_indices(i) == 0
        matrix_indices(i) = randi(24); % if no match, assign randomly
    end
end

%% GA main loop
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
    
    %% Genetic operations
    new_pop = zeros(size(P));
    new_matrix_indices = zeros(size(matrix_indices));
    new_fitness = zeros(size(fitness));
    
    % Elitism
    elite_num = round(elite_rate * Psize);
    [sorted_fit, sorted_idx] = sort(fitness);
    elite_indices = sorted_idx(1:elite_num);
    
    for i = 1:elite_num
        new_pop(:,:,i) = P(:,:,elite_indices(i));
        new_matrix_indices(i) = matrix_indices(elite_indices(i));
        new_fitness(i) = fitness(elite_indices(i));
    end
    
    % Generate remaining individuals
    for i = (elite_num+1):Psize
        % Selection operation
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
            parent1_idx = find(cum_prob >= r, 1);
            
            % Select second parent
            r = rand();
            parent2_idx = find(cum_prob >= r, 1);
            
        else
            % Tournament selection
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
        
        % Crossover operation
        if rand() < pc
            % Arithmetic crossover when parents have the same structure
            if idx1 == idx2
                alpha = rand(size(parent1));
                child = alpha .* parent1 + (1 - alpha) .* parent2;
                new_idx = idx1;
            else
                % If structures differ, randomly select one structure
                if rand() < 0.5
                    child = parent1;
                    new_idx = idx1;
                else
                    child = parent2;
                    new_idx = idx2;
                end
            end
        else
            % No crossover, directly copy the first parent
            child = parent1;
            new_idx = idx1;
        end
        
        % Mutation operation
        if rand() < pm
            % Structure mutation: randomly change the valid matrix (maintain three 1s per row/column)
            if rand() < 0.3  % 30% probability to change structure
                new_idx = randi(24);
                pattern = valid_matrices(:,:,new_idx);
                
                % Create a new power matrix, maintaining exactly three non-zero values per row and column
                child = zeros(rad, tar);
                [row_idx, col_idx] = find(pattern);
                for k = 1:length(row_idx)
                    child(row_idx(k), col_idx(k)) = P_min + rand() * (P_max - P_min);
                end
            else
                % Value mutation: preserve structure, only change power values
                pattern = valid_matrices(:,:,new_idx);
                [row_idx, col_idx] = find(pattern);
                for k = 1:length(row_idx)
                    if rand() < 0.2  % 20% probability for each non-zero position to mutate
                        mutation_strength = 0.2 * (P_max - P_min);
                        child(row_idx(k), col_idx(k)) = child(row_idx(k), col_idx(k)) + ...
                            mutation_strength * randn();
                        
                        % Boundary handling
                        if child(row_idx(k), col_idx(k)) > P_max
                            child(row_idx(k), col_idx(k)) = P_max;
                        elseif child(row_idx(k), col_idx(k)) < P_min
                            child(row_idx(k), col_idx(k)) = P_min;
                        end
                    end
                end
            end
        end
        
        % Ensure each row has exactly three non-zero values (constraint of three ones per row)
        pattern = valid_matrices(:,:,new_idx);
        child = child .* pattern;  % ensure only specified positions have values
        
        % Store new individual
        new_pop(:,:,i) = child;
        new_matrix_indices(i) = new_idx;
        
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
    matrix_indices = new_matrix_indices;
    fitness = new_fitness;
    
    % Update array element matrices for all individuals
    for i = 1:Psize
        a_i = sum(P(:,:,i), 2);
        A(:,:,i) = sumA .* P(:,:,i) ./ a_i;
    end
    
    % Plotting
    plot(record(1:gen));
    title('Evolution of Optimal Fitness in GA (k=3)');
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
title('GA Convergence Curve (k=3)');
xlabel('Iteration');
ylabel('Total Power');
grid on;

record3 = record(1:gen);
save('case2_GA3_record.mat', 'record3');
toc;

%% Detection probability function (k=3 version)
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
    
    K = 3;  % rank-K fusion, K=3
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