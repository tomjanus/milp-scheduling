function [A, b] = set_A_b_matrices(vars, linprog, sparse_out)
  % Calculate all inequality constraints and create A and b matrices
  [A_p, b_p] = power_ineq_constraint(vars, linprog);
  
  A = [A_p];
  b = [b_p];
  
  
  if (sparse_out == true)
    A = sparse(A);
    b = sparse(b);
  end
end

function [A_p, b_p] = power_ineq_constraint(vars, linprog)
  % Set the inequality constraints
  % p_j(k) - n_j(k) U_power <= 0            (1)
  % -p_j(k) <= 0                            (2)
  % for every pump j for every time step k
  % The inequality is used fo `binary linearisation’ of power consumption output
  % with respect to the pump (on/off) status.
  number_time_steps = size(vars.x_cont.p, 1);
  number_pumps =size(vars.x_cont.p, 2);

  % Initialize output arrays
  A_p = zeros(2*number_time_steps*number_pumps, var_struct_length(vars));
  b_p = zeros(number_time_steps,number_pumps, 2);
  
  row_counter = 1;
  % Eq. 1
  for j = 1:number_pumps
    for i = 1:number_time_steps
      Aineq = vars;
      Aineq.x_cont.p(i,j) = 1;
      Aineq.x_bin.n(i,j) = - linprog.Upower;
      bineq = 0;
      A_p(row_counter,:) = struct_to_vector(Aineq)';
      b_p(i,j,1)=bineq;
      row_counter = row_counter + 1;
    end
  end
  
  % Eq. 2
  for j = 1:number_pumps
    for i = 1:number_time_steps
      Aineq = vars;
      Aineq.x_cont.p(i,j) = -1;
      bineq = 0;
      A_p(row_counter,:) = struct_to_vector(Aineq)';
      b_p(i,j,2)=bineq;
      row_counter = row_counter + 1;      
    end
  end
  % Roll out the b vector
  b_p = b_p(:);
end
