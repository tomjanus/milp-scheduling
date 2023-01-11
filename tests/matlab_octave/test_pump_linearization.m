function y = test_pump_linearization()
  % Function for testing the accuracy of pump characteristic linearization
  test_name = "test_pump_linearization";
  fprintf("\nRunning test: %s \n", test_name);
  warning('off','all');
  % Provide test pump data
  test_pump.smin = 0.7;
  test_pump.smax = 1.2;
  test_pump.max_eff_flow = 45;
  test_pump.A = -0.0045000;
  test_pump.B = 0;
  test_pump.C = 45;
  
  % Domain points
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
  
  % NOTE: The nominal point is derived from the informtion in the pump data structure
  
  % Linearize pump characteristic
  % NOTE: Specification of constraints is done in linearize_pump_characteristic
  %       Move it outside when more than one linearization function support is
  %       added
  linearized_test_pump_model = linearize_pump_characteristic(test_pump);
  
  % Pick operating points
  test_points = zeros(3,2);
  test_points(1,:) = [45, 1];
  test_points(2,:) = [20, 0.85];
  test_points(3,:) = [80, 1.1];
  selected_domains = [1, 1, 3];
  % Compare pump head from the non-linear and linear model
  % Nonlinear values
  fprintf("----------------------------------------------------------------\n");
  fprintf("Comparison of nonlinear and linearized pump models\n");
  for point_index = 1:size(test_points,1) 
    q = test_points(point_index, 1);
    s = test_points(point_index, 2);
    H_nl = pump_head(test_pump, q, 1, s);
    H_l = pump_head_linear(linearized_test_pump_model, q, s, ...
                           selected_domains(point_index));
    fprintf('Point %d : Flow %.1f , Speed %.2f , Head %.2f m, perc. error %.2f , abs. error %.3f \n', ...
      point_index, q, s, H_nl, perc_error(H_nl, H_l), abs_error(H_nl, H_l));
  end 
  fprintf("----------------------------------------------------------------\n");
  warning('on','all');
  fprintf("Test: %s complete. \n\n", test_name);
  y = 1;
end


