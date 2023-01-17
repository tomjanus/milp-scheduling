function intcon = set_intcon_vector(var_struct)
  % Set intcon vector for the MILP programme formulation.
  % The vector is composed of indices of variables that are binary.
  
  % Args:
  %   var_struct - structure of variables with x_cont and x_bin fields
  %     storing continuous variables and integer variables, respectively
  
  intcon = find([zeros(var_struct_length(var_struct, 'x_cont'), 1); ...
            ones(var_struct_length(var_struct, 'x_bin'), 1)]);
end
