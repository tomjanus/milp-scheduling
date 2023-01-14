function [varargout] = sub_from_array(array, lin_index)
  % Finds the array of indices pointing to the element of
  % the array that is `pointed to` by a linear index given
  % in argument `lin_index'.
  % Args:
  %  array: (multi-dimenionality) array of values
  %  lin_index: integer determining the linear index, i.e.
  %    the index to the element of the array reshaped into
  %    a vector
  % Return:
  %  multi-dimensional index - variable number of arguments
  nout = length(size(array));
  [varargout{1:nout}] = ind2sub(size(array), lin_index);
end
