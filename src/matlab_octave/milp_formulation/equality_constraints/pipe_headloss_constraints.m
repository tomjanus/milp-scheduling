function [Aeq_dhpipe, beq_dhpipe] = pipe_headloss_constraints(vars, network, ...
    input, lin_pipes)
  % Applies the pipe headloss equality condition for each pipe j and each time
  % step k
  % h_o^j(k) − h_d^j (k) − sum_i {m_i^j * ww_i^j} - sum_i {c_i^j * bb_i^j} = 0
  
  % Args:
  % vars: variables structure with the variables that are ultimately converted
  %       onto the variable vector x
  % network: structure with network variables
  % input: input structure
  % lin_pipes: array of structs obtained from `linearize_pipes` that contain
  %   information about line coefficients and limits of each segment of each
  %   linearized pipe in the network
  
  number_time_steps = size(vars.x_cont.ww, 2);
  number_pipes = size(vars.x_cont.ww, 3);
  number_segments = size(vars.x_cont.ww, 1);
  % Prepare incidence matrices without non-pipe elements
  % TODO: MAKE THIS CODE WORK WITH MORE THAN ONE PUMP GROUP
  % Remove column(s) from incidence matrices that correspond to pump group elements
  Lc = remove_columns(network.Lc, network.pump_group_indices(1));
  Lf = remove_columns(network.Lf, network.pump_group_indices(1));
  L = combine_incidence_matrices(Lc, Lf);
  % Initialize output arrays
  Aeq_dhpipe = zeros(number_time_steps*number_pipes, var_struct_length(vars));
  beq_dhpipe = zeros(number_time_steps,number_pipes);
  % Get the upstream and downstream head for each pipe
  row_counter = 1;
  for j = 1:number_pipes
    % Find the upstream and downstream head indices
    index_up_head = find(L.matrix(:,j)==-1);
    index_down_head = find(L.matrix(:,j)==1);
    for i = 1:number_time_steps
      Aeq = vars;
      beq = 0;
      % This bit is not generic, and repetitive
      % TODO: Provide a structure that contains information about which indices
      % Correspond to pipes/other elements and calculated nodes/tank nodes/reservoir nodes
      if (index_up_head <= L.limits.Lc(end)) && (index_up_head >= 1)
        Aeq.x_cont.hc(i,index_up_head) = 1;
        beq = 0;
      elseif (index_up_head == L.limits.Lf(1))
        % Reservoir
        beq = - input.hr;
      elseif (index_up_head == L.limits.Lf(2))
        % Tank
        Aeq.x_cont.ht(i) = 1;
        beq = 0;
      else
        error("Encountered unknown index %d in the incidence matrix", index_up_head);
      end
      % Same as above, but for downstream node indices
      if (index_down_head <= L.limits.Lc(end)) && (index_down_head >= 1)
        Aeq.x_cont.hc(i,index_down_head) = -1;
        beq = beq + 0;
      elseif (index_down_head == L.limits.Lf(1))
        beq = beq + input.hr;
      elseif (index_down_head == L.limits.Lf(2))
        Aeq.x_cont.ht(i) = -1;
        beq = beq + 0;
      else
        error("Encountered unknown index %d in the incidence matrix", index_down_head);
      end

      for k = 1:number_segments
        m = lin_pipes{1}(k).coeffs.m;
        c = lin_pipes{1}(k).coeffs.c;
        Aeq.x_cont.ww(k,i,j) = -m;
        Aeq.x_bin.bb(k,i,j) = -c;
      end
      % Add the new matrix and vector to the output arrays
      Aeq_dhpipe(row_counter,:) = struct_to_vector(Aeq)';
      beq_dhpipe(i,j)=beq;
      % Assign beq
      row_counter = row_counter + 1;
    end
  end
  % Roll out the beq vector
  beq_dhpipe = tensor_to_vector(beq_dhpipe);
end
