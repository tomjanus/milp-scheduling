function y = run_scheduling(plot_outputs)
  %% Run a scheduling problem on a  two pump one tank network (2p1t)
  if nargin < 1
    plot_outputs = false;
  end
  % Step 1 - Load network and input data
  [input,const,linprog,network,sim,pump_groups] = initialise_2p1t();
  % Step 2 - Simulate the network
  % Calculate flows, calculated heads, power consumption and tank levels
  output = simulator_2p1t(input.init_schedule, network, input, sim);
  % Find q_op and s_op at 12
  pump_speed_12 = input.init_schedule.S(12);
  pump_flow_12 = output.q(2,12)/input.init_schedule.N(12);
  
  % Step 3 - Visualise simulation results
  if plot_outputs
    plot_2p1t_simulation_results(output,input.init_schedule.N, ...
      input.init_schedule.S,input, sim, 1);
  end
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
  lin_pipes = linearize_pipes_2p1t(network, output);
  lin_pumps = linearize_pumps_2p1t(pump_groups);
  % Linearize the power consumption model
  %lin_power = linearize_pump_power_2p1t(pump_groups, pump_flow_12, pump_speed_12);
  % Linearize pump model with dummy constriants and domain vertices (as not relevant for linearization)
  constraint_signs = {'>', '<', '<', '>'};
  domain_vertices = {[0,0], [0,0], [0,0], [0,0]};
  lin_power = linearize_power_model(pump_groups(1).pump, pump_flow_12, pump_speed_12, ...
      domain_vertices, constraint_signs);
  
  % Set the equality constraints parameters Aeq and beq
  
  y.vars = vars;
  y.lin_pipes = lin_pipes;
  
end









