close all   % close all windows
clear       % clear workspace
clc         % clear command window
f=300e6;    %carrier frequency (Hz)
n=100;       %number of array elements
l=0.04*3e8/f;    %wave length (m)
sa=361;     %sampling
d=l/2;
p=zeros(sqrt(n),sqrt(n));
for i=1:sqrt(n)
    p(i,:) =0:d:d*(sqrt(n)-1);
end
p=reshape(p',n,1);
angle=[-90,90];
angle_m=[-20,20];
angle_n=[-60 60];
Rat=[1 sqrt(9) 0 0]'; %ratio
s_m=size(angle_m,2);
theta_list = linspace(angle(1, 1), angle(1, 2), 361);
steering_matrixe=exp(1j*p*2*pi/l*sin(theta_list*pi/180));
m_steering=exp(1j*p*2*pi/l*sin(angle_m*pi/180));
n_steering=exp(1j*p*2*pi/l*sin(angle_n*pi/180));
R=[m_steering n_steering] * [m_steering n_steering]';
R_inv = pinv(R);
C=[m_steering n_steering];
w=R_inv*C/(C'*R_inv*C)*Rat;
bp = zeros(1, sa);
  for it = 1:sa
      a = steering_matrixe(:, it);
      bp(1, it) = abs(w' * a);
  end
  % Normalize.
 bp = 20 * log10(bp / max(bp));

 gain_m = zeros(1, s_m);
    for i = 1:s_m
      gain_m(i) = abs(w' * (m_steering(:, i)*m_steering(:, i)')* w) / abs(w'*w);
    end

plot(theta_list,bp);
delta = (angle(1, 2) - angle(1, 1)) / 6;
set(gca, 'xlim',[angle(1,1)-10, angle(1, 2)+10]);
set(gca, 'xtick',angle(1, 1):delta: angle(1, 2));    
xlabel('Azimuth Angle (deg)');
ylabel('Normalized Beam Pattern (dB)');
set(gca, 'YLim', [-50, 0]);