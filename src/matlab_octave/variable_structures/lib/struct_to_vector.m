function var_vector = struct_to_vector(var_struct, var_type)
  % Access all fields in a var struct and output a concatenated variable 
  % vector
  % Works individually for bin and continuous variables
  % Args:
  %   var_struct: var structure containing fields x_cont and x_bin
  %   var_type (Optional): specifies the type of variable which
  %     length is to be calculated, i.e. 'x_cont' or 'x_bin'

  if nargin == 2
    parsed_fields = {var_type};
  else
    parsed_fields = {'x_cont', 'x_bin'};
  end
  
  field_names = fieldnames(var_struct);
  var_vector = [];
  
  for k=1:numel(field_names)
    field_name = field_names{k};
    if ~ismember(field_name, parsed_fields)
      continue
    end
    subfield_names=fieldnames(var_struct.(field_name));
    for l=1:numel(subfield_names)
      subfield_name = subfield_names{l};
      subfield_vector = var_struct.(field_name).(subfield_name);
      % Convert the fields to vectors
      if number_of_dimensions(subfield_vector) > 1
        subfield_vector = tensor_to_vector(subfield_vector);
      end
      var_vector = [var_vector; subfield_vector];
    end
  end
end
