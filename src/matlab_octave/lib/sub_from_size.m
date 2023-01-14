function [varargout] = sub_from_size(array_size, lin_index)
  % Takes information about the size of an array and produces
  % the array of indices pointing to the element of this
  % array that is `pointed to` by a linear index given in
  % argument `lin_index'.
  % Args:
  %  array_size: array of integers describing the
  %    dimensionality of the array
  %  lin_index: integer determining the linear index, i.e.
  %    the index to the element of the array reshaped into
  %    a vector
  % Return:
  %  multi-dimensional index - variable number of arguments
  nout = length(array_size);
  [varargout{1:nout}] = ind2sub(array_size, lin_index);
end
