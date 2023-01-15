function [lb, ub] = set_variable_bounds(var_struct, constraints)
  % Set upper and lower boundaries for continuous and binary decision variables
  % Set constraints on continuous variables
  % Args:
  % var_struct - structure of variables with x_cont and x_bin fields
  % constarints - 
  
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
      % Set constraint values
    lb_struct.(var_type).(var_name) = lb_constraint;
    ub_struct.(var_type).(var_name) = ub_constraint;
    end
  end
  lb = struct_to_vector(lb_struct);
  ub = struct_to_vector(ub_struct);
end
