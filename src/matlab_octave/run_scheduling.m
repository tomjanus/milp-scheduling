% Step 1 - Load network and input data
run('initialise_2p1t.m')
% Step 2 - Simulate the network
% Calculate flows, calculated heads, power consumption and tank levels
% given initial tank head ht0, initial schedule, network data, input data,
% pump data and simulation time horizon.
output = simulator_2p1t(ht0,TIME_HORIZON,init_schedule,network,tank,input,pump);
% Visualise simulation results
N = init_schedule.N;
S = init_schedule.S;

%plot_simulation_results(output,N,S,input)
% Step 3 - Formulate linear program

