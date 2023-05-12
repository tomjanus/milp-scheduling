function [A, b] = set_A_b_matrices(vars, linprog, lin_power, lin_pipes, ...
      lin_pumps, pump_groups, sparse_out)
  % Calculate all inequality constraints and create A and b matrices
  [A_p, b_p] = power_ineq_constraint(vars, linprog);
  [A_p_lin, b_p_lin] = power_model_ineq_constraint(vars, lin_power, linprog);
  [A_pipe, b_pipe] = pipe_flow_segment_constraints(vars, lin_pipes, linprog);
  [A_s_box, b_s_box] = s_box_constraints(vars, pump_groups, linprog);
  [A_q_box, b_q_box] = q_box_constraints(vars, pump_groups, linprog);
  [A_pumpeq, b_pumpeq] = pump_equation_constraints(vars, linprog, lin_pumps);
  [A_pump_domain, b_pump_domain] = pump_domain_constraints(vars, linprog, ...
      lin_pumps);
  [A_pumpsymmetry, b_pumpsymmetry] = pump_symmetry_breaking(vars);
    
  A = [A_p; A_p_lin; A_pipe; A_s_box; A_q_box; A_pumpeq; A_pump_domain; A_pumpsymmetry];
  b = [b_p; b_p_lin; b_pipe; b_s_box; b_q_box; b_pumpeq; b_pump_domain; b_pumpsymmetry];
  
  
  if (sparse_out == true)
    A = sparse(A);
    b = sparse(b);
  end
end
