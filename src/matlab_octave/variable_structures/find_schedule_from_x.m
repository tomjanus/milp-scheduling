function [n, s] = find_schedule_from_x(exitflag, vars, x)
  if exitflag >= 1
      % Retrieve n and s vectors from x1
      n = zeros(size(vars.x_bin.n));
      s = zeros(size(vars.x_cont.s));
      if size(n) ~= size(s)
        error("Arrays of active pump numbers n and pump speeds s are not equal");
      end
      % Populate n and s arrays with values obtained from intlinprog
      for i = 1:size(n,1)
        for j = 1:size(n,2)
          lin_index_n = lin_index_from_array(vars.x_bin.n, {i,j});
          lin_index_s = lin_index_from_array(vars.x_cont.s, {i,j});
          lp_index_n = map_var_index_to_lp_vector(vars, 'n', lin_index_n);
          lp_index_s = map_var_index_to_lp_vector(vars, 's', lin_index_s);
          n(i,j) = x(lp_index_n);
          s(i,j) = x(lp_index_s);
        end
      end
  else
      n = nan;
      s = nan;
  end
end