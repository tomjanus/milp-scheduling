function y = run_scheduling(plot_outputs)
  %% Run a scheduling problem on a  two pump one tank network (2p1t)
  if nargin < 1
    plot_outputs = false;
  end
  % Step 1 - Load network and input data
  [input,const,linprog,network,sim] = initialise_2p1t();
  % Step 2 - Simulate the network
  % Calculate flows, calculated heads, power consumption and tank levels
  output = simulator_2p1t(input.init_schedule, network, input, sim);
  % Step 3 - Visualise simulation results
  if plot_outputs
    plot_2pt1_simulation_results(output,input.init_schedule.N, ...
      input.init_schedule.S,input, sim, 1)    
  end
  % Step 4 - Formulate linear program
  % Initialise continuous and binary variable structures
  vars = initialise_var_structure(network, linprog);
  % Set the vector of indices of binary variables in the vector of decision variables x
  intcon_vector = set_intcon_vector(vars);
  % Set the vector of objective factors c
  c_vector = set_objective_vector(vars, network, input, linprog, true);
  % Get variable constraints for the two pump one tank network
  constraints = set_constraints_2p1t(network);
  [lb_vector, ub_vector] = set_variable_bounds(vars, constraints);
  % Set the equality constraints parameters Aeq and beq
  
  
end









