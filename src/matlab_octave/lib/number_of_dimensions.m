function n_dim = number_of_dimensions(input_array, dim_squeeze)
  % Finds out the dimensionality of a (multidimensional) array.
  %
  % Args:
  %   input_array: a multi-dimensional array or cell
  %   dim_squeeze [optional]: a boolean flag. If true, the dimensions
  %     equal 1 are ignored (dropped), e.g. array of size 2, 1, 3 will
  %     be reported as having 2, instead of 3 dimensions.
  %     default value == false
  %
  % Return:
  %   number of dimensions (integer)

  switch nargin
    case 1
       dim_squeeze = false;
  end

  size_array = size(input_array);
  if dim_squeeze == true
    n_dim = sum(size_array > 1);
  else
    n_dim = length(size_array);
  end
end
