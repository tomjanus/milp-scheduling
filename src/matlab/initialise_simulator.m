%%%%%%%%%%%%%%%%
%% Intilise data for Simulator

% Create a 24x1 vector of tariffs
tariff = [0.072490, 0.072490, 0.072490, 0.072490, 0.072490, 0.072490, 0.072490, ...
 	  0.087490, 0.087490, 0.087490, 0.087490, 0.087490, 0.087490, 0.087490, ...
	  0.087490, 0.15195, 0.15195, 0.15195, 0.084340, 0.084340, 0.084340, ...
          0.084340, 0.084340, 0.084340];

% Create a 24x1 vector of demands
demand = [0.72, 0.59, 0.53, 0.47, 0.51, 0.55, 1.1, 1.53,	1.51, 1.34, 1.3, 1.3, ...
	  1.24,	1.24, 1.17, 1.14, 1.06, 1.121, 1.15, 1.31, 1.24,	1.21, 1.13, 1.14];

global R1 R2 R3 R4 A B C At nc nf e Lc Lf hr et x_min x_max gp hp d  T time

%% GENERAL
time=1:1:24;

g=9.81;


%Reservoir
hr=210;

%% TANK

et=230;
Dt=15;
At=pi*Dt^2/4.0;
x_min=0.5;
x_max=3.5;

%% PIPES
L1=10;
D1=1;

L2=1610;
D2=0.355;

L3=61;
D3=0.458;

L4=1610;
D4=0.254;

A1=pi*D1^2/4;
A2=pi*D2^2/4;
A3=pi*D3^2/4;;
A4=pi*D4^2/4;

fDW1=0.015;
fDW2=0.015;
fDW3=0.015;
fDW4=0.015;

R1=10^-6*fDW1*L1/(2*g*D1*A1^2);
R2=10^-5*fDW2*L2/(2*g*D2*A2^2);
R3=10^-6*fDW3*L3/(2*g*D3*A3^2);
R4=10^-6*fDW4*L4/(2*g*D4*A4^2);
R_pipe=[R1;R2;R3;R4];


%% NODES
nc=4;
nf=2;
e=5;
e_n1=210;
e_n2=210;
e_n3=220;
e_n4=220;
e_n5=230;
e_n6=210;

%%% PUMP hydraulic
A=-0.0045;
B=0;
C=45;

%%% Pump energy consumptionP(q,s)=g*q*s62+h*s^3
gp=0.2422;
hp=40;

%% TARIFF T is in the T vector in the workspace
T=tariff;
%% Demand  
d=40*demand;
df=1;
 
%% TOPOLOGY
nc=4;
nf=2;
e=5;
Lc=[1 -1 0 0 0;...
    0 1 -1 0 0;...
    0 0 1 -1 -1;...
    0 0 0 0 1];
Lf=[-1 0 0 0 0;...
    0 0 0 1 0];
  
%% INITIALISATION
N0=[2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 0 0 0 2 2 2 2 2 2];
S0=[0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8];
ht00=233;
 
d=40*demand;
T=tariff(1:24);
    
    







