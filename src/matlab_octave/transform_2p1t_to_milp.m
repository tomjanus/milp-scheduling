function lin_model = transform_2p1t_to_milp(...
    input, linprog, network, pump_groups, init_sim_output, ...
    save_to_mps, save_to_mat, var_names, final_water_level)
  % Process the 2p1t model and create a mixed integer linear programme
  % representation (lin_model). Save to mps file and/or mat file
  % when required (if save_to_mps and save_to_mat respectively, are set to tru)
  sparse_out = 1;  
  % Find q_op and s_op at 12
  pump_speed_12 = input.init_schedule.S(12);
  pump_flow_12 = init_sim_output.q(2,12)/input.init_schedule.N(12);
  pump_speed_nominal = 1;
  pump_flow_max_eff = pump_groups.pump.max_eff_flow;
  % Step 4 - Formulate linear program
  % Initialise continuous and binary variable structures
  vars = initialise_var_structure(network, linprog);
  % Set the vector of indices of binary variables in the vector of decision variables x
  intcon_vector = set_intcon_vector(vars);
  % Set the vector of objective function coefficients c
  c_vector = set_objective_vector(vars, network, input, linprog, true);
  % Get variable (box) constraints for the two pump one tank network
  constraints = set_constraints_2p1t(network);
  [lb_vector, ub_vector] = set_variable_bounds(vars, constraints, final_water_level); % Hard coded initial water level
  % Linearize the pipe and pump elements
  lin_pipes = linearize_pipes_2p1t(network, init_sim_output);
  lin_pumps = linearize_pumps_2p1t(pump_groups);
  % Linearize the power consumption model
  % lin_power = linearize_pump_power_2p1t(pump_groups, pump_flow_12, ...
  %    pump_speed_12);
  % Linearize pump model with dummy constriants and domain vertices 
  % (as not relevant for linearization)
  constraint_signs = {'>', '<', '<', '>'};
  domain_vertices = {[0,0], [0,0], [0,0], [0,0]}; % Dummy variable due to the fact that linearize_power_model requires (any) input but in this case the variable does not do anything
  lin_power = linearize_power_model(pump_groups(1).pump, pump_flow_12, ...
      pump_speed_12, domain_vertices, constraint_signs);
  % Set the inequality constraints A and b
  [A, b] = set_A_b_matrices(vars, linprog, lin_power, lin_pipes, ...
      lin_pumps, pump_groups, sparse_out);
  % Set the equality constraints Aeq and beq
  [Aeq, beq] = set_Aeq_beq_matrices(vars, network, input, lin_pipes,...
      sparse_out);
  % Convert all individual matrices and vectors to a linear model structure
  lin_model.c_vector = c_vector;
  lin_model.A = A;
  lin_model.b = b;
  lin_model.Aeq = Aeq;
  lin_model.beq = beq;
  lin_model.lb = lb_vector;
  lin_model.ub = ub_vector;
  lin_model.intcon = intcon_vector;
  % Save to mps standard file, if save_to_mps is True
  % TODO: Add 'EleNames', 'EqtNames' for inequality and equality constraint names, respectively
  if save_to_mps == true
      if var_names == true
        % Create a cell with Variable names
        for ix=1:length(c_vector)
          variable = map_lp_vector_index_to_var(vars, ix);
          var_name = variable.subfield_name;
          var_subscript = strjoin(string(variable.index), '_');
          var_with_subscript = strjoin([var_name, var_subscript], '');
          if ix == 1
            var_names = {var_with_subscript};
          else
            var_names(end+1) = {var_with_subscript};
          end
        end
        var_names = cellstr(var_names);
        mps_text = BuildMPS(A, b, Aeq, beq, c_vector, lb_vector, ...
          ub_vector, 'MILP_Scheduler_2p1t', 'I', intcon_vector,...
          'VarNames', var_names);
      else
        mps_text = BuildMPS(A, b, Aeq, beq, c_vector, lb_vector, ...
          ub_vector, 'MILP_Scheduler_2p1t', 'I', intcon_vector);
      end 
      OK = SaveMPS('../python/data/2p1t/2p1t.mps', mps_text);
  end
  % Save to a mat file if save_to_map is True
  if save_to_mat == true
      save('../python/data/2p1t/2p1t_model.mat', '-struct', 'lin_model');
  end
