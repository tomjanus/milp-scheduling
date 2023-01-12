function n_dim = number_of_dimensions(array)
  % Finds out the dimensionality of the array
  size_array = size(array);
  n_dim = sum(size_array > 1);
end
