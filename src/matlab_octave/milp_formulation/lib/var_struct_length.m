function struct_length = var_struct_length(var_struct, var_type)
  % Find the total length of all vectors of the MILP var structure
  % Args:
  %   var_struct: var structure containing fields x_cont and x_bin
  %   var_type (Optional): specifies the type of variable which
  %     length is to be calculated.
  %

  if nargin == 2
    parsed_fields = {var_type};
  else
    parsed_fields = {'x_cont', 'x_bin'};
  end
  
  field_names = fieldnames(var_struct);
  struct_length = 0;
  for k=1:numel(field_names)
    field_name = field_names{k};
    % Iterate only through fields that contain continuous or binary vars
    if ismember(field_name, parsed_fields)
      subfield_names = fieldnames(var_struct.(field_name));
      for l=1:numel(subfield_names)
        subfield_name = subfield_names{l};
        field_length = numel(var_struct.(field_name).(subfield_name));
        struct_length = struct_length + field_length;
      end
    end    
  end
end
