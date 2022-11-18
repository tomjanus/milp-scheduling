% Step 1 - Load network and input data
run('initialize.m')
% Step 2 - Simulate the network
% Calculate flows, calculated heads, power consumption and tank levels
% given initial tank head ht0, initial schedule, network data, input data,
% pump data and simulation time horizon.
[q,hc,P,ht,h] = Simulator(ht0,TIME_HORIZON,init_schedule,network,input,pump);
% Visualise simulation results
N = init_schedule.N;
S = init_schedule.S;
plot_simulation_results(q,hc,P,ht,N,S,input)
% Step 3 - Formulate linear program

