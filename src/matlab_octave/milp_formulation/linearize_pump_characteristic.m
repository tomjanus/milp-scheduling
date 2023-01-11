function out = linearize_pump_characteristic(pump)
  % Linearize a nonlinear hydraulic pump characteristic over a speed-flow domain 
  % defined by boundary points p1, p2, p3, and p4 that are calculated from
  % information contained in the pump structure.
  % Args:
  %   pump - structure with pump data
  % Return:
  %   array of structures with plane coefficients
  
  % Each domain is defined by polynomial coefficients a, b, c
  % describing plane equation z = ax + by + c
  
  %% Get the nominal point
  [qn, sn, Hn] = pump_nominal_point(pump);
  pn = [qn, sn, Hn];

  %% Define the boundary point coordinates
  q_min = 0;
  s_min = pump.smin;
  s_max = pump.smax;
  % Find intercept flows for minimum and maximum speeds respectively
  q_int_smin = pump_intercept_flow(pump, 1, s_min);
  q_int_smax = pump_intercept_flow(pump, 1, s_max);
  % Define the boundary points
  p1 = [q_min, s_min, pump_head(pump, q_min, 1, s_min)]; % min-min
  p2 = [q_min, s_max, pump_head(pump, q_min, 1, s_max)]; % min-max
  p3 = [q_int_smax , s_max, pump_head(pump, q_int_smax, 1, s_max)]; % max-max
  p4 = [q_int_smin , s_min, pump_head(pump, q_int_smin, 1, s_min)]; % max-min

  % Specify a cell with constraint signs
  constraint_signs = {">", "<", ">";...
                      ">", ">", "<";...
                      "<", ">", "<";...
                      "<", "<", ">"};
  domain_vertices = {p1, p2, p3, p4};
  
  %% Currently only supports the tetrahedron linearization in create_tetrahedron
  out = create_tetrahedron(p1, p2, p3, p4, pn, constraint_signs);
end
