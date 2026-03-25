clc;
clear;
tic;
rng(1);
tar = 4;         % target  
rad = 4;         % radar
Psize = 5000;    % Number of populations
% Psize = 18200;
MaxIt = 1200;    % iteration count
sumA = 10000;    % Number of elements per radar array
% c1 = 1.5;        
% c2 = 1.5;        % algorithm parameters
% wmax = 1.2;      
% wmin = 0.8;      % Inertia factor
c1 = 2;          
c2 = 2;         
wmax = 0.6;     
wmin = 0.2;      % (k=1,3)
% c1 = 2;          
% c2 = 2;          
% wmax = 1.2;      
% wmin = 0.2;        % (k=2)

convergence_threshold = 1e-6;  % convergence threshold
convergence_count = 0;         % Convergence counter
max_convergence_count = 50;    % Continuous convergence threshold

P = (50000*ones(rad,tar,Psize)+unidrnd(50000,rad,tar,Psize)).*[1 1 1 0;1 1 0 1;1 0 1 1;0 1 1 1];    % Power matrix
% a = sum(P,2);
A =[3333.33 3333.33 3333.33 3333.33]'.*ones(4,4,Psize).*[1 1 1 0;1 1 0 1;1 0 1 1;0 1 1 1];        % Update the element matrix from the power matrix
% v_min = -200;
% v_max = 200;           % Speed limit of power particles
v_min = -120;
v_max = 120;
v = (v_min + rand(rad,tar,Psize)*(v_max - v_min)).*[1 1 1 0;1 1 0 1;1 0 1 1;0 1 1 1];
% v1_min = -100;
% v1_max = 100;          % Velocity limitation of aperture particles
% v1 = v1_min + rand(rad,tar,Psize)*(v1_max - v1_min);
P_min = 0;
% P_max = 90000000000;         % Power constraint
P_max = 10000000; 
A_min = 0;
A_max = sumA;           % Aperture constraint
%%%%% Initialize individual optimal position and optimal value %%%%%% 
ppbest = P;
pabest = A;
pfit = ones(Psize,1);
for i=1:Psize
    pfit(i)= sum(P(:,:,i),[1 2]);
end
%%%% Initialize the global optimal position and optimal value %%%%
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
%%%%% iterative loop %%%%%
for i=1:MaxIt

    for j = 1:Psize
        PDK2 = DP(P(:,:,j),A(:,:,j));
        res=(PDK2>=0.95);
        % Update the optimal position and value of individual power
        if (length(find(res==1))==tar && sum(P(:,:,j),[1 2])<pfit(j))
            ppbest(:,:,j) = P(:,:,j);
            pabest(:,:,j) = A(:,:,j);
            pfit(j) = sum(P(:,:,j),[1 2]);
        end
        % Update the global optimal position and optimal value of power
        if (length(find(res==1))==tar && pfit(j)<pbestfit)
            gpbest = P(:,:,j);
            gabest = A(:,:,j);
            pbestfit = pfit(j);
            PDK3 = DP(gpbest,gabest);
        end
        % Calculate the dynamic inertia weight value
        w=wmax-(wmax-wmin)*i/MaxIt;    % Weight update
        % Update power position and speed values
        v(:,:,j) = w*v(:,:,j) + c1*rand(1)*(ppbest(:,:,j) - P(:,:,j))+c2*rand(1)*(gpbest - P(:,:,j));
        P(:,:,j) = P(:,:,j) + v(:,:,j);
%         v1(:,:,j) = w*v1(:,:,j) + c1*rand(1)*(pabest(:,:,j) - A(:,:,j))+c2*rand(1)*(gabest - A(:,:,j));
%         A(:,:,j) = A(:,:,j) + v1(:,:,j);

        % Boundary condition processing
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
        % Calculate fitness changes
        fitness_change = abs(record(i-1) - record(i));

        % Determine if it is less than the convergence threshold
        if fitness_change < convergence_threshold
            convergence_count = convergence_count + 1;
        else
            convergence_count = 0;  % reset
        end

        % End prematurely when reaching the continuous convergence condition
        if convergence_count >= max_convergence_count
            break;
        end
    end
    plot(record);
    title('Optimal fitness evolution process')
     pause(0.0001) 
end
PDK4 = DP(gpbest,gabest);
 ptotal=sum(gpbest,'all');
 aaaa=sum(gpbest./gabest,1);
disp(gpbest);
disp(gabest);
disp(['Optimal value of total power：',num2str(pbestfit)]);
disp(aaaa(1))
toc;

% Rank K fusion detection probability
function DD = DP(P,A)
rad=4;
Pfa = 10^(-8);          % False alarm probability
L = 10^(0.5/10);        % System loss 
k = 1.38*10^(-23);      % Boltzmann constant
F = 10^(0.5/10);        % Noise Figure
B = 0.5*10^6;           % Spectrum width
T = 290;                % system temperature
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
SNR = (10000*P.*A.*lamda.^2.*sigma)./(4^3*pi.^3*L*k*F*B*T.*R.^4.*10^12);   % signal-to-noise ratio
PD = 0.5.*erfc(((-log(Pfa))^0.5-(0.5+SNR).^0.5));  % The detection probability of each individual radar for each target
nsize=4;
n=2^nsize;               % number of rows in the matrix
W=zeros(n,nsize);        % Generate result matrix
     for m = 1:n              % The generation of binary ordered matrices
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
 DD = sum(b,1); % The detection probability of each target by the networked radar after rank k fusion         
end