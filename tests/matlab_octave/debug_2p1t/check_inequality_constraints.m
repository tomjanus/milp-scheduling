function y = check_inequality_constraints(vars, linprog, lin_power, lin_pipes, lin_pumps, pump_groups)
    % Calculate network inequality constraints
    [A_p, b_p] = power_ineq_constraint(vars, linprog);
    [A_p_lin, b_p_lin] = power_model_ineq_constraint(vars, lin_power, linprog); 
    [A_pipe, b_pipe] = pipe_flow_segment_constraints(vars, lin_pipes, linprog);
    [A_ss_box, b_ss_box] = ss_box_lin_constraints(vars, pump_groups, linprog);
    [A_qq_box, b_qq_box] = qq_box_lin_constraints(vars, pump_groups, linprog);
    [A_pumpeq, b_pumpeq] = pump_equation_constraints(vars, linprog, lin_pumps);
    [A_pump_domain, b_pump_domain] = pump_domain_constraints(vars, linprog, ...
        lin_pumps);
      
    % Create reports
    eq_ineq_constraint_report(...
        "Power inequality constraints", ...
        "reports/inequality/power_ineq_constraint.report", ...
        A_p, b_p, vars);
    eq_ineq_constraint_report(...
        "Linear power model inequality constraints", ...
        "reports/inequality/power_model_ineq_constraint.report", ...
        A_p_lin, b_p_lin, vars);
    eq_ineq_constraint_report(...
        "Pipe flow segment inequality constraints", ...
        "reports/inequality/pipe_flow_segment_ineq_constraint.report", ...
        A_pipe, b_pipe, vars);
    eq_ineq_constraint_report(...
        "Linearized pump speed inequality constraints", ...
        "reports/inequality/ss_box_lin_ineq_constraint.report", ...
        A_ss_box, b_ss_box, vars);
    eq_ineq_constraint_report(...
        "Linearized pump flow inequality constraints", ...
        "reports/inequality/qq_box_lin_ineq_constraint.report", ...
        A_qq_box, b_qq_box, vars);
    eq_ineq_constraint_report(...
        "Pump equation inequality constraints", ...
        "reports/inequality/pump_equation_ineq_constraint.report", ...
        A_pumpeq, b_pumpeq, vars);
    eq_ineq_constraint_report(...
        "Pump domain inequality constraints", ...
        "reports/inequality/pump_domain_ineq_constraint.report", ...
        A_pump_domain, b_pump_domain, vars);
end