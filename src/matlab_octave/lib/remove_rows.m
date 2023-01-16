function output_array = remove_rows(input_array, row_indices)
  %
  output_array = input_array;
  output_array(row_indices,:)=[];
end
