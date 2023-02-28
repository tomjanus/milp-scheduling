% Run functions testing the correctness of MILP formulation for the 2p1t system
sparse_out = 1;

% Initialize variable structures required to run the MILP pump scheduling problem
[sim_input,const,linprog,network,sim,pump_groups] = initialise_2p1t();
output = simulator_2p1t(sim_input.init_schedule, network, sim_input, sim);
% Find q_op and s_op at 12
pump_speed_12 = sim_input.init_schedule.S(12);
pump_flow_12 = output.q(2,12)/sim_input.init_schedule.N(12);

vars = initialise_var_structure(network, linprog);
intcon_vector = set_intcon_vector(vars);
c_vector = set_objective_vector(vars, network, sim_input, linprog, true);
% Get variable (box) constraints for the two pump one tank network
constraints = set_constraints_2p1t(network);
[lb_vector, ub_vector] = set_variable_bounds(vars, constraints);
% Linearize the pipe and pump elements
lin_pipes = linearize_pipes_2p1t(network, output);
lin_pumps = linearize_pumps_2p1t(pump_groups);
% Linearize the power consumption model
% lin_power = linearize_pump_power_2p1t(pump_groups, pump_flow_12, ...
%    pump_speed_12);
% Linearize pump model with dummy constraints and domain vertices 
% (as not relevant for linearization)
constraint_signs = {'>', '<', '<', '>'};
domain_vertices = {[0,0], [0,0], [0,0], [0,0]};
lin_power = linearize_power_model(pump_groups(1).pump, pump_flow_12, pump_speed_12, ...
    domain_vertices, constraint_signs);
% Set the inequality constraints A and b
[A, b] = set_A_b_matrices(vars, linprog, lin_power, lin_pipes, ...
    lin_pumps, pump_groups, sparse_out);
% Set the equality constraints Aeq and beq
[Aeq, beq] = set_Aeq_beq_matrices(vars, network, sim_input, lin_pipes,...
    sparse_out);
    
% Run checks and generate reports for manual inspection and debugging
check_inequality_constraints(vars, linprog, lin_power, lin_pipes, lin_pumps, pump_groups);
check_equality_constraints(network, vars, lin_pipes, sim_input);
check_intcon_vector(intcon_vector, vars);
check_c_vector(c_vector, vars);
check_lb_vector(lb_vector, vars);
check_ub_vector(ub_vector, vars);
