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
