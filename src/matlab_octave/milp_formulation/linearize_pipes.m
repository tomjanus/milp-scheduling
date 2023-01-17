function out = linearize_pipes(network, sim_out, rep_hr, Upipes)
  % Linearizes all pipes in the network given in the network structure
  % using the linearization points obtained from the outputs of the simulator.
  % Requires prior initialization of the network followed by a simulation
  % run over the planning time horizon.
  %
  % Args:
  %   network - network structure
  %   sim_out - simulation output structure
  %   rep_hr - representative hour (1 - 24)
  %   Upipe - max flow(s) for linearization - one per pipe
  % Return:
  %   Cell of linearized pipe output structures 
  
  no_pipes = length(network.R);
  out = cell(no_pipes, 1);
  if length(Upipes) == 1
    Upipes = repmat(Upipes, no_pipes, 1);
  else
    if length(Upipes) ~= no_pipes
      error("Length of vector Upipes: %d not equal to no. of pipes: %d", length(Upipes), no_pipes);
    end
  end
  q_sim = sim_out.q(network.elements.pipe_index,:); % Select flows in pipes only
  
  for i = 1:no_pipes
    R = network.R(i);
    Upipe = Upipes(i);
    q_op = q_sim(i, rep_hr);
    out{i} = linearize_pipe_characteristic(R, q_op, Upipe);
  end
end

