clc;
clear;
tic;
rng(1);
tar = 4;         % 4 targets  
rad = 4;         % 4 radars
Psize = 5000;    % population size
MaxIt = 2500;    % maximum number of iterations
sumA = 10000;    % number of array elements per radar
c1 = 1.5;        % algorithm parameter
c2 = 1.5;        % algorithm parameter
wmax = 1.2;      % inertia weight
wmin = 0.8;      % inertia weight

convergence_threshold = 1e-6;  % convergence threshold
convergence_count = 0;         % convergence counter
max_convergence_count = 50;    % maximum consecutive convergence count

P = 30000*ones(rad,tar,Psize)+unidrnd(30000,rad,tar,Psize);%.*[1 0 0 1;0 1 1 0;0 0 1 1;1 1 0 0];    % power matrix
a = sum(P,2);
A = sumA.*P./a;       % update array element matrix from power matrix
v_min = -200;
v_max = 200;           % velocity limit for power particles
v = v_min + rand(rad,tar,Psize)*(v_max - v_min);%.*[1 0 0 1;0 1 1 0;0 0 1 1;1 1 0 0];

P_min = 0;
P_max = 80000000;         % power constraint
A_min = 0;
A_max = sumA;           % aperture constraint
%%%%%%%%%% Initialize individual optimal positions and values %%%%%%%%%%%% 
ppbest = P;
pabest = A;
pfit = ones(Psize,1);
for i=1:Psize
    pfit(i)= sum(P(:,:,i),[1 2]);
end
%%%%%%%%% Initialize global optimal positions and values %%%%%%%%%%
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
%%%%%%%%% Iteration loop %%%%%%%%%%
for i=1:MaxIt
%%%%%%%%% Power %%%%%%%%%
    for j = 1:Psize
        PDK2 = DP(P(:,:,j),A(:,:,j));
        res=(PDK2>=0.95);
        %%%%%%%% Update individual optimal positions and values for power %%%%%%%
        if (length(find(res==1))==tar && sum(P(:,:,j),[1 2])<pfit(j))
            ppbest(:,:,j) = P(:,:,j);
            pabest(:,:,j) = A(:,:,j);
            pfit(j) = sum(P(:,:,j),[1 2]);
        end
        %%%%%%%% Update global optimal positions and values for power %%%%%%%
        if (length(find(res==1))==tar && pfit(j)<pbestfit)
            gpbest = P(:,:,j);
            gabest = A(:,:,j);
            pbestfit = pfit(j);
            PDK3 = DP(gpbest,gabest);
        end
        %%%%%%% Compute dynamic inertia weight %%%%%%%
        w=wmax-(wmax-wmin)*i/MaxIt;    %% weight update
        %%%%%% Update power position and velocity %%%%%%%
        v(:,:,j) = w*v(:,:,j) + c1*rand(1)*(ppbest(:,:,j) - P(:,:,j))+c2*rand(1)*(gpbest - P(:,:,j));
       P(:,:,j) = P(:,:,j) + v(:,:,j);
%         v1(:,:,j) = w*v1(:,:,j) + c1*rand(1)*(pabest(:,:,j) - A(:,:,j))+c2*rand(1)*(gabest - A(:,:,j));
%         A(:,:,j) = A(:,:,j) + v1(:,:,j);
        %%%%% Boundary handling %%%%%%%
        for ii=1:rad
            for jj=1:tar
                if(v(ii,jj,j) > v_max)
                    v(ii,jj,j) = v_max;
                end
                if(v(ii,jj,j) < v_min)
                    v(ii,jj,j) = v_min;
                end
            end
        end
         
         for ii=1:rad
            for jj=1:tar
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
        
        a = sum(P(:,:,j),2);
        A(:,:,j) = sumA.*P(:,:,j)./a;
    end
    record(i) = pbestfit;
    if i>1
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
    title('Evolution of Optimal Fitness (k=4)')
     pause(0.0001) 
end

PDK3 = DP(gpbest,gabest);
disp('Optimal power allocation matrix:');
disp(gpbest);
disp('Optimal array element allocation matrix:');
disp(gabest);
disp(['Optimal total power: ',num2str(pbestfit)]);
disp(['Final detection probability: ', num2str(PDK3)]);
toc;

%%%%%%% Rank-K fusion detection probability %%%%%%%%
function DD = DP(P,A)
rad=4;
Pfa = 10^(-8);          % false alarm probability
L = 10^(0.5/10);        % system loss 
k = 1.38*10^(-23);      % Boltzmann constant
F = 10^(0.5/10);        % noise figure
B = 0.5*10^6;           % bandwidth
T = 290;                % system temperature
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
SNR = (10000*P.*A.*lamda.^2.*sigma)./(4^3*pi^3*L*k*F*B*T.*R.^4.*10^12);   % SNR
PD = 0.5.*erfc(((-log(Pfa))^0.5-(0.5+SNR).^0.5));                    % detection probability of each single radar for each target
nsize=4;
n=2^nsize;               % number of rows in the matrix
W=zeros(n,nsize);        % matrix to store results
     for m = 1:n              % generate binary ordered matrix
      W(m,:) = bitget(m-1,nsize:-1:1); 
     end
K = 4;
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
 DD = sum(b,1); % detection probability of the networked radar after rank-K fusion for each target         
end
% save('PSO4_record.mat', 'record');