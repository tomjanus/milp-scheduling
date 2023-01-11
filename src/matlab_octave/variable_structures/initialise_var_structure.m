function vars = initialise_var_structure(...
    network, no_steps, no_pipe_segments, no_pump_segments)
  % Create a structure of continuous and binary decision variables and 
  % initialize the variable vectors with zeros
  %
  % All variables cover the time horizon n = 1 : no_steps
  %
  % Args:
  %   network - network structure
  %   no_steps - number of time steps for which schedule is calculated
  %   no_pipe_segments - number of segments each pipe is discretized into
  %
  % Returns:
  % structure with continuous and binary variable vectors

  % TODO: Arguments no_pipe_segments and no_pump_segments should come
  % from within linearization functions as they may depend on the type
  % and/or parameterization of chosen linearization functions out of
  % the set of available linearization options.
  
  % TANKS (CALCULATED NODES WITH FLOW-HEAD RELATIONSHIPS)
  % number of variables describing tank heads in the network, $h_{t,k}(n)$
  % for k = 1 : network.nt tanks
  no_tank_vars = network.nt * no_steps;
  % CALCULATED NODES
  % number of calculated heads, $h_{c,j}(n)$ for j = 1: network.nc calculated nodes
  no_calc_head_vars = network.nc * no_steps;
  %% PIPES
  % number of calculated pipe flows, $q_{i}(n)$ for i = 1: nework.npipes
  no_calc_flow_vars = network.npipes * no_steps;
  % number of pipe segment flows, $ww_{i,p_seg}(n)$ for i = 1 : network.npipes
  % and p_seg = 1 : no_pipe_segments
  no_pipe_seg_flows = network.npipes * no_pipe_segments * no_steps;  
  % PUMPS
  % number of continuous variables for pump domain speed,
  % $ss_{l,pump_seg}(n)$ for l = 1 : network.npumps and 
  % pump_seg = 1 : no_pump_segments
  no_pump_speed_seg_vars = network.npumps * no_pump_segments * no_steps; 
  % number of continuous variables for pump domain flow,
  % $qq_{l,pump_seg}(n)$ for l = 1 : network.npumps and 
  % pump_seg = 1 : no_pump_segments
  no_pump_flow_seg_vars = network.npumps * no_pump_segments * no_steps;
  % COST
  % number of variables quantifying power consumption by pumps (all individual
  % pumps quantified separately. $p_{l}(n)$ for l = 1 : network.npumps
  no_power_vars = network.npumps * no_steps;
  % number of variables determining pump speed of each pump
  % $s_{l}(n)$ for l = 1 : network.npumps
  no_pump_speed_vars = no_power_vars;
  % number of variables determining pump flow of each pump
  % $q_{l}(n)$ for l = 1 : network.npumps
  no_pump_flow_vars = no_power_vars;  
  
  x_cont.ht = zeros(no_tank_vars, 1);
  x_cont.hc = zeros(no_calc_head_vars, 1);
  x_cont.qpipe = zeros(no_calc_flow_vars, 1);
  x_cont.ww = zeros(no_pipe_seg_flows, 1);
  x_cont.ss = zeros(no_pump_speed_seg_vars, 1);
  x_cont.qq = zeros(no_pump_flow_seg_vars, 1);
  x_cont.p = zeros(no_power_vars, 1);
  x_cont.s = zeros(no_pump_speed_vars, 1);
  x_cont.q = zeros(no_pump_flow_vars, 1);
  
  % PIPES
  % binary variables for pipe segment selection, $bb_{i,pipe_seg}(n)$ 
  % for i = 1 : network.npipes and pipe_seg = 1 : no_pipe_segments
  no_pipe_seg_vars = no_pump_flow_seg_vars;
  % PUMPS
  % number of binary variables for domain selection for pumps
  % $aa_{l,pump_seg}(n)$ for l = 1 : network.npumps and 
  % pump_seg = 1 : no_pump_segments
  no_pump_seg_vars = no_pump_flow_seg_vars; 
  % COST
  % number of variables determining on/off status of each pump
  % $n_{l}(n)$ for l = 1 : network.npumps
  no_pump_on_off_vars = network.npumps * no_steps;  
  
  x_bin.bb = zeros(no_pipe_seg_vars, 1);
  x_bin.aa = zeros(no_pump_seg_vars, 1);
  x_bin.n = zeros(no_pump_on_off_vars, 1);  
  
  vars.x_cont = x_cont;
  vars.x_bin = x_bin;
  
  % Calculate numbers of continuous and binary variables
  vars.n_cont = length(struct_to_vector(x_cont));
  vars.n_bin = length(struct_to_vector(x_bin));;
end
