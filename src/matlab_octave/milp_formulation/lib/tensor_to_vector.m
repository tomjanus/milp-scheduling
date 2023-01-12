function vec = tensor_to_vector(tensor)
  % Unstack the multidimensional tensor into a vector
  num_elements = numel(tensor);
  vec = reshape(tensor, num_elements, 1);
end
