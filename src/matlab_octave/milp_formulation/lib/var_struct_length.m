function struct_length = var_struct_length(var_struct)
  % Find the total length of all vectors of the MILP var structure
  % Assumption
  % The var structure contains fields 'x_cont' and 'x_bin; and each of these
  % fields contains fields representing vectors of variable values
  
  field_names = fieldnames(var_struct);
  struct_length = 0;
  for k=1:numel(field_names)
    field_name = field_names{k};
    % Iterate only through fields that contain continuous or binary vars
    if (field_name == 'x_cont') || (field_name == 'x_bin')
      subfield_names=fieldnames(var_struct.(field_name))
      for l=1:numel(subfield_names)
        subfield_name = subfield_names{l};
        field_length = length(var_struct.(fields_name).(subfield_name));
        struct_length = struct_length + field_length;
      end
    end    
  end
end
