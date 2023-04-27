function [sim_n, sim_s] = linprog_to_sim_schedule(optim_n, optim_s)
  % Conversion of pump schedule obtained from the mixed integer
  % linear programme to pump schedule compatible with the simulator

  % Currently, only applies to cases with a single pump group
  
  % This only works for a single pump group
  sim_n = sum(optim_n,2)';
  sim_s = zeros(size(optim_s, 1), 1);
  for i = 1:size(optim_s,1)
      s_row = optim_s(i,:);
      % If pumps are all ON, use mean speed
      if all(s_row)
          sim_s(i) = mean(s_row);
          continue
      end
      % If all pumps are OFF, set speed to zero
      if ~any(s_row)
          sim_s(i) = 0;
          continue
      end
      % If some of the pumps are off, select ones that are not OFF and
      % take the average
      sim_s(i) = mean(s_row(s_row~=0));
  end
  sim_s = sim_s';
end