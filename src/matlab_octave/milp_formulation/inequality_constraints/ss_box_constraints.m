function [A_ss_box, b_ss_box] = ss_box_constraints(vars, pump_groups, linprog)
  % Binary linearize pump speed s
  % AAj,i (k) sj,min <= ssj,i (k) <= AAj,i (k) sj,max
  number_pumps = size(vars.x_bin.n, 2);
  number_time_steps = size(vars.x_bin.n, 1);
  
  A_lh = zeros(number_time_steps*number_pumps*linprog.NO_PUMP_SEGMENTS, var_struct_length(vars));
  A_rh = zeros(number_time_steps*number_pumps*linprog.NO_PUMP_SEGMENTS, var_struct_length(vars));
  b_lh = zeros(number_time_steps, number_pumps,linprog.NO_PUMP_SEGMENTS);
  b_rh = zeros(number_time_steps, number_pumps,linprog.NO_PUMP_SEGMENTS);
  
  %LHS inequality
  row_counter = 1;
  for l = 1:linprog.NO_PUMP_SEGMENTS
    for j = 1:number_pumps
      % TODO: Modify this to consider multiple pump groups
      smin = pump_groups(1).pump.smin;
      for k = 1:number_time_steps
        Aineq = vars;
        Aineq.x_cont.ss(l,k,j) = -1;
        Aineq.x_bin.aa(l,k,j) = smin;
        b_lh(k,j,l) = 0;
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
      smax = pump_groups(1).pump.smax;
      for k = 1:number_time_steps
        Aineq = vars;
        Aineq.x_cont.ss(l,k,j) = 1;
        Aineq.x_bin.aa(l,k,j) = -smax;
        b_rh(k,j,l) = 0;
        A_rh(row_counter,:) = struct_to_vector(Aineq)';
        row_counter = row_counter + 1;
      end
    end
  end
  b_rh = b_rh(:);
  
  A_ss_box = [A_lh; A_rh];
  b_ss_box = [b_lh; b_rh];
  
end

