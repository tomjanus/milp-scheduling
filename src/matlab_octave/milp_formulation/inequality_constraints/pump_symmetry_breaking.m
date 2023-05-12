function [A_pumpsymmetry, b_pumpsymmetry] = pump_symmetry_breaking(vars)
  % Implements a symmetry breaking constraint prioritizing pumps of equal characteristics
  % in pump groups
  % 
  % n(j)(k) >= n(j+1)(k) for j = 1 to npumps-1
  % wich translates into a sentence: the status of preceding pump cannot be lower then
  % the status of subsequent pumps. E.g. in case of two pumps, status combinations
  % (0,0), (1,0), and (1,1) are permitted whilst status combination (0,1) is prohibited.
  
  % The constraint is written as follows as a single-sided inequality
  %   n(j+1)(k) - n(j)(k) <= 0,     for j = 1 to npumps - 1
  
  % TODO: Generalize into multiple pump groups
  no_pumps = size(vars.x_bin.n, 2);
  no_time_steps = size(vars.x_bin.n,1);
  number_of_constraints = (no_pumps - 1) * no_time_steps;
  
  A_lh = zeros(number_of_constraints, var_struct_length(vars));
  b_lh = zeros(no_time_steps, no_pumps - 1);
  
  %LHS inequality
  row_counter = 1;
  for j = 1:(no_pumps - 1)
    for k = 1:no_time_steps
      Aineq = vars;
      Aineq.x_bin.n(k,j) = -1;
      Aineq.x_bin.n(k,j+1) = +1;
      b_lh(k,j) = 0;
      A_lh(row_counter,:) = struct_to_vector(Aineq)';
      row_counter = row_counter + 1;
    end
  end
  b_lh = tensor_to_vector(b_lh);
  A_pumpsymmetry = A_lh;
  b_pumpsymmetry = b_lh;
end
