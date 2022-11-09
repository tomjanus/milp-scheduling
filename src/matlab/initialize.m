%%%%%%%%%%%%%%%%
%% Intilise data for the Simulator
% Represents input data for simulating the network with the schematic
% given below:
% n - node; e - element, p - pump, r - reservoir, d - demand
%
%                                     n5 (tank)
%                                     |
%                                     |    (p4)
%                                    (e5)
%(r) (p1)         (p2)         (p3)   |          (d)
%n1 ------ n2 ----(e2)----n3---(e4)---n4---(e6)---n6
%           |             |                (p5)
%          nc1----(e3)----nc2

TIME_HORIZON = 24; % Schedule performed over 24 hours

%global R1 R2 R3 R4 Ap Bp Cp At nc nf e Lc Lf hr et x_min x_max gp hp d  T time

%% GENERAL
time=1:1:TIME_HORIZON;
g=9.81;

elevations = [210, 210, 220, 220, 230, 210]; % node elevations

%% TANK
et=elevations(5);
Dt=15;
At=pi*Dt^2/4.0;
x_min=0.5;
x_max=3.5;

% RESERVOIR
hr=210; % reservoir head, m

%%% PUMP hydraulic
pump.A=-0.0045;
pump.B=0;
pump.C=45;
% Pump energy consumption P(q,s) = gp * q * s^2 + hp * n * s^3 where n is the
% number of pumps switched on and operating in parallel
pump.gp=0.2422;
pump.hp=40;
 
%% INITIALISATION
% Initial pump schedules
init_schedule.N = [2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 0 0 0 2 2 2 2 2 2];
init_schedule.S = 0.8 * ones(1, TIME_HORIZON);
% Initial tank head
ht0=233;

%% Create the input structure
% A 24x1 vector of tariffs
tariff = [0.072490, 0.072490, 0.072490, 0.072490, 0.072490, 0.072490, ...
    0.072490, 0.087490, 0.087490, 0.087490, 0.087490, 0.087490, 0.087490, ...
    0.087490, 0.087490, 0.15195, 0.15195, 0.15195, 0.084340, 0.084340, ...
    0.084340, 0.084340, 0.084340, 0.084340];

% A 24x1 vector of demands
demand = [0.72, 0.59, 0.53, 0.47, 0.51, 0.55, 1.1, 1.53,	1.51, 1.34, 1.3, ...
    1.3, 1.24,	1.24, 1.17, 1.14, 1.06, 1.121, 1.15, 1.31, 1.24,	1.21, ...
    1.13, 1.14];
DEMAND_MULTIPLIER = 40;
input.demand = demand * DEMAND_MULTIPLIER;
input.tariff = tariff;
input.df = 1;
input.hr = hr;

%% Create the network structure
% -------------------------------
% (4 pipes: n1-n2; n3-n4; n4-n5; n5-n6) 
L_pipe = [10, 1610, 61, 1610];
D_pipe = [1, 0.355, 0.458, 0.254];
% Calculate pipe areas
A_pipe = pi*D_pipe.^2/4;
% Darcy-Weisbach coefficients
fDW = [0.015, 0.015, 0.015, 0.015];

% Network topology
% node-element incidence matrix for the (calculated) connection nodes 
network.Lc = [1 -1 0 0 0;...
    0 1 -1 0 0;...
    0 0 1 -1 -1;...
    0 0 0 0 1];
% node-element incidence matrix for the fixed (non-calculated) connection nodes 
network.Lf=[-1 0 0 0 0;...
    0 0 0 1 0];
% Pipe resistances
network.R = 10^-6*fDW.*L_pipe./(2*g*D_pipe.*A_pipe.^2);
network.At = At; % Tank area
network.tank_feed_pipe_index = 4;
network.pump_pipe_index = 2;
network.ne = 5; % number of pipes (elements)
network.nc = 4; % number of calculated nodes
network.nf = 2; % number of fixed head nodes
