function y = test_obj_vector_creation()
  %
  warning('off','all');
  test_name = 'test_obj_vector_creation';
  fprintf('\nRunning test: %s \n', test_name);
  % Set test input values
  test_time_step = 1;
  sparse_out = true;
  test_no_steps = 24;
  test_tarif_vec = ones(test_no_steps,1);
  % Creae a test network structure
  test_network.nt = 1;
  test_network.nc = 4;
  test_network.npipes = 4;
  % TODO: should this be npumps or number of pump groups?
  test_network.npg = 2;
  test_network.npumps = 2;
  
  linprog.NO_PIPE_SEGMENTS =  3;
  linprog.NO_PUMP_SEGMENTS =  4;
  linprog.NO_PRED_STEPS =  24;
  linprog.TIME_STEP =  1;
  
  % Create a test vars structure
  test_vars = initialise_var_structure(test_network, linprog);
  
  test_input.tariff = test_tarif_vec;
  
  test_f_vector = set_objective_vector(test_vars, test_network, test_input, linprog, 1);
  
  % Check how many values in the test vector are greated than one and if the
  % number is equal to test_no_steps * test_network.npumps
  
  number_nonzero_elements = length(find(test_f_vector>0));
  if number_nonzero_elements == test_no_steps * test_network.npumps
    y = 1;
  else
    y = 0;
  end
  warning('on','all');
  fprintf('Test: %s complete. \n\n', test_name);
end
