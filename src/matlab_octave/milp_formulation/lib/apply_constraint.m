function out = apply_constraint(tensor, constraint_value)
  % Takes an n-dimensional tensor, creates a copy and sets all
  % values in the copy to the value provided in the
  % constraint_value argument
  out = ones(size(tensor))*constraint_value;
end
