function [A_s_box, b_s_box] = s_box_constraints(vars, pump_groups, linprog)
  % Binary linearize pump speed s
  % nj(k) * smin,j <= sj(k) <= nj(k) * smax,j
  number_pumps = size(vars.x_bin.n, 2);
  number_time_steps = size(vars.x_bin.n, 1);
  
  A_lh = zeros(number_time_steps*number_pumps, var_struct_length(vars));
  A_rh = zeros(number_time_steps*number_pumps, var_struct_length(vars));
  b_lh = zeros(number_time_steps, number_pumps);
  b_rh = zeros(number_time_steps, number_pumps);
  
  %LHS inequality
  row_counter = 1;
    for j = 1:number_pumps
      % TODO: Modify this to consider multiple pump groups
      smin = pump_groups(1).pump.smin;
      for k = 1:number_time_steps
        Aineq = vars;
        Aineq.x_cont.s(k,j) = -1;
        Aineq.x_bin.n(k,j) = smin;
        b_lh(k,j) = 0;
        A_lh(row_counter,:) = struct_to_vector(Aineq)';
        row_counter = row_counter + 1;
      end
    end
  b_lh = tensor_to_vector(b_lh);

  %RHS inequality
  row_counter = 1;
    for j = 1:number_pumps
      % TODO: Modify this to consider multiple pump groups
      smax = pump_groups(1).pump.smax;
      for k = 1:number_time_steps
        Aineq = vars;
        Aineq.x_cont.s(k,j) = 1;
        Aineq.x_bin.n(k,j) = -smax;
        b_rh(k,j) = 0;
        A_rh(row_counter,:) = struct_to_vector(Aineq)';
        row_counter = row_counter + 1;
      end
    end
  b_rh = tensor_to_vector(b_rh);
  
  A_s_box = [A_lh; A_rh];
  b_s_box = [b_lh; b_rh];
  
end

