%%%%%%%%%%%%%%%%
%% Initialise data for the Simulator
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
delta_t = 1; % time step (hrs)
% DISCRETIZATION SETTINGS
NO_PIPE_SEGMENTS = 3;
NO_PUMP_SEGMENTS = 4;

%% GENERAL
time=1:1:TIME_HORIZON;
g=9.81;

elevations = [210, 210, 220, 220, 230, 210]; % node elevations

% Create a tank structure
tank.elevation = elevations(5);
tank.diameter = 15;
tank.area = pi*tank.diameter^2/4.0;
tank.x_min = 0.5;
tank.x_max = 3.5;

% TEST

% RESERVOIR
hr = 210; % reservoir head, m

%%% PUMP hydraulic
% Currently only one type of pump is used. Later expand to multiple different
% pumps
pump.A = -0.0045;
pump.B = 0;
pump.C = 45;
% Pump energy consumption:
% P(q,s) = ep * q^3 + fp * q^2 * s + gp * q * s^2 + hp * s^3 
% where n is the number of pumps switched on and operating in parallel and s
% is the pump speed.
pump.ep = 0.0;
pump.fp = 0.0;
pump.gp = 0.2422;
pump.hp = 40;
pump.smin = 0.7;
pump.smax = 1.2;
pump.max_eff_flow = 45;

network.npg = 1; % number of pump groups
% In a more general case number of pumps per group would be a vector of length
% equal to network.npg
network.nt = 1; % number of tanks
network.nr = 1; % number of reservoirs
network.np = 2; % number of pumps per pump group
network.npipes = 4;
% Number of elements is equal to number of pipes + number of pump groups
network.ne = network.npipes + network.npg; % number of pipes (elements) Is e2 and e3 treated as one?
network.nc = 4; % number of calculated nodes
network.nf = 2; % number of fixed head nodes
% TODO: Make this part generic. Currently it is assumed that each pump group 
% has the same number of pumps (per pump group). Vectorise the variables to
% allow having different number of pumps in every pump group
network.npumps = network.np * network.npg;

% FUTURE VARIABLES
network.ncheck = 0; % number of check valves
network.nprv = 0; % number of PRVs
 
%% INITIALISATION
% Initial pump schedules
init_schedule.N = [2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 0 0 0 2 2 2 2 2 2];
init_schedule.S = 0.8 * ones(1, TIME_HORIZON);
% Initial tank head
init_level = 3.0;
if ((init_level < tank.x_min) || (init_level > tank.x_max))
  error('Initial tank level not within bounds')
end
ht0 = tank.elevation + init_level; % make sure that x_min <= init_level <= x_max

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
% Combined incidence matrix for calculated and non-calculated connection nodes
network.L = [network.Lc; network.Lf];
% Pipe resistances
network.R = 10^-6*fDW.*L_pipe./(2*g*D_pipe.*A_pipe.^2);
network.tank = tank;
network.tank_feed_pipe_index = 4;
% In a more general case, network.pump_pipe_index will be a vector of length
% equal to network.npg
network.pump_pipe_index = 2;


% Indices of variables within matrices and vectors
% TODO: SORT OUT THE INDEX INCONSISTENCY RESULTING FROM TWO ELEMENTS
% ASSOCIATED WITH PUMP GROUP BUT ONLY ONE PUMP GIVEN IN THE MODEL
network.pipe_index=[1;3;4;5]; % Pipe flow index for the simulator results
network.pump_index=[2;3];
% Indices of calculated nodes, reservoir nodes and tank nodes, respectively
network.hc_index=[1;2;3;4]; % Row number in network.L matrix
network.hr_index=[5]; % Row number in network.L matrix
network.ht_index=[6]; % Row number in network.L matrix