function [Aeq, beq] = set_Aeq_beq_matrices(vars, network, input, lin_pipes, ...
                                           sparse_out)
  % Calculate all equality constraints and create Aeq and beq matrices
  [Aeq_ht, beq_ht] = ht_constraints(vars, network);
  [Aeq_qpipe, beq_qpipe] = ww_constraints(vars, network);
  [Aeq_bb, beq_bb] = bb_constraints(vars);
  [Aeq_dhpipe, beq_dhpipe] = pipe_headloss_constraints(vars, network, ...
    input, lin_pipes);

  [Aeq_ss, beq_ss] = ss_constraints(vars);
  [Aeq_qq, beq_qq] = qq_constraints(vars);
  [Aeq_aa, beq_aa] = aa_constraints(vars);
  [Aeq_nodeq, beq_nodeq] = nodeq_constraints(vars, network, input);
  [Aeq_pumpgroup, beq_pumpgroup] = pumpgroup_constraints(vars, network);

  % Concatenate all Aeq matrices and beq vectors
  Aeq = [Aeq_ht; Aeq_qpipe; Aeq_bb; Aeq_dhpipe; Aeq_ss; Aeq_qq; Aeq_aa; ...
    Aeq_nodeq; Aeq_pumpgroup];
  beq = [beq_ht; beq_qpipe; beq_bb; beq_dhpipe; beq_ss; beq_qq; beq_aa; ...
    beq_nodeq; beq_pumpgroup];

  %Aeq = [Aeq_ht; Aeq_qpipe; Aeq_bb; Aeq_ss; Aeq_qq; Aeq_aa; Aeq_pumpgroup];
  %beq = [beq_ht; beq_qpipe; beq_bb; beq_ss; beq_qq; beq_aa; beq_pumpgroup];

  Aeq = [Aeq_qpipe; Aeq_nodeq; Aeq_pumpgroup];
  beq = [beq_qpipe; beq_nodeq; beq_pumpgroup];

  if (sparse_out == true)
    Aeq = sparse(Aeq);
    beq = sparse(beq);
  end
end

function [Aeq_ht, beq_ht] = ht_constraints(vars, network)
  % Set the equality constraints determining the water mass balance
  % in the tank(s) for all time steps except the first. In the first time-step
  % tank heads ht_i(k) for i = 1:Ntanks are set to ht_init, i.e. the initial
  % heads.
  % Map equation: ht(k) - ht(k-1) - 1/At q_tank(k) == 0 for k = 2:N_TIMESTEPS
  %               ht(1) = tank_elevation + init_level

  % Args:
  % vars: variables structure with the variables that are ultimately converted
  %       onto the variable vector x
  % network: structure with network variables
  
  % TODO: Expand this code to multiple tanks
  tank = network.tanks(1);

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
      Aeq.x_cont.qel(i, network.elements.tank_feed_pipe_index) = -1/tank.area;
      beq = 0;
    end
    Aeq_ht(i,:) = struct_to_vector(Aeq)';
    beq_ht(i) = beq;
  end
end

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

function [Aeq_aa, beq_aa] = aa_constraints(vars)
  % Applies constraints to pump segment selection variables aa
  % for all k = 1..K for all j in E_{pump} \sum_i^{n_seg} aa_i^j - n_j = 0
  
  % Args:
  % vars: variables structure with the variables that are ultimately converted
  %       onto the variable vector x
  
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
        Aeq.x_bin.n(i,j) = -1;
        Aeq_aa(row_counter,:) = struct_to_vector(Aeq)';
        beq_aa(i,j)=0;
        row_counter = row_counter + 1;
      end
  end
  beq_aa = beq_aa(:);
end

function [Aeq_nodeq, beq_nodeq] = nodeq_constraints(vars, network, input)
  % Apply flow constraints to all nodal flows
  % For every node j for all time steps k = 1 .. N 
  %                               \sum q_{in}^j (k) + \sum q_{out}^j (k) = 0 
  Lc = network.Lc;
  no_equalities = size(Lc,1);
  number_time_steps = size(vars.x_cont.qel,1);
  % Initialize output arrays
  Aeq_nodeq = zeros(no_equalities*number_time_steps, var_struct_length(vars));
  beq_nodeq = zeros(no_equalities, number_time_steps);
  row_counter = 1;
  for j = 1:no_equalities
    for i = 1:number_time_steps
      Aeq=vars;
      in_flows = find(Lc(j,:)==1);
      out_flows = find(Lc(j,:)==-1);
      Aeq.x_cont.qel(i,in_flows) = 1;
      Aeq.x_cont.qel(i,out_flows) = -1;
      d_ji = input.demands(j,i);
      Aeq_nodeq(row_counter,:) = struct_to_vector(Aeq)';
      beq_nodeq(j,i)=d_ji;
      row_counter = row_counter + 1;
    end
  end
  beq_nodeq = beq_nodeq(:);
end

function [Aeq_pumpgroup, beq_pumpgroup] = pumpgroup_constraints(vars, network)
  % Apply constraints linking flows in pump groups to flows in (individual) pumps
  % For each pump group j in E_{pump_group} \sum_i^j (q_i^j) * n_i^j = q_{pumpgroup}
  % for j in E_{pumps, j}
  no_pump_groups = length(network.pump_groups);
  number_time_steps = size(vars.x_cont.qel, 1);
  Aeq_pumpgroup = zeros(no_pump_groups * number_time_steps, ...
                        var_struct_length(vars));
  beq_pumpgroup = zeros(no_pump_groups, number_time_steps);
  row_counter = 1;
  pump_flow_index = 1;
  for j = 1:no_pump_groups
    for i = 1:number_time_steps
      Aeq=vars;
      pump_group_index = network.pump_groups(j).element_index;
      % Make this code generalize for more pump groups
      npumps = network.pump_groups(j).npumps;
      Aeq.x_cont.qel(i,pump_group_index) = 1;
      Aeq.q_cont.q(i,pump_flow_index:npumps) = -1; 
      beq_pumpgroup(j,i)=0;
      Aeq_pumpgroup(row_counter,:) = struct_to_vector(Aeq)';
      row_counter = row_counter + 1;
    end
    pump_flow_index = pump_flow_index + npumps;
  end
  beq_pumpgroup = beq_pumpgroup(:);
end
