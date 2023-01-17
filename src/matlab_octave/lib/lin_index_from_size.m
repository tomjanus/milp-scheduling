function index_1d = lin_index_from_size(array_size, index_array)
  % Takes a stacked 1D array that was created from a multi-dimensional array
  % with dimensions given in a cell argument orig_dims and finds index
  % in the 1D array that corresponds to the element in the multi-dimensional
  % array accesed with coordinates provided in index_array
  % Args:
  %   orig_dims: array of original dimensions, e.g. [3,4,2]
  %   index_array: cell with indices pointing to the element of the original
  %     multi-dimensional array
  
  % Argument consistency check
  if length(array_size) ~= length(index_array)
    error('Array dimensions and index arguments do not have the same lengths.');
  end
  % Check all indices
  for i = 1:length(index_array)
    if index_array{i} > array_size(i)
      error('Index %d supplied in index array beyond bounds.', index_array{i});
    end
  end
  index_1d = sub2ind(array_size, index_array{:});
end