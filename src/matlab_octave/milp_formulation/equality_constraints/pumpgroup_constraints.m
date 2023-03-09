function [Aeq_pumpgroup, beq_pumpgroup] = pumpgroup_constraints(vars, network)
  % Apply constraints linking flows in pump groups to flows in (individual) pumps
  % For each pump group j in E_{pump_group} \sum_i^j (q_i^j) * n_i^j = q_{pumpgroup}
  % for j in E_{pumps, j}
  no_pump_groups = length(network.pump_groups);
  number_time_steps = size(vars.x_cont.qel, 1);
  Aeq_pumpgroup = zeros(no_pump_groups * number_time_steps, ...
                        var_struct_length(vars));
  beq_pumpgroup = zeros(no_pump_groups, number_time_steps)';
  row_counter = 1;
  pump_flow_index = 1;
  for j = 1:no_pump_groups
    for i = 1:number_time_steps
      Aeq=vars;
      pump_group_index = network.pump_groups(j).element_index;
      % Make this code generalize for more pump groups
      npumps = network.pump_groups(j).npumps;
      Aeq.x_cont.qel(i,pump_group_index) = 1;
      Aeq.x_cont.q(i,pump_flow_index:npumps) = -1; 
      beq_pumpgroup(i,j)=0;
      Aeq_pumpgroup(row_counter,:) = struct_to_vector(Aeq)';
      row_counter = row_counter + 1;
    end
    pump_flow_index = pump_flow_index + npumps;
  end
  beq_pumpgroup = tensor_to_vector(beq_pumpgroup);
end
