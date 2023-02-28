function [A_pipe, b_pipe] = pipe_flow_segment_constraints(vars, lin_pipes, linprog)
  % Set the inequality constraints for pipr segment flows
  % bb(i,k,j) * q*(i-1,j) <= ww(i,k,j) <= bb(i,k,j) * q*(i,j)
  % where q* flows are the boundary points defining the `domains` of validity
  % for each segment in the linearized pipe characteristic.
  % Number of inequalities are equal to n_pipes * n_segments * N * 2 where the
  % last coefficient 2 describes the fact that we have two inequalities per
  % equation: the lower bound and the upper bound.
  
  % LH inequality:
  % -wwij(k) + bbij(k) qj(i-1)* <= 0 
  % RH inequality:
  % wwij(k) - bbij(k) qj(i)* <= 0 
  number_time_steps = size(vars.x_cont.ww, 2);
  number_pipes = size(vars.x_cont.ww, 3);
  
  A_lh = zeros(number_time_steps*number_pipes*linprog.NO_PIPE_SEGMENTS,...
    var_struct_length(vars));
  A_rh = zeros(number_time_steps*number_pipes*linprog.NO_PIPE_SEGMENTS,...
    var_struct_length(vars));
  
  b_lh = zeros(number_time_steps, number_pipes, linprog.NO_PIPE_SEGMENTS);
  b_rh = zeros(number_time_steps, number_pipes, linprog.NO_PIPE_SEGMENTS);
  
  %LHS inequality
  row_counter = 1;
  for i = 1:linprog.NO_PIPE_SEGMENTS
    for j = 1:number_pipes
      for k = 1:number_time_steps
        left_limit = lin_pipes{j}(i).limits{1}(1);
        Aineq = vars;
        Aineq.x_cont.ww(i,k,j) = -1;
        Aineq.x_bin.bb(i,k,j) = left_limit;
        b_lh(k,j,i) = 0;
        A_lh(row_counter,:) = struct_to_vector(Aineq)';
        row_counter = row_counter + 1;
      end
    end
  end
  b_lh = b_lh(:);
  
  %RHS inequality
  row_counter = 1;
  for i = 1:linprog.NO_PIPE_SEGMENTS
    for j = 1:number_pipes
      for k = 1:number_time_steps
        right_limit = lin_pipes{j}(i).limits{2}(1);
        Aineq = vars;
        Aineq.x_cont.ww(i,k,j) = +1;
        Aineq.x_bin.bb(i,k,j) = -right_limit;
        b_rh(k,j,i) = 0;
        A_rh(row_counter,:) = struct_to_vector(Aineq)';
        row_counter = row_counter + 1;
      end
    end
  end
  b_rh = b_rh(:);
  
  A_pipe = [A_lh; A_rh];
  b_pipe = [b_lh; b_rh];
  
end

