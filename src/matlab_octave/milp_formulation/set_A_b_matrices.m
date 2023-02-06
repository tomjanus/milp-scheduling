function [A, b] = set_A_b_matrices(vars, linprog, lin_power, lin_pipes, ...
      lin_pumps, pump_groups, sparse_out)
  % Calculate all inequality constraints and create A and b matrices
  [A_p, b_p] = power_ineq_constraint(vars, linprog);
  [A_p_lin, b_p_lin] = power_model_ineq_constraint(vars, lin_power, linprog);
  [A_pipe, b_pipe] = pipe_flow_segment_constraints(vars, lin_pipes, linprog);
  [A_ss_box, b_ss_box] = ss_box_lin_constraints(vars, pump_groups, linprog);
  [A_qq_box, b_qq_box] = qq_box_lin_constraints(vars, pump_groups, linprog);
  [A_pumpeq, b_pumpeq] = pump_equation_constraints(vars, linprog, lin_pumps);
  [A_pump_domain, b_pump_domain] = pump_domain_constraints(vars, linprog, ...
      lin_pumps);
    
  A = [A_p; A_p_lin; A_pipe; A_ss_box; A_qq_box; A_pumpeq; A_pump_domain];
  b = [b_p; b_p_lin; b_pipe; b_ss_box; b_qq_box; b_pumpeq; b_pump_domain];
  
  
  if (sparse_out == true)
    A = sparse(A);
    b = sparse(b);
  end
end

function [A_p, b_p] = power_ineq_constraint(vars, linprog)
  % Set the inequality constraints
  % p_j(k) - n_j(k) U_power <= 0            (1)
  % -p_j(k) <= 0                            (2)
  % for every pump j for every time step k
  % The inequality is used fo `binary linearisation’ of power consumption output
  % with respect to the pump (on/off) status.
  number_time_steps = size(vars.x_cont.p, 1);
  number_pumps =size(vars.x_cont.p, 2);

  % Initialize output arrays
  A_p = zeros(2*number_time_steps*number_pumps, var_struct_length(vars));
  b_p = zeros(number_time_steps,number_pumps, 2);
  
  row_counter = 1;
  % Eq. 1
  for j = 1:number_pumps
    for i = 1:number_time_steps
      Aineq = vars;
      Aineq.x_cont.p(i,j) = 1;
      Aineq.x_bin.n(i,j) = - linprog.Upower;
      bineq = 0;
      A_p(row_counter,:) = struct_to_vector(Aineq)';
      b_p(i,j,1)=bineq;
      row_counter = row_counter + 1;
    end
  end
  
  % Eq. 2
  for j = 1:number_pumps
    for i = 1:number_time_steps
      Aineq = vars;
      Aineq.x_cont.p(i,j) = -1;
      bineq = 0;
      A_p(row_counter,:) = struct_to_vector(Aineq)';
      b_p(i,j,2)=bineq;
      row_counter = row_counter + 1;      
    end
  end
  % Roll out the b vector
  b_p = b_p(:);
end

function [A_p_lin, b_p_lin] = power_model_ineq_constraint(vars, lin_power, linprog)
  % Implement the inequality constraints on pump power using the big U trick
  % - m_s * sj(k) - m_q * qj(k) + pj(k) + nj(k) Upower <= U_power + c (LH constraint)
  % m_s * sj(k) + m_q * qj(k) + -pj(k) + nj(k) Upower <= Upower -c (RH constraint)
  % Initialize the left and right hand constraints
  number_time_steps = size(vars.x_cont.p, 1);
  number_pumps =size(vars.x_cont.p, 2);
  A_lh = zeros(number_time_steps*number_pumps,var_struct_length(vars));
  A_rh = zeros(number_time_steps*number_pumps,var_struct_length(vars));
  b_lh = zeros(number_time_steps,number_pumps);
  b_rh = zeros(number_time_steps,number_pumps);
  
  m_dq = lin_power.coeff(1);
  m_ds = lin_power.coeff(2);
  c = lin_power.coeff(3);
  
  % LH inequality
  row_counter = 1;
  for j = 1:number_pumps
    for i = 1:number_time_steps
      Aineq = vars;
      Aineq.x_cont.s(i,j) = -m_ds;
      Aineq.x_cont.q(i,j) = -m_dq;
      Aineq.x_cont.p(i,j) = 1;
      Aineq.x_bin.n(i,j) = linprog.Upower;
      bineq = linprog.Upower + c;
      A_lh(row_counter,:) = struct_to_vector(Aineq)';
      b_lh(i,j)=bineq;
      row_counter = row_counter + 1;  
    end
  end
  % Roll out the b vector
  b_lh = b_lh(:);
  row_counter = 1;

  % RH inequality
  row_counter = 1;
  for j = 1:number_pumps
    for i = 1:number_time_steps
      Aineq = vars;
      Aineq.x_cont.s(i,j) = m_ds;
      Aineq.x_cont.q(i,j) = m_dq;
      Aineq.x_cont.p(i,j) = -1;
      Aineq.x_bin.n(i,j) = linprog.Upower;
      bineq = linprog.Upower - c;
      A_rh(row_counter,:) = struct_to_vector(Aineq)';
      b_rh(i,j)=bineq;
      row_counter = row_counter + 1;  
    end
  end
  % Roll out the b vector
  b_rh = b_rh(:);

  A_p_lin = [A_lh; A_rh];
  b_p_lin = [b_lh; b_rh];
end

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

function [A_qq_box, b_qq_box] = qq_box_lin_constraints(vars, pump_groups, linprog)
  % Binary linearize ss
  % 0 <= qqij(k) <= AAij(k) * qint,jmax
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
      qmin = 0;
      for k = 1:number_time_steps
        Aineq = vars;
        Aineq.x_cont.qq(i,k,j) = -1;
        b_lh(k,j,i) = qmin;
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
      qmax = pump_groups(1).pump.qint_smax;
      
      for k = 1:number_time_steps
        Aineq = vars;
        Aineq.x_cont.ss(i,k,j) = 1;
        Aineq.x_bin.aa(i,k,j) = -qmax;
        b_rh(k,j,i) = 0;
        A_rh(row_counter,:) = struct_to_vector(Aineq)';
        row_counter = row_counter + 1;
      end
    end
  end
  b_rh = b_rh(:);
  
  A_qq_box = [A_lh; A_rh];
  b_qq_box = [b_lh; b_rh];
  
end

function [A_pumpeq, b_pumpeq] = pump_equation_constraints(vars, linprog, ...
      lin_pumps)
  % Implements a linearized pump characteristic equation as an inequality
  % constraint
  % -(1-nj(k)) Upump <= 
  %   delta_hj(k)- SUM 
  % <= (1-nj(k))Upump
  % where SUM =  sum_{i=1}^{i=4}(ddi,j*ssi,j(k) + eei,j * qqi,j(k) + ffi,j * AAi,j(k))
  % The constraint expands to the following two <= constraints
  % LHS:
  %   - delta_hj(k) + SUM + nj(k) Upump <= Upump
  % RHS:
  %   + delta_hj(k) - SUM + nj(k) Upump <= Upump
  no_pumps = size(vars.x_bin.n, 2);
  no_segments = linprog.NO_PUMP_SEGMENTS;
  no_time_steps = size(vars.x_cont.hc,1);
  number_of_constraints = 2 * no_pumps * no_time_steps;
  
  A_lh = zeros(no_pumps * no_time_steps, var_struct_length(vars));
  A_rh = zeros(no_pumps * no_time_steps, var_struct_length(vars));
  b_lh = zeros(no_time_steps, no_pumps);
  b_rh = zeros(no_time_steps, no_pumps);
  
  % TODO: Write function for finding pumps upstream and downstream node
  % and their indices in the L matrix from the information stored in the
  % network struct and in the incidence matrices (Lf, Lc, and L)
  % CURRENTLY HARD CODED
  % hup = hc(1);
  % hdown = hc(2);
  
  % TODO: Adapt code to process pumps from multiple pump groups
  % Currently, only one pump group is supported
  lin_pump_model = lin_pumps{1};
  
  index_hup = 1; % in hc
  index_hdown = 2; % in hc

  %LHS inequality
  row_counter = 1;
  for j = 1:no_pumps
    for k = 1:no_time_steps
      Aineq = vars;
      Aineq.x_cont.hc(k, index_hup) = -1;
      Aineq.x_cont.hc(k, index_hdown) = 1;
      Aineq.x_bin.n(k,j) = linprog.Upump;
      % Get the linearized pump characteristics for all discretized regions
      for i = 1:no_segments
        coeffs = lin_pump_model(i).coeffs;
        A_ineq.x_cont.qq(i,k,j) = coeffs(1);
        A_ineq.x_cont.ss(i,k,j) = coeffs(2);
        A_ineq.x_bin.aa(i,k,j) = coeffs(3);
      end
      b_lh(k,j) = linprog.Upump;
      A_lh(row_counter,:) = struct_to_vector(Aineq)';
      row_counter = row_counter + 1;
    end
  end
  b_lh = b_lh(:);
  
  %RHS inequality
  row_counter = 1;
  row_counter = 1;
  for j = 1:no_pumps
    for k = 1:no_time_steps
      Aineq = vars;
      Aineq.x_cont.hc(k, index_hup) = 1;
      Aineq.x_cont.hc(k, index_hdown) = -1;
      Aineq.x_bin.n(k,j) = linprog.Upump;
      % Get the linearized pump characteristics for all discretized regions
      for i = 1:no_segments
        coeffs = lin_pump_model(i).coeffs;
        A_ineq.x_cont.qq(i,k,j) = -coeffs(1);
        A_ineq.x_cont.ss(i,k,j) = -coeffs(2);
        A_ineq.x_bin.aa(i,k,j) = -coeffs(3);  
      end
      b_rh(k,j) = linprog.Upump;
      A_rh(row_counter,:) = struct_to_vector(Aineq)';
      row_counter = row_counter + 1;
    end
  end 
  b_rh = b_rh(:);

  A_pumpeq = [A_lh; A_rh];
  b_pumpeq = [b_lh; b_rh];
end

function [A_pump_domain, b_pump_domain] = pump_domain_constraints(vars, ...
    linprog, lin_pumps)
  % Constraints for each of the domains of the linerized pump characteristic
  % equation
  % Di,j * SQi,j(k) <= AAi,j * Ci,j
  no_pumps = size(vars.x_bin.n, 2);
  no_segments = linprog.NO_PUMP_SEGMENTS;
  no_time_steps = size(vars.x_cont.hc,1);
  no_sides = 3; % Sides of a triangular facet
  
  A_pump_domain = zeros(no_time_steps * no_pumps * no_segments * no_sides, ...
    var_struct_length(vars));
  b_pump_domain = zeros(no_sides, no_time_steps, no_pumps, no_segments);
  
  % TODO: Adapt code to process pumps from multiple pump groups
  % Currently, only one pump group is supported
  lin_pump_model = lin_pumps{1};
  
  row_counter = 1;
  for i = 1:no_segments
    constraints = lin_pump_model(i).constraints;
    for j = 1:no_pumps
      for k = 1:no_time_steps
        for l = 1:no_sides
          Aineq = vars;
          % Add inequality constraints
          sign = constraints{l}{2};
          m_q = constraints{l}{1}(1);
          m_s = constraints{l}{1}(2);
          c = constraints{l}{1}(3);
          if sign == '>'
            % Invert signs if inequality is greater than because by convention
            % the inequalities in our linprog formulatin are of the form '<='
            m_q = -m_q;
            m_s = -m_s;
            c = -c;
          end
          Aineq.x_cont.qq(i,k,j) = m_q;
          Aineq.x_cont.ss(i,k,j) = m_s;
          Aineq.x_bin.aa(i,k,j) = -c;
          b_pump_domain(l,k,j,i) = 0;
          A_pump_domain(row_counter,:) = struct_to_vector(Aineq)';
          row_counter = row_counter + 1;
        end
      end
    end
  end
  b_pump_domain = b_pump_domain(:);
  
end