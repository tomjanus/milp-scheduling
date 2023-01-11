function y = test_pipe_linearization()
  warning('off','all');
  test_name = "test_pipe_linearization";
  fprintf("\nRunning test: %s \n", test_name);
  % Provide test pipe and linearization data
  R_test = 0.00035391;
  q_op_test = 50;
  Upipe_test = 150;
  % Linearize the pipe characteristic
  lin_model = linearize_pipe_characteristic(R_test, q_op_test, Upipe_test);
  % Compare head-drops between the nonlinear and linear model for a range of
  % points
  % Pick operating points
  test_flows = [0, 5, 15, 30, 40, 50, 80, 100, 150, 200];
  % TODO:
  % Segments are currently hard coded but could be made dependent on q_op_test
  segments = [2, 2, 2, 2, 2, 2, 3, 3, 3, 3];
  if (length(test_flows) ~= length(segments))
    error('Points and segments vectors do not have equal lengths');
  end
  fprintf("----------------------------------------------------------------\n");
  fprintf("Comparison of nonlinear and linearized pipe models\n");
  for i = 1:length(test_flows)
    % Find head-drop from nonlinear characteristic
    dh_nl = pipe_characteristic(R_test, test_flows(i));
    % Find head-drop from linearized characteristic
    dh_lin = lin_model(segments(i)).coeffs.m * test_flows(i) + ...
        lin_model(segments(i)).coeffs.c;
    fprintf('Point %d, Flow %.1f L/s , Headloss %.2f m, perc. error %.1f , abs. error %.3f m\n', ...
        i, test_flows(i), dh_nl, perc_error(dh_nl, dh_lin), abs_error(dh_nl, dh_lin));
  end
  fprintf("----------------------------------------------------------------\n");
  warning('on','all');
  fprintf("Test: %s complete. \n\n", test_name);
  y = 1;
end


