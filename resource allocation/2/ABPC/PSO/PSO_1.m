clc;
clear;
tic;
rng(5);
tar = 4;         % 4 targets  
rad = 4;         % 4 radars
Psize = 5000;    % population size
ssize = 200;     % single-start population size
% MaxIt = 1000;    % number of iterations
MaxIt = 1000;    % number of iterations
sumA = 10000;    % number of array elements per radar
c1 = 2;          % algorithm parameter
c2 = 2;          % algorithm parameter
wmax = 0.6;      % inertia weight
wmin = 0.2;      % inertia weight
PPbestfit = inf;

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

% Print all matrices that satisfy the condition
%disp(valid_matrices); 
%%
P = 20000 * ones(rad, tar, ssize) + unidrnd(20000, rad, tar, ssize);
for i = 1:24
    P1 = (20000 * ones(rad, tar, ssize) + unidrnd(20000, rad, tar, ssize)) .* valid_matrices(:,:,i);   % power matrix
    P = cat(3, P, P1);
end
a = sum(P, 2);
A = sumA .* P ./ a;       % update array element matrix from power matrix
v_min = -150;
v_max = 150;           % velocity limit for power particles
v = v_min + rand(rad, tar, ssize) * (v_max - v_min);
for i = 1:24
    v1 = (v_min + rand(rad, tar, ssize) * (v_max - v_min)) .* valid_matrices(:,:,i);
    v = cat(3, v, v1);
end
% v1_min = -100;
% v1_max = 100;          % velocity limit for aperture particles
% v1 = v1_min + rand(rad,tar,Psize)*(v1_max - v1_min);
P_min = 0;
P_max = 10000000000;         % power constraint
A_min = 0;
A_max = sumA;           % aperture constraint

%%
%%%%%%%%%% Initialize individual optimal positions and values %%%%%%%%%%%% 
ppbest = P;
pabest = A;
pfit = ones(Psize, 1);
for i = 1:Psize
    pfit(i) = sum(P(:,:,i), [1 2]);
end

%%
%%%%%%%%%% Initialize global optimal positions and values %%%%%%%%%%
gpbest = ones(rad, tar, 25);
gabest = ones(rad, tar, 25);
pbestfit = inf * ones(25, 1);
for i = 1:Psize
    PDK1 = DP(P(:,:,i), A(:,:,i));
    res = (PDK1 >= 0.95);
    if (length(find(res == 1)) == tar && pfit(i) < pbestfit(ceil(i/ssize), 1))
        gpbest(:,:,ceil(i/ssize)) = P(:,:,i);
        gabest(:,:,ceil(i/ssize)) = A(:,:,i);
        pbestfit(ceil(i/ssize), 1) = pfit(i);
    end
end

%%
%%%%%%%%%% Iteration loop %%%%%%%%%%
for i = 1:MaxIt
    %%%%%%%%%% Power %%%%%%%%%
    for j = 1:Psize
        PDK2 = DP(P(:,:,j), A(:,:,j));
        res = (PDK2 >= 0.95);
        %%%%%%%% Update individual optimal positions and values for power %%%%%%%
        if (length(find(res == 1)) == tar && sum(P(:,:,j), [1 2]) <= pfit(j))
            ppbest(:,:,j) = P(:,:,j);
            pabest(:,:,j) = A(:,:,j);
            pfit(j) = sum(P(:,:,j), [1 2]);
        end
        %%%%%%%% Update global optimal positions and values for power %%%%%%%
        if (length(find(res == 1)) == tar && pfit(j) <= pbestfit(ceil(j/ssize), 1))
            gpbest(:,:,ceil(j/ssize)) = P(:,:,j);
            gabest(:,:,ceil(j/ssize)) = A(:,:,j);
            pbestfit(ceil(j/ssize), 1) = pfit(j);
        end
        %%%%%%% Compute dynamic inertia weight %%%%%%%
        w = wmax - (wmax - wmin) * i / MaxIt;    %% weight update
        %%%%%% Update power position and velocity %%%%%%%
        v(:,:,j) = w * v(:,:,j) + c1 * rand(1) * (ppbest(:,:,j) - P(:,:,j)) + c2 * rand(1) * (gpbest(:,:,ceil(j/ssize)) - P(:,:,j));
        P(:,:,j) = P(:,:,j) + v(:,:,j);
%         v1(:,:,j) = w*v1(:,:,j) + c1*rand(1)*(pabest(:,:,j) - A(:,:,j))+c2*rand(1)*(gabest - A(:,:,j));
%         A(:,:,j) = A(:,:,j) + v1(:,:,j);
        %%%%% Boundary handling %%%%%%%
        for ii = 1:rad
            for jj = 1:tar
                if (v(ii, jj, j) > v_max)
                    v(ii, jj, j) = v_min + rand(1) * (v_max - v_min);
                end
                if (v(ii, jj, j) < v_min)
                    v(ii, jj, j) = v_min + rand(1) * (v_max - v_min);
                end
            end
        end
       
        for ii = 1:rad
            for jj = 1:tar
                if (P(ii, jj, j) > P_max)
                    P(ii, jj, j) = P_max;
                end
                if (P(ii, jj, j) < P_min)
                    P(ii, jj, j) = P_min;
                end
%                 if(v1(ii,jj,i) > v1_max || v1(ii,jj,i) < v1_min)
%                     v1(ii,jj,i) = rand*(v1_max-v1_min)+v1_min;
%                 end
            end
        end
        a = sum(P(:,:,j), 2);
        A(:,:,j) = sumA .* P(:,:,j) ./ a;
    end
    
    for mm = 1:25
        PP = sum(gpbest(:,:,mm), [1 2]);
        if PP < PPbestfit
            Gpbest = gpbest(:,:,mm);
            Gabest = gabest(:,:,mm);
            PPbestfit = PP;
        end
    end   
    record(i) = PPbestfit;
    if i > 1
        % Compute fitness change
        fitness_change = abs(record(i-1) - record(i));

        % Check if it is less than the convergence threshold
        if fitness_change < convergence_threshold
            convergence_count = convergence_count + 1;
        else
            convergence_count = 0;  % reset
        end

        % Terminate early when consecutive convergence condition is met
        if convergence_count >= max_convergence_count
            break;
        end
    end
    plot(record);
    title('Evolution of Optimal Fitness (k=1)')
    pause(0.0001) 
end

PDK3 = DP(Gpbest, Gabest);
disp('Optimal power allocation matrix:');
disp(Gpbest);
disp('Optimal array element allocation matrix:');
disp(Gabest);
disp(['Optimal total power: ', num2str(PPbestfit)]);
disp(['Final detection probability: ', num2str(PDK3)]);

save('case2_PSO1_record.mat', 'record');
toc;

% %% Compute the SNR matrix after optimization
% % Define SNR calculation parameters (same as in DP function)
% Pfa = 10^(-8);          % false alarm probability
% L = 10^(0.5/10);        % system loss 
% k = 1.38*10^(-23);      % Boltzmann constant
% F = 10^(0.5/10);        % noise figure
% B = 0.5*10^6;           % bandwidth
% T = 290;                % system temperature
% lamda = repmat(0.04,4,4);
% sigma = [10 10 10 10
%         10 10 10 10
%         10 10 10 10
%         10 10 10 10];
% Tx=[-10,20,40,70];
% Ty=[40,70,40,60];
% Rx=[10,20,25,40];
% Ry=[0,20,5,0];
% 
% % Compute distance matrix
% R = zeros(4,4);
% for i=1:4
%     for j=1:4
%         R(i,j)=((Tx(j)-Rx(i)).^2+(Ty(j)-Ry(i)).^2)^0.5;    
%     end
% end
% 
% % Compute SNR using the optimal solution
% SNR_optimal = (10000*Gpbest.*Gabest.*lamda.^2.*sigma)./(4^3*pi^3*L*k*F*B*T.*R.^4.*10^12);
% 
% % Output SNR matrix
% disp('Optimized SNR matrix:');
% disp(SNR_optimal);
% 
% % Output average SNR for each radar-target pair
% disp('SNR statistics for each radar-target pair:');
% for i=1:rad
%     for j=1:tar
%         fprintf('Radar %d to Target %d SNR: %.4f dB\n', i, j, 10*log10(SNR_optimal(i,j)));
%     end
% end
%%
%%%%%%% Rank-K fusion detection probability %%%%%%%%
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
    Tx = [-10, 20, 40, 70];
    Ty = [40, 70, 40, 60];
    % z=[20,20,20,20];
    Rx = [10, 20, 25, 40];
    Ry = [0, 20, 5, 0];
    for i = 1:4
        for j = 1:4
            R(i, j) = ((Tx(j) - Rx(i)).^2 + (Ty(j) - Ry(i)).^2)^0.5;    
        end
    end
    SNR = (10000 * P .* A .* lamda.^2 .* sigma) ./ (4^3 * pi^3 * L * k * F * B * T .* R.^4 .* 10^12);   % SNR
    PD = 0.5 .* erfc(((-log(Pfa))^0.5 - (0.5 + SNR).^0.5));                    % detection probability of each single radar for each target
    nsize = 4;
    n = 2^nsize;               % number of rows in the matrix
    W = zeros(n, nsize);       % matrix to store results
    for m = 1:n                % generate binary ordered matrix
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
    DD = sum(b, 1);         % detection probability of the networked radar after rank-K fusion for each target         
end