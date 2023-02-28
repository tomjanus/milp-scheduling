function [A_ss_box, b_ss_box] = ss_box_lin_constraints(vars, pump_groups, linprog)
  % Binary linearize ss
  % AAij(k) * smin,j <= ssij(k) <= AAij(k) * smax,j
  number_pumps = size(vars.x_bin.n, 2);
  number_time_steps = size(vars.x_bin.n, 1);
  
  A_lh = zeros(number_time_steps*number_pumps*linprog.NO_PUMP_SEGMENTS,...
    var_struct_length(vars));
  A_rh = zeros(number_time_steps*number_pumps*linprog.NO_PUMP_SEGMENTS,...
    var_struct_length(vars));
  b_lh = zeros(number_time_steps, number_pumps, linprog.NO_PUMP_SEGMENTS);
  b_rh = zeros(number_time_steps, number_pumps, linprog.NO_PUMP_SEGMENTS);
  
  %LHS inequality
  row_counter = 1;
  for i = 1:linprog.NO_PUMP_SEGMENTS
    for j = 1:number_pumps
      
      % TODO: Modify this to consider multiple pump groups
      smin = pump_groups(1).pump.smin;
      
      for k = 1:number_time_steps
        Aineq = vars;
        Aineq.x_cont.ss(i,k,j) = -1;
        Aineq.x_bin.aa(i,k,j) = smin;
        b_lh(k,j,i) = 0;
        A_lh(row_counter,:) = struct_to_vector(Aineq)';
        row_counter = row_counter + 1;
      end
    end
  end
  b_lh = b_lh(:);

  %RHS inequality
  row_counter = 1;
  for i = 1:linprog.NO_PUMP_SEGMENTS
    for j = 1:number_pumps
      
      % TODO: Modify this to consider multiple pump groups
      smin = pump_groups(1).pump.smax;
      
      for k = 1:number_time_steps
        Aineq = vars;
        Aineq.x_cont.ss(i,k,j) = 1;
        Aineq.x_bin.aa(i,k,j) = -smin;
        b_rh(k,j,i) = 0;
        A_rh(row_counter,:) = struct_to_vector(Aineq)';
        row_counter = row_counter + 1;
      end
    end
  end
  b_rh = b_rh(:);
  
  A_ss_box = [A_lh; A_rh];
  b_ss_box = [b_lh; b_rh];
  
end

