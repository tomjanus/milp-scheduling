function [optim_out,init_sim_output,optim_sim_output,sim,input,vars] = ...
    run_scheduling_2p1t()
  %% Run a scheduling problem on a  two pump one tank network (2p1t)
  % Set sparse to true - make it an argument later
  sparse_out = 1;
  
  % Step 1 - Load network and input data
  [input,const,linprog,network,sim,pump_groups] = initialise_2p1t();
  % Step 2 - Simula ste the network
  % Calculate flows, calculated heads, power consumption and tank levels
  init_sim_output = simulator_2p1t(input.init_schedule, network, input, sim);
  % Find q_op and s_op at 12
  pump_speed_12 = input.init_schedule.S(12);
  pump_flow_12 = init_sim_output.q(2,12)/input.init_schedule.N(12);
  
  % Step 4 - Formulate linear program
  % Initialise continuous and binary variable structures
  vars = initialise_var_structure(network, linprog);
  % Set the vector of indices of binary variables in the vector of decision variables x
  intcon_vector = set_intcon_vector(vars);
  % Set the vector of objective function coefficients c
  c_vector = set_objective_vector(vars, network, input, linprog, true);
  % Get variable (box) constraints for the two pump one tank network
  constraints = set_constraints_2p1t(network);
  [lb_vector, ub_vector] = set_variable_bounds(vars, constraints);
  % Linearize the pipe and pump elements
  lin_pipes = linearize_pipes_2p1t(network, init_sim_output);
  lin_pumps = linearize_pumps_2p1t(pump_groups);
  % Linearize the power consumption model
  %l in_power = linearize_pump_power_2p1t(pump_groups, pump_flow_12, ...
  %    pump_speed_12);
  % Linearize pump model with dummy constriants and domain vertices 
  % (as not relevant for linearization)
  constraint_signs = {'>', '<', '<', '>'};
  domain_vertices = {[0,0], [0,0], [0,0], [0,0]};
  lin_power = linearize_power_model(pump_groups(1).pump, pump_flow_12, ...
      pump_speed_12, domain_vertices, constraint_signs);
  % Set the inequality constraints A and b
  [A, b] = set_A_b_matrices(vars, linprog, lin_power, lin_pipes, ...
      lin_pumps, pump_groups, sparse_out);
  % Set the equality constraints Aeq and beq
  [Aeq, beq] = set_Aeq_beq_matrices(vars, network, input, lin_pipes,...
      sparse_out);
  % Run the MILP scheduler
  % For debugging, reset lb and ub vectors
  %lb_vector = ones(size(lb_vector))*-inf;
  %ub_vector = ones(size(ub_vector))*inf;
  %intcon_vector = [];
  options = optimoptions(...
     'intlinprog', ...
     'CutMaxIterations', 25, ...
     'MaxTime', 68000,...
     'CutGeneration', 'intermediate', ...
     'Heuristics','intermediate', ...
     'HeuristicsMaxNodes', 100, ...
     'BranchRule', 'strongpscost',...
     'IntegerPreprocess','advanced');
  [n, s, x] = scheduler(c_vector, intcon_vector, A, b, Aeq, beq, ...
      lb_vector, ub_vector, vars, options);
  optim_out.n = n;
  optim_out.s = s;
  optim_out.x = x;
  optim_out.schedule.N = sum(n,network.npumps)';
  optim_out.schedule.S = sum(s,network.npumps)';
  % Run the simulator with optimized schedules
  optim_sim_output = simulator_2p1t(optim_out.schedule, network, input, sim);
end









