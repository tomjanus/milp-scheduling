function [A_q_box, b_q_box] = q_box_constraints(vars, pump_groups, linprog)
  % Binary linearize pump flow q
  % 0 <= qqij(k) <= AAij(k) * qint,jmax
  number_pumps = size(vars.x_bin.n, 2);
  number_time_steps = size(vars.x_bin.n, 1);
  
  A_lh = zeros(number_time_steps*number_pumps, var_struct_length(vars));
  A_rh = zeros(number_time_steps*number_pumps, var_struct_length(vars));
  b_lh = zeros(number_time_steps, number_pumps);
  b_rh = zeros(number_time_steps, number_pumps);
  
  %LHS inequality
  row_counter = 1;
    for j = 1:number_pumps
      qmin = 0;
      for k = 1:number_time_steps
        Aineq = vars;
        Aineq.x_cont.q(k,j) = -1;
        b_lh(k,j) = qmin;
        A_lh(row_counter,:) = struct_to_vector(Aineq)';
        row_counter = row_counter + 1;
      end
    end
  b_lh = tensor_to_vector(b_lh);

  %RHS inequality
  row_counter = 1;
    for j = 1:number_pumps
      % TODO: Modify this to consider multiple pump groups
      qmax = pump_groups(1).pump.qint_smax;
      for k = 1:number_time_steps
        Aineq = vars;
        Aineq.x_cont.q(k,j) = 1;
        Aineq.x_bin.n(k,j) = -qmax;
        b_rh(k,j) = 0;
        A_rh(row_counter,:) = struct_to_vector(Aineq)';
        row_counter = row_counter + 1;
      end
    end
  b_rh = tensor_to_vector(b_rh);
  
  A_q_box = [A_lh; A_rh];
  b_q_box = [b_lh; b_rh];
  
end
