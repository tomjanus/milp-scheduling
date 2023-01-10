function f_vector = set_objective_vector(...
    vars, network, tariff_vec, time_step, no_steps, sparse_out)
  % Find a vector of objective vector coefficients
  % Apply tariff multiplier to the power consumption vector in x_cont variable
  % structure
  % The assignment follows data structure in which power consumption is
  % represented as a vector of power calculated in every pump over calculation
  % time horizon.
  
  % Args:
  %   vars - structure with all continuous and binary variables in the MILP formulation
  %   network_data - structure with network data
  %   tarif_vec - vector of energy tariffs over the scheduling horizon
  %   time_step - simulation time-step, normally 1 hr
  %   no_steps - number of time-steps in the scheduling horizon
  %   sparse_out - logical variable defining whether to output a sparse
  %                representation of the objective vector
  
  % Returns:
  %   vector of objectives
  
  % Create copies of variable structures used to later create an objective
  % coefficient vector
  f_cont = vars.x_cont;
  f_bin = vars.x_bin;
  
  if no_steps > length(tariff_vec)
    error('Number of scheduling steps greater than the length of the tariff')
  end
  
  enum = 1;
  for i = 1:network.npumps
    for j = 1:no_steps
      f_cont.p(enum) = tariff_vec(j) * time_step;
      enum = enum + 1;
    end
  end
  
  f_vector = [struct_to_vector(f_cont); struct_to_vector(f_bin)];
  
  if (sparse_out == true)
    f_vector = sparse(f_vector);
  end
end
    
 
 