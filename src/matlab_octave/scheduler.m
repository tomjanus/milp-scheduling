function [x1,fval,exitflag]= scheduler(...
  f_sparse,intcon,A1_sparse,b1_sparse,A1eq_sparse,b1eq_sparse,lb,ub,x0)
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
  
  [x1,fval,exitflag,output]= intlinprog(...
    f_sparse,intcon,A1_sparse,b1_sparse,A1eq_sparse,b1eq_sparse,lb,ub,x0);

end
