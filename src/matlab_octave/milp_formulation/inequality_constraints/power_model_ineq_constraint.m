function [A_p_lin, b_p_lin] = power_model_ineq_constraint(vars, lin_power, linprog)
  % Implement the inequality constraints on pump power using the big U trick
  % - m_s * sj(k) - m_q * qj(k) + pj(k) + nj(k) Upower <= U_power + c (LH constraint)
  % m_s * sj(k) + m_q * qj(k) + -pj(k) + nj(k) Upower <= Upower -c (RH constraint)
  % Initialize the left and right hand constraints
  number_time_steps = size(vars.x_cont.p, 1);
  number_pumps =size(vars.x_cont.p, 2);
  A_lh = zeros(number_time_steps*number_pumps,var_struct_length(vars));
  A_rh = zeros(number_time_steps*number_pumps,var_struct_length(vars));
  b_lh = zeros(number_time_steps,number_pumps);
  b_rh = zeros(number_time_steps,number_pumps);
  
  m_dq = lin_power.coeff(1);
  m_ds = lin_power.coeff(2);
  c = lin_power.coeff(3);
  
  % LH inequality
  row_counter = 1;
  for j = 1:number_pumps
    for i = 1:number_time_steps
      Aineq = vars;
      Aineq.x_cont.s(i,j) = -m_ds;
      Aineq.x_cont.q(i,j) = -m_dq;
      Aineq.x_cont.p(i,j) = 1;
      Aineq.x_bin.n(i,j) = linprog.Upower;
      bineq = linprog.Upower + c;
      A_lh(row_counter,:) = struct_to_vector(Aineq)';
      b_lh(i,j)=bineq;
      row_counter = row_counter + 1;  
    end
  end
  % Roll out the b vector
  b_lh = b_lh(:);

  % RH inequality
  row_counter = 1;
  for j = 1:number_pumps
    for i = 1:number_time_steps
      Aineq = vars;
      Aineq.x_cont.s(i,j) = m_ds;
      Aineq.x_cont.q(i,j) = m_dq;
      Aineq.x_cont.p(i,j) = -1;
      Aineq.x_bin.n(i,j) = linprog.Upower;
      bineq = linprog.Upower - c;
      A_rh(row_counter,:) = struct_to_vector(Aineq)';
      b_rh(i,j)=bineq;
      row_counter = row_counter + 1;  
    end
  end
  % Roll out the b vector
  b_rh = b_rh(:);

  A_p_lin = [A_lh; A_rh];
  b_p_lin = [b_lh; b_rh];
end
