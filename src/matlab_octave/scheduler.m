function [n, s, x1]= scheduler(...
  f_sparse,intcon,A1_sparse,b1_sparse,A1eq_sparse,b1eq_sparse,lb,ub,vars)
  % Wrapper for MATLAB's intlinprog
  % Uses MILP formulation to solve a pump scheduling problem in WDNs

  % Args:
  % f_sparse: coefficient vector of the objective
  % intcon: vector of indices of the elements of x that are integer variables
  % A1_sparse: linear inequality constraints matrix
  % b1s_sparse: linear inequality constraints
  % A1eq_sparse: linear equality constraints matrix
  % b1eq_sparse: linear equality constraints
  % lb: lower bounds on vector x
  % ub: upper bounds on vector x
  % x0: initial point

  % Return
  % Pump schedules: n, s
  
  % Do not use x0
  options = optimoptions('intlinprog', 'Heuristics','advanced', 'IntegerPreprocess','advanced');
  x0 = [];
  [x1,fval,exitflag,output]= intlinprog(...
    f_sparse,intcon,A1_sparse,b1_sparse,A1eq_sparse,b1eq_sparse,lb,ub,x0,options);
  
  fprintf("Solver finished executing\n");
  fprintf("Exit flag: %d\n", exitflag);
  fprintf("Objective value: %f\n", fval);
  disp(output);

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
          n(i,j) = x1(lp_index_n);
          s(i,j) = x1(lp_index_s);
        end
      end
  else
      n = nan;
      s = nan;
  end
end
