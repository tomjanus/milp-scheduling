function [lb, ub] = set_variable_bounds(var_struct, constraints, ht_forced_end)
  % Set upper and lower boundaries for continuous and binary decision variables
  % Set constraints on continuous variables
  % Args:
  % var_struct - structure of variables with x_cont and x_bin fields
  % constraints - 
  
  % Create copies of the var stucture. (in this way we can make sure that the
  % size and order of variables in the lower and upper bound vectors corresponds
  % to the size and order of variables in the decision variable vector x.
  lb_struct = var_struct;
  ub_struct = var_struct;
  
  parsed_fields = {'x_cont', 'x_bin'};
  
  % Iterate through all variables
  field_names = fieldnames(var_struct);
  for i = 1:length(field_names)
    var_type = field_names{i};
    if ~ismember(var_type, parsed_fields)
      continue
    end
    var_names = fieldnames(var_struct.(var_type));
    for j=1:length(var_names)
      var_name = var_names{j};
      constraint = constraints.(var_type).(var_name);
      % Apply constraints to tensors
      lb_constraint = apply_constraint(getfield(lb_struct.(var_type), var_name), ...
          constraint(1));
      ub_constraint = apply_constraint(getfield(ub_struct.(var_type), var_name), ...
          constraint(2));

      % Enforce that the first and the last value of ht are equal
      % TODO: Remove this if statement and restructure the constraint
      %       application code to include single values as well as vectors
      %       (profiles). At the moment constraints can only be formulated
      %       as upper and lower bounds (constants). Allow code to include
      %       constraints specified as vectors (profiles). Raised in issue
      %       #7
      if strcmp(var_name,'ht')
          lb_constraint(end) = ht_forced_end; % Equal to network.tanks(1).ht0 = 233 (default 2p1t case study)
      end
      % Set constraint values
    lb_struct.(var_type).(var_name) = lb_constraint;
    ub_struct.(var_type).(var_name) = ub_constraint;
    end
  end
  lb = struct_to_vector(lb_struct);
  ub = struct_to_vector(ub_struct);
end
