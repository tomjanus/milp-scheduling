function out = linearize_power_pumps(pump_groups, q_op, s_op)
  % Linearizes power comsumption for all pump (groups) in the network
  % Since all pumps in every pump group are assumed to be equal, linearization is
  % performed for a (representative) pump of each pump group.
  % Args:
  %   pump_groups - vector of structs of (representative) pumps for each pump group
  %   q_op, s_op = lists of operating points (q_op and s_op) - one per each group
  % Return:
  %   Cell of linearized pipe output structures
  number_pump_groups = length(pump_groups);
 
  if length(q_op) ~= length(s_op)
    error("Vectors of q and s coordinates of operating points not equal");
  end
  
  if length(q_op) == 1
    q_op = repmat(q_op, number_pump_groups, 1);
    s_op = repmat(s_op, number_pump_groups, 1);
  end
  
  if length(q_op) ~= number_pump_groups
    error("Number of operating points not equal to the number of pump groups");
  end

  out = cell(length(pump_groups));
  for i = 1:length(out)
    out{i} = pump_power_tangent(pump_groups(i).pump, q_op(i), s_op(i));
  end
end
