function [lb, ub] = constant_bounds(vector_length, lower_bound, upper_bound)
  % Set constant lower and upper bounds on a vector of length = vector_length
  lb = ones(vector_length, 1) * lower_bound;
  ub = ones(vector_length, 1) * upper_bound;  
end
