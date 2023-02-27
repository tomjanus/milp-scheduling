function [Aeq_bb, beq_bb] = bb_constraints(vars)
  % Sum of bb variables bb_i^j(k) over all segments i for each pipe j for every 
  % time step k = 1...K == 1 
  
  % Args:
  % vars: variables structure with the variables that are ultimately converted
  %       onto the variable vector x
  
  number_time_steps = size(vars.x_bin.bb, 2);
  number_pipes = size(vars.x_bin.bb, 3);
  number_segments = size(vars.x_bin.bb, 1);
  
  % Initialize output arrays
  Aeq_bb = zeros(number_time_steps*number_pipes, var_struct_length(vars));
  beq_bb = zeros(number_time_steps,number_pipes);
  row_counter = 1;
  for j = 1:number_pipes
    for i = 1:number_time_steps
      Aeq = vars;
      Aeq.x_bin.bb(:,i,j) = 1;
      beq = 1;
      % Add the new matrix and vector to the output arrays
      Aeq_bb(row_counter,:) = struct_to_vector(Aeq)';
      beq_bb(i,j)=beq;
      row_counter = row_counter + 1;
    end
  end
  % Roll out the beq vector
  beq_bb = beq_bb(:);
end