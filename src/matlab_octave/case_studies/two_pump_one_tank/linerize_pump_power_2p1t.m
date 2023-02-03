function out = linearize_pump_power_2p1t(ump_groups, q_op, s_op)
  % Wrapper for linearize_pumps configured for linearizing the 2pt1
  % case study model.
  % Currently, just callse the linearize_pumps model but it's
  % provided for consistency with linearize_pipes function.
  out = linearize_power_pumps(pump_groups, q_op, s_op);
end
