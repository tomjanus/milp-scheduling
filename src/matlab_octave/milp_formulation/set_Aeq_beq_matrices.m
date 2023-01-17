function [Aeq, beq] = set_Aeq_beq_matrices(vars, network, tank, input, ...
      lin_pipes, sparse_out)
  % Calculate all equality constraints and create Aeq and beq matrices
  [Aeq_ht, beq_ht] = ht_constraints(vars, network, tank);
  [Aeq_qpipe, beq_qpipe] = ww_constraints(vars);
  [Aeq_bb, beq_bb] = bb_constraints(vars);
  [Aeq_dhpipe, beq_dhpipe] = pipe_headloss_constraints(vars, network, ...
    input, lin_pipes);
  [Aeq_ss, beq_ss] = ss_constraints(vars);
  [Aeq_qq, beq_qq] = qq_constraints(vars);
  [Aeq_aa, beq_aa] = aa_constraints(vars);

  % Concatenate all Aeq matrices and beq vectors
  Aeq = [Aeq_ht; Aeq_qpipe; Aeq_bb; Aeq_dhpipe; Aeq_ss; Aeq_qq; Aeq_aa];
  beq = [beq_ht; beq_qpipe; beq_bb; beq_dhpipe; beq_ss; beq_qq; beq_aa];

  if (sparse_out == true)
    Aeq = sparse(Aeq);
    beq = sparse(beq);
  end
end

function [Aeq_ht, beq_ht] = ht_constraints(vars, network, tank)
  % Set the equality constraints determining the water mass balance
  % in the tank(s) for all time steps except the first. In the first time-step
  % tank heads ht_i(k) for i = 1:Ntanks are set to ht_init, i.e. the initial
  % heads.
  % Map equation: ht(k) - ht(k-1) - 1/At q_tank(k) == 0 for k = 2:N_TIMESTEPS

  % Args:
  % vars: variables structure with the variables that are ultimately converted
  %       onto the variable vector x
  % tank: struture with tank properties
  % init_level: initial tank level(s) - currently only a single tank is supported

  number_time_steps = size(vars.x_cont.ht, 1);
  % Initialize output arrays
  Aeq_ht = zeros(number_time_steps, var_struct_length(vars));
  beq_ht = zeros(number_time_steps, 1);

  for i = 1:number_time_steps
    Aeq = vars;
    Aeq.x_cont.ht(i) = 1;
    if i == 1
      % Set initial condition for tank elevation
      beq = tank.elevation + tank.init_level;
    else
      Aeq.x_cont.ht(i-1)=-1;
      Aeq.x_cont.qpipe(i, network.pipes.tank_feed_pipe_index) = -1/tank.area;
      beq = 0;
    end
    Aeq_ht(i,:) = struct_to_vector(Aeq)';
    beq_ht(i) = beq;
  end
end

function [Aeq_qpipe, beq_qpipe] = ww_constraints(vars)
  % For each pipe the flow qpipe has to be equal to the sum of segment flows w
  number_time_steps = size(vars.x_cont.qpipe, 1);
  number_pipes = size(vars.x_cont.qpipe, 2);
  % Initialize output arrays
  Aeq_qpipe = zeros(number_time_steps*number_pipes, var_struct_length(vars));
  beq_qpipe = zeros(number_time_steps,number_pipes);

  row_counter = 1;
  for j = 1:number_pipes
    for i = 1:number_time_steps
      Aeq = vars;
      Aeq.x_cont.qpipe(i,j) = 1;
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

function [Aeq_bb, beq_bb] = bb_constraints(vars)
  %
  number_time_steps = size(vars.x_cont.ww, 2);
  number_pipes = size(vars.x_cont.ww, 3);
  number_segments = size(vars.x_cont.ww, 1);
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

function [Aeq_dhpipe, beq_dhpipe] = pipe_headloss_constraints(vars, network, ...
    input, lin_pipes)
  % Applies the pipe headloss equality condition for each pipe j and each time
  % step k
  %
  % h_o^j(k) − h_d^j (k) − sum_i {m_i^j * ww_i^j} - sum_i {c_i^j * bb_i^j} = 0
  number_time_steps = size(vars.x_cont.ww, 2);
  number_pipes = size(vars.x_cont.ww, 3);
  number_segments = size(vars.x_cont.ww, 1);
  % Prepare incidence matrices without non-pipe elements
  Lc = remove_columns(network.Lc, network.elements.pump_index);
  Lf = remove_columns(network.Lf, network.elements.pump_index);
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
      % This bit is not generic, and repetitive
      % TODO: fi[Aeq_aa, beq_aa] = aa_constraints(vars)x later with a better data structure
      switch index_up_head
        case num2cell(1:L.limits.Lc(end))
          Aeq.x_cont.hc(i,j) = 1;
          beq = 0;
        case L.limits.Lf(1)
          % reservoir
          Aeq.x_cont.ht(i) = 1;
          beq = 0;
        case L.limits.Lf(1) + 1
          % tank
          beq = - input.hr;
      end

      switch index_down_head
        case num2cell(1:L.limits.Lc(end))
          Aeq.x_cont.hc(i,j) = -1;
          beq = 0;
        case L.limits.Lf(1)
          % reservoir
          Aeq.x_cont.ht(i) = -1;
          beq = 0;
        case L.limits.Lf(1) + 1
          % tank
          beq = input.hr;
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
  beq_dhpipe = beq_dhpipe(:);
end

function [Aeq_ss, beq_ss] = ss_constraints(vars)
  % Prepare constraints that pump speed s is equal to sum of segment speeds ss
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

function [Aeq_qq, beq_qq] = qq_constraints(vars)
  % Prepare constraints that pump flow q is equal to sum of segment flows qq
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

function [Aeq_aa, beq_aa] = aa_constraints(vars)
  % Implements a constraint where the sum of aa elements in each pump in each
  % time step is equal to the number of active pumps n
  number_time_steps = size(vars.x_bin.aa, 2);
  number_pumps = size(vars.x_bin.n, 2);
  number_segments = size(vars.x_bin.aa, 1);
  % Initialize output arrays
  Aeq_aa = zeros(number_time_steps*number_pumps, var_struct_length(vars));
  beq_aa = zeros(number_time_steps,number_pumps);
  row_counter = 1;
  % TODO: This loop will need to be generalized into groups and pumps per group
  %       and the variable n will have to be a 3D array with additional
  %       dimension defining every pump group in the model
  for j = 1:number_pumps
      for i = 1:number_time_steps
        Aeq = vars;
        Aeq.x_bin.aa(:,i,j) = 1;
        Aeq.x_bin.n(i,:) = -1;
        Aeq_aa(row_counter,:) = struct_to_vector(Aeq)';
        beq_aa(i,j)=0;
        row_counter = row_counter + 1;
      end
  end
  beq_aa = beq_aa(:);
end
