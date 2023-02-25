function y = map_var_index_to_lp_vector(var_structure, var_name, var_index)
  % Takes an index from a vector of variables of a given type and returns the
  % index to this variable in the composite vector of variables x used in the
  % MILP formulation
  
  % Assumption:
  % var_structure needs to contain two fields: x_cont and x_bin
  
  % Args:
  %   var_structure - variable structue with continous and binary variables
  %   var_name - variable name
  %   var_index - index within the variable vector (integer) or a cell of
  %      subscripts, e.g. {2,4}
  
  isaninteger = @(x)isfinite(x) & x==floor(x);

  % Returns index pointing to the variable in the vector x of MILP formulation
  fn=fieldnames(var_structure);
  % Loop through the fields
  parsed_fields = {'x_cont', 'x_bin'};
  
  field_found = false;
  start_index = 0;
  
  for i=1:numel(fn)
      % Only select the variable fields: x_cont and x_bin
      field_name = fn{i};
      % If we are dealing with the vectors
      if ismember(field_name, parsed_fields)
        % Iterate through the variables - continuous first and then binary
        var_names = fieldnames(var_structure.(field_name));
        for j=1:numel(var_names)
          var_j_name = var_names{j};
          var_j_length = numel(var_structure.(field_name).(var_j_name));
          if strcmp(var_j_name, var_name) == true
            field_found = true;
            break
          end
          start_index = start_index + var_j_length;
        end
        if field_found == true
          break
        end
      end
  end
  % Throw error if the requested field could not be found
  if field_found ~= true
      error('Variable %s not found', var_name);
  else
      if iscell(var_index)
          var_index_str = mat2str(cell2mat(var_index));
          var_index = lin_index_from_array(...
              var_structure.(field_name).(var_j_name), var_index);
      end
  end
  if isaninteger(var_index)
      var_index_str = int2str(var_index);
  end
  % Throw error if the requested index is beyond the vector's length
  if var_index > var_j_length
    error('Index %s of field %s beyond range', var_index_str, var_name);
  end

  y = start_index + var_index;
end
