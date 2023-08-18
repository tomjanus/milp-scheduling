function [A_qq_box, b_qq_box] = qq_box_constraints(vars, pump_groups, linprog)
  % Binary linearize pump flow q
  % 0 <= qqij(k) <= AAij(k) * qint,jmax
  number_pumps = size(vars.x_bin.n, 2);
  number_time_steps = size(vars.x_bin.n, 1);
  
  A_lh = zeros(number_time_steps*number_pumps*linprog.NO_PUMP_SEGMENTS, var_struct_length(vars));
  A_rh = zeros(number_time_steps*number_pumps*linprog.NO_PUMP_SEGMENTS, var_struct_length(vars));
  b_lh = zeros(number_time_steps, number_pumps, linprog.NO_PUMP_SEGMENTS);
  b_rh = zeros(number_time_steps, number_pumps, linprog.NO_PUMP_SEGMENTS);
  
  %LHS inequality
  row_counter = 1;
  for l = 1:linprog.NO_PUMP_SEGMENTS
    for j = 1:number_pumps
      qmin = 0;
      for k = 1:number_time_steps
        Aineq = vars;
        Aineq.x_cont.qq(l,k,j) = -1;
        %Aineq.x_bin.aa(l,k,j)
        b_lh(k,j, l) = qmin;
        A_lh(row_counter,:) = struct_to_vector(Aineq)';
        row_counter = row_counter + 1;
      end
    end
  end
  b_lh = b_lh(:);

  %RHS inequality
  row_counter = 1;
  for l = 1:linprog.NO_PUMP_SEGMENTS
    for j = 1:number_pumps
      % TODO: Modify this to consider multiple pump groups
      qmax = pump_groups(1).pump.qint_smax;
      for k = 1:number_time_steps
        Aineq = vars;
        Aineq.x_cont.qq(l,k,j) = 1;
        Aineq.x_bin.aa(l,k,j) = -qmax;
        b_rh(k,j,l) = 0;
        A_rh(row_counter,:) = struct_to_vector(Aineq)';
        row_counter = row_counter + 1;
      end
    end
  end
  b_rh = b_rh(:);
  
  A_qq_box = [A_lh; A_rh];
  b_qq_box = [b_lh; b_rh];
  
end
