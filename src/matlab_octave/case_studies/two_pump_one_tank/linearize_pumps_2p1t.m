function out = linearize_pumps_2p1t(pump_groups)
  % Wrapper for linearize_pumps configured for linearizing the 2pt1
  % case study model.
  % Currently, just callse the linearize_pumps model but it's
  % provided for consistency with linearize_pipes function.
  out = linearize_pumps(pump_groups);
end
