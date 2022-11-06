function y= Hydraulics(x,n,s,dk,hr,htt)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

global R1 R2 R3 R4 A B C At nc nf e Lc Lf hr et x_min x_max gp hp d  T time

qh=x(1:e);
hch=x(e+1:e+nc);
hf(1)=hr;
hf(2)=htt;
y=[0;0;0;0;0;0;0;0;0];

y(1:nc)=Lc*qh.';
y(nc)=y(nc)-dk;

R(1)=R1*qh(1)*abs(qh(1));
R(2)=(A*qh(2)^2+B*qh(2)*n*s+C*n^2*s^2);
R(3)=R2*qh(3)*abs(qh(3));
R(4)=R3*qh(4)*abs(qh(4));
R(5)=R4*qh(5)*abs(qh(5));

y(nc+1:nc+e)=R.'+Lc.'*hch.'+Lf.'*hf.';
y(nc+2)=y(nc+2)-n^2*(hch(2)-hch(1))-(hch(2)-hch(1));
end

