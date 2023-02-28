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
