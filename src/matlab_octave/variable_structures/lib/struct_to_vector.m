function var_vector = struct_to_vector(var_structure)
  % Access all fields in a var struct and output a concatenated variable vector
  % Works individually for bin and continuous variables
  % Assumption
  % The var structure contains fields 'x_cont' and 'x_bin; and each of these
  % fields contains fields representing vectors
  
  field_names = fieldnames(var_struct);
  var_vector = [];
  
  for k=1:numel(field_names)
    field_name = field_names{k};
    if (field_name == 'x_cont') || (field_name == 'x_bin')
      subfield_names=fieldnames(var_struct.(field_name))
      for l=1:numel(subfield_names)
        subfield_name = subfield_names{l};
        subfield_value = var_structure.(field_name).(subfield_name);
        if(isnumeric(subfield_value) && length(subfield_value > 0))
            var_vector = [var_vector; field_value];
        end        
      end
    end
  end
  
end