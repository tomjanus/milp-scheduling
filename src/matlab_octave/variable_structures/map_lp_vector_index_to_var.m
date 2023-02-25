function y = map_lp_vector_index_to_var(var_structure, var_index)
  % Takes an index from a vector of variables in linprog formulation and
  % returns the field and subfield name and index of this variable in
  % var_struct
  
  % Assumption:
  % var_structure needs to contain two fields: x_cont and x_bin
  
  % Args:
  %   var_structure - variable structue with continous and binary variables
  %   var_index - index within the linprog variable vector

  parsed_fields = {'x_cont', 'x_bin'};
  
  % Initialize the output structure
  y.field_name = '';
  y.subfield_name = '';
  y.index = nan;

  start_index = 0;
  for i=1:numel(parsed_fields)
      % Only select the variable fields: x_cont and x_bin
      field_name = parsed_fields{i};
      % If we are dealing with the vectors
      % Iterate through the variables - continuous first and then binary
      var_names = fieldnames(var_structure.(field_name));
      for j=1:numel(var_names)
          var_j_name = var_names{j};
          subfield_array = var_structure.(field_name).(var_j_name);
          var_j_length = numel(subfield_array);
          lb_index = start_index;
          end_index = start_index + var_j_length;
          if var_index > lb_index && var_index <= end_index
              y.field_name = field_name;
              y.subfield_name = var_j_name;
              n_array_dim = number_of_dimensions(subfield_array);
              % Work on arrays of different dimensions
              if n_array_dim == 1
                  y.index(1) = sub_from_array(...
                      subfield_array,(var_index - lb_index));
              elseif n_array_dim == 2
                  [y.index(1), y.index(2)] = sub_from_array(...
                      subfield_array,(var_index - lb_index));
              elseif n_array_dim == 3
                  [y.index(1), y.index(2), y.index(3)] = sub_from_array(...
                      subfield_array,(var_index - lb_index));
              else
                  error('Only arrays of dimension 1, 2 and 3 are supported.');
              end
              return
          end
          start_index = end_index;
      end        
  end
end

  % Returns index pointing to the variable in the vector x of MILP formulation