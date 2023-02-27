function [Aeq_qq, beq_qq] = qq_constraints(vars)
  % Applies constraints to pump segment flows
  % for all pumps for all time steps = 1:K, sum_i qq_i^j(k) - q_j(k) = 0
  % 
  % Args:
  % vars: variables structure with the variables that are ultimately converted
  %       onto the variable vector x
  
  number_time_steps = size(vars.x_cont.qq, 2);
  number_pumps = size(vars.x_cont.qq, 3);
  number_segments = size(vars.x_cont.qq, 1);
  % Initialize output arrays
  Aeq_qq = zeros(number_time_steps*number_pumps, var_struct_length(vars));
  beq_qq = zeros(number_time_steps,number_pumps);
  row_counter = 1;
  for j = 1:number_pumps
      for i = 1:number_time_steps
        Aeq = vars;
        Aeq.x_cont.qq(:,i,j) = -1;
        Aeq.x_cont.q(i,j) = 1;
        Aeq_qq(row_counter,:) = struct_to_vector(Aeq)';
        beq_qq(i,j)=0;
        row_counter = row_counter + 1;
      end
   end
   beq_qq = beq_qq(:);
end