function output_array = remove_columns(input_array, column_indices)
  %
  output_array = input_array;
  output_array(:,column_indices)=[];
end
