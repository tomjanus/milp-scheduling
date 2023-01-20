function vars = initialise_var_structure(network, linprog)
  % Create a structure of continuous and binary decision variables and 
  % initialize the variable vectors with zeros
  %
  % All variables cover the time horizon n = 1 : no_steps
  % The var structure is intended to act as a template for creating the decision
  % variable vector, the objective coefficient vector, and the rows of matrices
  % A and Aq for the formulation of the mixed integer linear programme.
  %
  % Args:
  %   network - network structure
  %   linprog - linear programme config variables
  %
  % Returns:
  % structure with continuous and binary variable vectors
  
  no_pipe_segments = linprog.NO_PIPE_SEGMENTS;
  no_pump_segments = linprog.NO_PUMP_SEGMENTS;
  no_steps = linprog.NO_PRED_STEPS;
  number_of_elements = network.npipes + network.npg;

  % TODO: Arguments no_pipe_segments and no_pump_segments should come
  % from within linearization functions as they may depend on the type
  % and/or parameterization of chosen linearization functions out of
  % the set of available linearization options.
  
  % Initialize continuous variables
  x_cont.ht = zeros(no_steps, network.nt);
  x_cont.hc = zeros(no_steps, network.nc);
  % Introduce a `compound' flow vector that is composed of pipe flows and
  % flows via pump groups
  x_cont.qel = zeros(no_steps, number_of_elements);
  % x_cont.qpipe = zeros(no_steps, network.npipes);
  % x_cont.q = zeros(no_steps, network.npumps);
  x_cont.ww = zeros(no_pipe_segments, no_steps, network.npipes);
  x_cont.ss = zeros(no_pump_segments, no_steps, network.npumps);
  x_cont.qq = zeros(no_pump_segments, no_steps, network.npumps);
  x_cont.p = zeros(no_steps, network.npumps);
  x_cont.q = zeros(no_steps, network.npumps);
  x_cont.s = zeros(no_steps, network.npumps);
  
  % Initialize binary variables
  % Binary variables for pipe segment selection
  x_bin.bb = zeros(no_pipe_segments, no_steps, network.npipes);
  % Binary variables for pump segment selection
  x_bin.aa = zeros(no_pump_segments, no_steps, network.npumps);
  % Binary variables for pump selection (for every pump in the network separately)
  x_bin.n = zeros(no_steps, network.npumps);

  % Create the output var structure
  vars.x_cont = x_cont;
  vars.x_bin = x_bin;
  
  % Calculate numbers of continuous and binary variables
  vars.n_cont = length(struct_to_vector(vars, 'x_cont'));
  vars.n_bin = length(struct_to_vector(vars, 'x_bin'));
end
