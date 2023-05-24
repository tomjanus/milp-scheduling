%% Run case study with the two pump single tank network using milp solver outside MATLAB
%  -------------------------------------- PART 1 ---------------------------------------
%  Requires three steps:
%  1. Convert the model into a mps file and run initial simulation
%  2. Run the mps file using Jupyter notebook in src/python/docs/solve_with_cplex_cbc.ipynb
%     and save the optimization output (optimal state vector x) to a mat file
%  3. Read the .mat file and finish the process by running final optimization with the
%     optimized schedule and visualise results, i.e. visualise the following:
%     (a) Simulation results with initial pump schedule
%     (b) Outputs of the linear programme
%     (c) Simulation results with optimized pump schedule

% The process requires running two files:
% 1. run_2p1t_without_matlab_1.m
% 2. run_2p1t_without_matlab_2.m

% In between 1 and 2 it is required to run the optimization outside matlab and transfer the
% generated outputs back to the root directory, i.e. the directory in which this file is located.
   
%% Load 2p1t network and input data
[input,const,linprog,network,sim,pump_groups] = initialise_2p1t();

%% Initialise continuous and binary variable structures required to construct linear programme 
vars = initialise_var_structure(network, linprog);

%% Initial simulation to simulate flows, calculated heads, power consumption and tank levels
init_sim_output = simulator_2p1t(input.init_schedule, network, input, sim);

%% Transform network to a mixed integer linear model
lin_model = transform_2p1t_to_milp(input, linprog, network, pump_groups, ...
    init_sim_output, 1, 1, 1);

% Save state for part 2 of the analysis
save("optim_step1.mat", "input", "network", "sim", "vars", "init_sim_output");


