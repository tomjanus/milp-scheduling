function vars = initialise_var_structure(...
    network, no_steps, no_pipe_segments, no_pump_segments, variable_format)
  % Create a structure of continuous and binary decision variables and 
  % initialize the variable vectors with zeros
  %
  % All variables cover the time horizon n = 1 : no_steps
  %
  % Args:
  %   network - network structure
  %   no_steps - number of time steps for which schedule is calculated
  %   no_pipe_segments - number of segments each pipe is discretized into
  %   variable_format (optional) - option to store variables either as
  %      multidimensional tensors (if requied) or as stacked vectors
  %      Options = ["vector", "tensor"]
  %
  % Returns:
  % structure with continuous and binary variable vectors

  % TODO: Arguments no_pipe_segments and no_pump_segments should come
  % from within linearization functions as they may depend on the type
  % and/or parameterization of chosen linearization functions out of
  % the set of available linearization options.
  available_formats = {"vector", "tensor"};
  
  if nargin == 4
    variable_format = "vector";
  end
  
  % Throw error if variable format not in the list of available formats
  if ~ismember(variable_format, available_formats)
    printf("Provided variable format: %s not recognized\n", variable_format);
    printf("Using the default vector formet.\n");
    variable_format = "vector";
  end
  
  % Initialize continuous variables
  ht = zeros(no_steps, network.nt);
  hc = zeros(no_steps, network.nc);
  qpipe = zeros(no_steps, network.npipes);
  ww = zeros(no_pipe_segments, no_steps, network.npipes);
  ss = zeros(no_pump_segments, no_steps, network.npumps);
  qq = zeros(no_pump_segments, no_steps, network.npumps);
  p = zeros(no_steps, network.npumps);
  q = zeros(no_steps, network.npumps);
  s = zeros(no_steps, network.npumps);
  cont_vars = {ht, hc, qpipe, ww, ss, qq, p, q, s};
  
  % Initialize binary variables
  bb = zeros(no_pipe_segments, no_steps, network.npipes); % Binary variables for pipe segment selection
  aa = zeros(no_pump_segments, no_steps, network.npumps);; % Binary variables for pump segment selection
  n = zeros(no_steps, network.npumps);
  bin_vars = {bb, aa, n};
  
  if strcmp(variable_format, "vector")
    % Convert multidimensional arrays to vectors
    for i = 1:length(cont_vars)
      cont_vars{i} = tensor_to_vector(cont_vars{i});
    end
    for i = 1:length(bin_vars)
      bin_vars{i} = tensor_to_vector(bin_vars{i});
    end
  end
  
  % Store variables in a vector format
  x_cont.ht = cont_vars{1};
  x_cont.hc = cont_vars{2};
  x_cont.qpipe = cont_vars{3};
  x_cont.ww = cont_vars{4};
  x_cont.ss = cont_vars{5};
  x_cont.qq = cont_vars{6};
  x_cont.p = cont_vars{7};
  x_cont.s = cont_vars{8};
  x_cont.q = cont_vars{9};
  
  x_bin.bb = bin_vars{1};
  x_bin.aa = bin_vars{2};
  x_bin.n = bin_vars{3};  
  
  vars.x_cont = x_cont;
  vars.x_bin = x_bin;
  
  % Calculate numbers of continuous and binary variables
  vars.n_cont = length(struct_to_vector(vars, "x_cont"));
  vars.n_bin = length(struct_to_vector(vars, "x_bin"));;
end
