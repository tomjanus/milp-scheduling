function [Aeq_qpipe, beq_qpipe] = ww_constraints(vars, network)
  % For each pipe the flow qel that represents a pipe (note: qel represents 
  % flows in pipes and pump groups) has to be equal to the sum of segment flows 
  % qpipe_j(k) - \sum_i w{i,j}(k) = 0 for all pipe segments i for all pipes j
  % and all time steps k = 1 : K
  % where qpipe(j) = qel(pipe_indices(j)), i.e. pipe flows are stored within the
  % vector of elements flows qel
  
  % Args:
  % vars: variables structure with the variables that are ultimately converted
  %       onto the variable vector x
  % network: structure with network variables
  
  number_time_steps = size(vars.x_cont.qel, 1);
  number_pipes = length(network.pipe_indices);
  
  % Initialize output arrays
  Aeq_qpipe = zeros(number_time_steps*number_pipes, var_struct_length(vars));
  beq_qpipe = zeros(number_time_steps,number_pipes);

  row_counter = 1;
  for j = 1:number_pipes
    pipe_index = network.pipe_indices(j); % Pipe index in the vector of element flows qel
    for i = 1:number_time_steps
      Aeq = vars;
      Aeq.x_cont.qel(i,pipe_index) = 1;
      Aeq.x_cont.ww(:,i,j) = -1;
      beq = 0;
      % Add the new matrix and vector to the output arrays
      Aeq_qpipe(row_counter,:) = struct_to_vector(Aeq)';
      beq_qpipe(i,j)=beq;
      row_counter = row_counter + 1;
    end
  end
  % Roll out the beq vector
  beq_qpipe = beq_qpipe(:);

end