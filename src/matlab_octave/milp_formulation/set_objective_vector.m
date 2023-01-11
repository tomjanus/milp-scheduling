function f_vector = set_objective_vector(...
    vars, network, tariff_vec, time_step, no_steps, sparse_out)
  % Find a vector of objective vector coefficients
  % Apply tariff multiplier to the power consumption vector in x_cont variable
  % structure
  % The assignment follows data structure in which power consumption is
  % represented as a vector of power calculated in every pump over calculation
  % time horizon.
  
  % WARNING: no_steps needs to be corresponding to the number of steps chosen
  %   during initialisation of the vars structure. Potential source of conflict
  %   TODO: Move no_steps to a common data structure, e.g. as a field in the
  %     network structure, to avoid situation where different numbers of the
  %     time_step variable are provided to different functions, leading to
  %     calculation issues that can be difficult to track down.
  %     no_steps could, alternatively, be incorporated in the var structure.
  
  % Args:
  %   vars - structure with all continuous and binary variables in the MILP 
  %          formulation
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
  f_struct = vars;
  f_cont = vars.x_cont;
  f_bin = vars.x_bin;
  
  if no_steps > length(tariff_vec)
    error('Number of scheduling steps greater than the length of the tariff')
  end
  
  enum = 1;
  for i = 1:network.npumps
    for j = 1:no_steps
      % Set objective function coefficientsm i.e. multipliers of the pump 
      % power consumption `p`
      f_struct.x_cont.p(enum) = tariff_vec(j) * time_step;
      enum = enum + 1;
    end
  end
  
  f_vector = [struct_to_vector(f_struct, "x_cont"); ...
              struct_to_vector(f_struct, "x_bint")];
  
  % Convert the output vector to its sparse representation, if required
  if (sparse_out == true)
    f_vector = sparse(f_vector);
  end
end
    
 
 