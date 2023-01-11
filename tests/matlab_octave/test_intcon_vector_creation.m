function y = test_intcon_vector_creation()
  warning('off','all');

  % Prepare a set of test parameters
  test_network.nt = 1;
  test_network.nc = 4;
  test_network.npipes = 4;
  test_network.npumps = 2;

  vars = initialise_var_structure(...
    test_network, 24, 3, 4);
  no_vars_in_struct = var_struct_length(vars);
  fprintf("Number of variables in the variable struct = %d \n", no_vars_in_struct);
  no_bin_vars = var_struct_length(vars, "x_bin");
  fprintf("Number of int variables in the variable struct = %d \n", no_bin_vars);
  intcon = set_intcon_vector(vars);
  fprintf("Created intcon vector of length %d\n", length(intcon));
  if no_bin_vars == length(intcon)
    y = 1;
  else
    y = 0;
  end
  warning('on','all');
