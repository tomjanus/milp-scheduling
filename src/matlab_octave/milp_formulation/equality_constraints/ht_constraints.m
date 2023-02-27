function [Aeq_ht, beq_ht] = ht_constraints(vars, network)
  % Set the equality constraints determining the water mass balance
  % in the tank(s) for all time steps except the first. In the first time-step
  % tank heads ht_i(k) for i = 1:Ntanks are set to ht_init, i.e. the initial
  % heads.
  % Map equation: ht(k) - ht(k-1) - 1/At q_tank(k) == 0 for k = 2:N_TIMESTEPS
  %               ht(1) = tank_elevation + init_level

  % Args:
  % vars: variables structure with the variables that are ultimately converted
  %       onto the variable vector x
  % network: structure with network variables
  
  % TODO: Expand this code to multiple tanks
  tank = network.tanks(1);

  number_time_steps = size(vars.x_cont.ht, 1);
  % Initialize output arrays
  Aeq_ht = zeros(number_time_steps, var_struct_length(vars));
  beq_ht = zeros(number_time_steps, 1);

  for i = 1:number_time_steps
    Aeq = vars;
    Aeq.x_cont.ht(i) = 1;
    if i == 1
      % Set initial condition for tank elevation
      beq = tank.elevation + tank.init_level;
    else
      Aeq.x_cont.ht(i-1)=-1;
      Aeq.x_cont.qel(i, network.elements.tank_feed_pipe_index) = -1/tank.area;
      beq = 0;
    end
    Aeq_ht(i,:) = struct_to_vector(Aeq)';
    beq_ht(i) = beq;
  end
end