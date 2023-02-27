function [Aeq_ss, beq_ss] = ss_constraints(vars)
  % Applies constraints to pump segment speeds
  % for all pumps for all time steps = 1:K, sum_i ss_i^j(k) - s_j(k) = 0
  % Args:
  % vars: variables structure with the variables that are ultimately converted
  %       onto the variable vector x
  
  number_time_steps = size(vars.x_cont.ss, 2);
  number_pumps = size(vars.x_cont.ss, 3);
  number_segments = size(vars.x_cont.ss, 1);
  % Initialize output arrays
  Aeq_ss = zeros(number_time_steps*number_pumps, var_struct_length(vars));
  beq_ss = zeros(number_time_steps,number_pumps);
  row_counter = 1;
  for j = 1:number_pumps
      for i = 1:number_time_steps
        Aeq = vars;
        Aeq.x_cont.ss(:,i,j) = -1;
        Aeq.x_cont.s(i,j) = 1;
        Aeq_ss(row_counter,:) = struct_to_vector(Aeq)';
        beq_ss(i,j)=0;
        row_counter = row_counter + 1;
      end
   end
   beq_ss = beq_ss(:);
end