function [input,const,linprog,network,sim] = initialise_2p1t()
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

  % Initializes the following data structures
  % linprog
  % sim
  % network
  % input 
  % constants
  
  % TODO: Remove redundancy in data - e.g remove tank_feed_pipe index as it is
  % alredy included in the tank structure and pump_group_index as it is already
  % included in the pump structure
  
  %% Define network characteristics required for defining the data structures
  elevations = [210, 210, 220, 220, 230, 210]; % node elevations
  hr = 210; % reservoir head, m
  nt = 1; % number of tanks
  nr = 1; % number of reservoirs
  % Initial tank heads
  init_tank_levels = [3.0];
  % -------------------------------
  % (4 pipes: n1-n2; n3-n4; n4-n5; n5-n6)
  L_pipe = [10, 1610, 61, 1610];
  D_pipe = [1, 0.355, 0.458, 0.254];
  % Calculate pipe areas
  A_pipe = pi*D_pipe.^2/4;
  % Darcy-Weisbach coefficients
  fDW = [0.015, 0.015, 0.015, 0.015];
  DEMAND_MULTIPLIER = 40;
  
  % CONSTANTS
  const.g = 9.81;
  
  %% SIMULATION SETTINGS
  sim.TIME_HORIZON = 24; % Schedule performed over 24 hours
  sim.delta_t = 1; % time step (hrs)
  sim.time = 1:1:sim.TIME_HORIZON;
  
  %% DISCRETIZATION SETTINGS
  linprog.NO_PIPE_SEGMENTS = 3;
  linprog.NO_PUMP_SEGMENTS = 4;
  linprog.NO_PRED_STEPS = 24; % Prediction horizon
  liprog.TIME_STEP = 1;
  
  %% NETWORK STRUCTURE AND NETWORK COMPONENTS
  % 1 PUMPS
  %%% PUMP hydraulic
  % Currently only one type of pump is used. Later expand to multiple different
  % pumps
  pump1.A = -0.0045;
  pump1.B = 0;
  pump1.C = 45;
  % Pump energy consumption:
  % P(q,s) = ep * q^3 + fp * q^2 * s + gp * q * s^2 + hp * s^3
  % where n is the number of pumps switched on and operating in parallel and s
  % is the pump speed.
  pump1.ep = 0.0;
  pump1.fp = 0.0;
  pump1.gp = 0.2422;
  pump1.hp = 40;
  pump1.smin = 0.7;
  pump1.smax = 1.2;
  pump1.max_eff_flow = 45;
  pump_groups(1).pump = pump1;
  pump_groups(1).npumps = 2;
  pump_groups(1).element_index = 2;
  
  % 2. TANKS
  tank1.elevation = elevations(5);
  tank1.diameter = 15;
  tank1.area = pi*tank1.diameter^2/4.0;
  tank1.x_min = 0.5;
  tank1.x_max = 3.5;
  tank1.init_level = nan;
  tank1.ht0 = nan;
  tank1.feed_pipe_index = 4;
  tanks(1) = tank1;
  % Set initial levels (initialize tanks)
  for i = 1:length(tanks)
    tank = tanks(i);
    init_level = init_tank_levels(i);
    if ((init_level < tank.x_min) || (init_level > tank.x_max))
      error('Initial tank level not within bounds');
    else
      tanks(i).init_level = init_level;
      tanks(i).ht0 = tank.elevation + init_level; % make sure that x_min <= init_level <= x_max
    end
  end
  
  % 3. NETWORK TOPOLOGY
  % node-element incidence matrix for the (calculated) connection nodes
  network.Lc = [1 -1 0 0 0;...
                0 1 -1 0 0;...
                0 0 1 -1 -1;...
                0 0 0 0 1];
  % node-element incidence matrix for the fixed (non-calculated) connection
  % nodes
  network.Lf=[-1 0 0 0 0;...
               0 0 0 1 0];
  % Combined incidence matrix for calculated and non-calculated connection nodes
  network.L = [network.Lc; network.Lf];
  
  % Construct the network structure
  network.pump_groups = pump_groups;
  network.tanks = tanks;
  % FUTURE VARIABLES
  network.ncheck = 0; % number of check valves
  network.nprv = 0; % number of PRVs
      
  network.npg = length(network.pump_groups); % number of pump groups
  network.nt = nt; % number of tanks
  network.nr = nr; % number of reservoirs
  network.nc = size(network.Lc,1); % number of calculated nodes
  network.nf = size(network.Lf,1);; % number of fixed head nodes
  network.pipe_indices=[1;3;4;5]; % Pipe flow index for the simulator results
  network.pump_group_indices = [2];
  network.npipes = length(network.pipe_indices);
  % Number of elements is equal to number of pipes + number of pump groups
  network.ne = network.npipes + network.npg; 
  
  network.elements.tank_feed_pipe_index = 4;
  
  % Find the total number of pumps
  _npumps = 0;
  for i = 1:length(network.pump_groups)
    _npumps = _npumps + network.pump_groups(i).npumps;
  end
  network.npumps = _npumps;
  
  % Indices of calculated nodes, reexservoir nodes and tank nodes, respectively
  network.hc_indices=[1;2;3;4]; % Row number in network.L matrix
  network.hr_indices=[5]; % Row number in network.L matrix
  network.ht_indices=[6]; % Row number in network.L matrix

  % Pipe resistances
  network.Rs = 10^-6*fDW.*L_pipe./(2*const.g*D_pipe.*A_pipe.^2);
      
  %% INPUTS
  % A 24x1 vector of tariffs
  input.tariff = [0.072490, 0.072490, 0.072490, 0.072490, 0.072490, 0.072490, ...
      0.072490, 0.087490, 0.087490, 0.087490, 0.087490, 0.087490, 0.087490, ...
      0.087490, 0.087490, 0.15195, 0.15195, 0.15195, 0.084340, 0.084340, ...
      0.084340, 0.084340, 0.084340, 0.084340];
  %% Initial pump schedules
  input.init_schedule.N = [2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 0 0 0 2 2 2 2 2 2];
  input.init_schedule.S = 0.8 * ones(1, sim.TIME_HORIZON);
  % A 24x1 vector of demands for calculated node 4
  demand4 = [0.72, 0.59, 0.53, 0.47, 0.51, 0.55, 1.1, 1.53,	1.51, 1.34, 1.3, ...
      1.3, 1.24,	1.24, 1.17, 1.14, 1.06, 1.121, 1.15, 1.31, 1.24,	1.21, ...
      1.13, 1.14];
  % Create a matrix of nodal demands representative of the whole network (to 
  % be used by the MILP formulation
  input.demands = zeros(network.nc, sim.TIME_HORIZON);
  input.demands(4,:) = demand4;
  input.demands = input.demands * DEMAND_MULTIPLIER;
  input.demands = sparse(input.demands);
  input.df = 1;
  input.hr = hr;
  
end

% Differentiate between element and pipe/pump indices.
% In the simulator, all elements are lumped into a signle vector but, for the
% purpose of MILP, pumps and pipes are treated separately
%network.pipes.tank_feed_pipe_index = 3;
%network.elements.tank_feed_pipe_index = 4;
%network.elements.pump_index=[2;3];


