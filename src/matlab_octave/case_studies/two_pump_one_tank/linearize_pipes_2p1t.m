function out = linearize_pipes_2p1t(network, sim_out)
  % Wrapper for linearize_pipes configured for linearizing the 2pt1
  % case study model.
  rep_hr = 12;
  Upipes = [150, 150, 150, 150];
  out = linearize_pipes(network, sim_out, rep_hr, Upipes);
end
