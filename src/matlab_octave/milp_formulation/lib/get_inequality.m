function y = get_inequality(coeffs)
  % Function for determining the form of inequality based on the coefficients
  % m and c of the line forming the linear inequality of form y (.) m * x + c
  % where (.) is either '>' or '<'.
  % We use convention that independent and dependent variable are lumped into
  % one vector x = [x(1), x(2)] where x(2) = f (x(1)), i.e y <- x(2) and x <- x(1)
  % 
  % Args:
  %   coeffs: 1 x 2 array with coefficients m and c
  % Return:
  %   y: a structure storing the index of the variable for which the constraints
  %      are applied to - 2 - dependent variable, 1 - independent variable
  %      and the line coeficients - a 2x1 array.
  % 
  % The function handles two cases
  % (1): Inequality boundary x(2) = m * x(1) + c can be defined. In this case
  %      the function gives out the output y.var_index = 2, y.coeffs = coeffs
  % (2): Inequality boundary cannot be defined because m = Inf. In this case
  %      y.var_index = 1, i.e. the inequality is applied to the independent variable
  %      and y.coeffs = [0, coeffs(2)];
  
  if length(coeffs) ~= 2
    error('Expected coeffs arguments needs to be an array of length 2. Length %d given', ...
          length(coeffs));
  end
  if isnan(coeffs(0))
    y.var_index = 1;
    y.coeffs = [0, coeffs(2)];
  else
    y.var_index = 2;
    y.coeffs = coeffs;
  end
end
