%% Run case study with the two pump single tank network using milp solver outside MATLAB
%  -------------------------------------- PART 2 ---------------------------------------
%  Requires optimization state vector x in file `optim_x.mat` and the outputs of file 
%  `run_2p1t_without_matlab_1.m` in file `optim_step1.mat`
%  Reads the .mat file and finishes the process by running final optimization with the
%     optimized schedule and visualise results, i.e. visualise the following:
%     (a) Simulation results with initial pump schedule
%     (b) Outputs of the linear programme
%     (c) Simulation results with optimized pump schedule

%% Load the required mat files
load("optim_step1.mat");
% Note, if you run cbc change the below path to
% "../python/outputs/2p1t/x_optim_cbc.mat"
load("../python/outputs/2p1t/x_optim_cplex", "x"); % Needs to load optimization state variable `x`
   
% Retrieve pump schedule from the optimal state vector x
[n, s] = find_schedule_from_x(1, vars, x);
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
        
% Remove intermediate step .mat file `optim_step1.mat`
delete('optim_step1.mat')
