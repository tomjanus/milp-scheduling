function y = test_intcon_vector_creation()
  % Tests the procedures for obtaining the intcon vector for the MILP
  % programme formulation in MATLAB's `intlinprog`
  % Returns 1 if the length of the intcon vector == no. of binary variables
  % Otherwise, returns 0.
  warning('off','all');
  test_name = 'test_intcon_vector_creation';
  fprintf('\nRunning test: %s \n', test_name);
  % Prepare a set of test parameters
  test_network.nt = 1;
  test_network.nc = 4;
  test_network.npipes = 4;
  % TODO: should this be npumps or number of pump groups?
  test_network.npg = 2;
  test_network.npumps = 2;

  % TODO: TEST BOTH THE VECTOR AND TENSOR VAR STRUCTURES
  linprog.NO_PIPE_SEGMENTS =  3;
  linprog.NO_PUMP_SEGMENTS =  4;
  linprog.NO_PRED_STEPS =  24;
  linprog.TIME_STEP =  1;
  
  vars = initialise_var_structure(test_network, linprog);
  no_vars_in_struct = var_struct_length(vars);
  fprintf('Number of variables in the variable struct = %d \n',...
          no_vars_in_struct);
  no_bin_vars = var_struct_length(vars, 'x_bin');
  fprintf('Number of int variables in the variable struct = %d \n',...
          no_bin_vars);
  intcon = set_intcon_vector(vars);
  fprintf('Created intcon vector of length %d\n', length(intcon));
  if no_bin_vars == length(intcon)
    y = 1;
  else
    y = 0;
  end
  fprintf('Test: %s complete. \n\n', test_name);
  warning('on','all');
end