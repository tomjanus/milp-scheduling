%% Run case study with the two pump single tank network using intlinprog
%  Goes through the following steps:
%  1. Converts the network to a MILP formulation (requires a simulation step)
%  2. Runs optimization with MATLAB's intlinprog solver
%  3. Visualises the results, i.e.
%     (a) Simulation results with initial pump schedule
%     (b) Outputs of the linear programme
%     (c) Simulation results with optimized pump schedule

%% Set flags
save_to_mps = 1;  % Save the linear programme to mps file
save_to_mat = 1;  % Save the linear programme matrices to .mat file

%% Set options
max_optim_time = 100;  % Maximum allowed optimization time in seconds

%% Specify intlinprog's parameter (options) structure
options = optimoptions(...
   'intlinprog', ...
   'CutMaxIterations', 25, ...
   'MaxTime', max_optim_time,...
   'CutGeneration', 'intermediate', ...
   'Heuristics','intermediate', ...
   'HeuristicsMaxNodes', 100, ...
   'LPOptimalityTolerance', 1e-3, ...
   'BranchRule', 'strongpscost',...
   'IntegerPreprocess','advanced');
   
%% Load 2p1t network and input data
[input,const,linprog,network,sim,pump_groups] = initialise_2p1t();

%% Initialise continuous and binary variable structures required to construct linear programme 
vars = initialise_var_structure(network, linprog);

%% Initial simulation to simulate flows, calculated heads, power consumption and tank levels
init_sim_output = simulator_2p1t(input.init_schedule, network, input, sim);

%% Transform network to a mixed integer linear model
lin_model = transform_2p1t_to_milp(input, linprog, network, pump_groups, ...
    init_sim_output, save_to_mps, save_to_mat, 1);

%% Set initial condition for the linear programme
x0=[];

%% Run mixed integer optimization in MATLAB
[n, s, x] = calculate_schedule(lin_model, x0, vars, options);
optim_output.n = n;
optim_output.s = s;
optim_output.x = x;
 
%% Obtain schedule structure that is compatible with the simulator
% NOTE: In scheduler, each pump is represented individually whilst simulator models
%       groups of pumps as one unit
% NOTE: This only works for a single pump group
[optim_n, optim_s] = linprog_to_sim_schedule(n,s);
optim_output.schedule.N = optim_n;
optim_output.schedule.S = optim_s;

%% Run the simulator with optimized schedules
optim_sim_output = simulator_2p1t(...
    optim_output.schedule, network, input, sim);
    
%% Visualise results: 
% 1. simulation with initial schedule
% 2. optimizer output
% 3. final_simulation with optimized schedule
plot_scheduling_2p1t_results(init_sim_output, optim_output, ...
        optim_sim_output, input, sim, vars);

