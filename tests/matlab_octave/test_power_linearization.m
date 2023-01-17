function y = test_power_linearization()
  warning('off','all');
  test_name = 'test_power_linearization';
  fprintf('\nRunning test: %s \n', test_name);
  % Create a test pump object
  test_pump.ep = 0.0;
  test_pump.fp = 0.0;
  test_pump.gp = 0.2422;
  test_pump.hp = 40;
  test_pump.max_eff_flow = 20;
  test_pump.smin = 0.7;
  test_pump.smax = 1.2;
  test_pump.A = -0.0045000;
  test_pump.B = 0;
  test_pump.C =  45;
    
  % Find the operating point
  s_op = 1;
  q_op = test_pump.max_eff_flow;
  
  % Specify domain vertices
  q_min = 0;
  s_min = test_pump.smin;
  s_max = test_pump.smax;
  
  q_int_smin = pump_intercept_flow(test_pump, 1, s_min);
  q_int_smax = pump_intercept_flow(test_pump, 1, s_max);
  % Use coordinates:
  % s
  % |
  % | *p2     *p3
  % |
  % | *p1     *p4
  % |______________q
  %
  p1 = [q_min, s_min, pump_head(test_pump, q_min, 1, s_min)]; % min-min
  p2 = [q_min, s_max, pump_head(test_pump, q_min, 1, s_max)]; % min-max
  p3 = [q_int_smax , s_max, pump_head(test_pump, q_int_smax, 1, s_max)]; % max-max
  p4 = [q_int_smin , s_min, pump_head(test_pump, q_int_smin, 1, s_min)]; % max-min

  % Specify a cell with constraint signs
  constraint_signs = {'>', '<', '<', '>'};
  domain_vertices = {p1, p2, p3, p4};
  
  % Linearize the power consumption model
  out = linearize_power_model(test_pump, q_op, s_op, ...
      domain_vertices, constraint_signs);

  m_dq = out(1).coeff(1);
  m_ds = out(1).coeff(2);
  c = out(1).coeff(3);
  % Get a number of flow and s pairs
  q_s_array = [0, 0.7;
               15, 0.7;
               35, 1.2;
               20, 1;
               60, 1.2];
  % Compare power consumption between nonlinear and linear model
  fprintf('----------------------------------------------------------------\n');
  fprintf('Comparison of nonlinear and linearized power consumption models\n');
  for i = 1:size(q_s_array, 1)
    q = q_s_array(i, 1);
    s = q_s_array(i, 2);
    P_nonlin = pump_power_consumption(test_pump, q, s, 1);
    P_lin = m_dq * q + m_ds * s + c;
    fprintf('Point %d : Flow %.1f , Speed %.2f , Power %.2f kW, perc. error %.2f , abs. error %.3f \n', ...
      i, q, s, P_nonlin, perc_error(P_nonlin, P_lin), abs_error(P_nonlin, P_lin));
  end
  fprintf('----------------------------------------------------------------\n');
  % Provide test pump data
  warning('on','all');
  fprintf('Test: %s complete. \n\n', test_name);
  y = 1;
end


