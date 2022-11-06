function [q,hc,P,ht,h] = Simulator(ht00,hr,K,N,S,df)
%UNTITLED Summary of this function goes here
%  Extended period simulator over 24 hours

global R1 R2 R3 R4 A B C At nc nf e Lc Lf hr et x_min x_max gp hp d  T time

%%% Time Loop]]

ht(1)=ht00;
htt=ht(1);
x0=[0 0 0 30  -30 210 210 232 232];
P=[0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0];

for k=1:K
n=N(k);
s=S(k);
dk=df*d(k);

   x=fsolve(@(x)Hydraulics(x,n,s,dk,hr,htt),x0);
    q(:,k)=x(1:e);
    hc(:,k)=x(e+1:e+nc);
    P(k)=(gp*q(2,k)*S(k)^2+hp*N(k)*S(k)^3)*T(k);
    ht(k+1)=ht(k)+(1/At)*q(4,k);
    h(:,k)=[hc(:,k);hr;ht(k)];
    htt=ht(k+1);
    
end

end
    


