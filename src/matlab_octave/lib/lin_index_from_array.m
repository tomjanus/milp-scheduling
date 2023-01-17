function index_1d = lin_index_from_array(var_array, index_array)
  % Calculate index in a reshaped 1D array from a multi-dimensional array
  % base on the sequence of indices pointing to the element in the
  % multidimensional array.
  % e.g.
  % var_array = [2,3,5,8;3,0,-4,6]
  % index_array = {2,2} , pointing to the element 0
  % 1d (transformed array) = [2,3,3,0,5,-4,8,6]
  % index_1d = 2;
  
  % Carry out data consistency checks
  if number_of_dimensions(var_array) ~= length(index_array)
    error('Number of indices %d different from of var array dimension - %d', ...
      length(index_array), number_of_dimensions(var_array));
  end
  
  if length(index_array) == 1
    index_array = {index_array};
  end
  
  if ~iscell(index_array)
    error('index_array argument must be a scalar or a cell of values');
  end
  % Generate a linear (1D) index
  index_1d = sub2ind(size(var_array), index_array{:});
end
