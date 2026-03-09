clc
clear all
Tx=[20,30,50,60];
Ty=[40,40,40,40];
%z=[20,20,20,20];
Rx=[20,30,50,60];
Ry=[0,0,0,0];
for i=1:4
    for j=1:4
    RN(i,j)=findAngle(Rx(i), Ry(i), Tx(j), Ty(j));    
    end
end
for i=1:4
    for j=1:4
    R(i,j)=((Tx(j)-Rx(i)).^2+(Ty(j)-Ry(i)).^2)^0.5;    
    end
end
RR=reshape(R,[1 16])';

qqqq=var(RR);
function [angle] = findAngle(x1, y1, x2, y2)
  dy = (y2-y1);
  dx = (x2-x1);
  if(x2>=x1)
    angle = 90 - atand(dy/dx);
  elseif(x2<x1) 
    angle = -90 - atand(dy/dx); 
  end
end

