function [n, s, x1]= calculate_schedule(model, x0, vars, options)
  % Wrapper for MATLAB's intlinprog
  % Uses MILP formulation to solve a pump scheduling problem in WDNs
      
  % Args:
  % model - structure with mixed integer linear programme model matrices and vectors
  %         NOTE: Take care that the model coefficients, such as objective vector, 
  %               matrices A and Aeq, and vectors b and beq are sparse for large problems
  % x0: initial point
  % vars: Variable structure used for mapping variable indices to vector
  %   and matrix indices in the milp formulation
  % options - intlinprog optimizer options - check https://uk.mathworks.com/help/optim/ug/intlinprog.html#d124e114105

  % Return:
  % n, s - vectors of pump states and pump speeds, aka. pump schedule
  % x1 - state vector
  
  fprintf("Solving optimal pump scheduling problem with MATLAB's intlinprog\n");
  [x1,fval,exitflag,output]= intlinprog(...
    model.c_vector, model.intcon, model.A, model.b, model.Aeq, model.beq, ...
    model.lb, model.ub, x0, options);
  fprintf("Solver finished executing\n");
  fprintf("Exit flag: %d\n", exitflag);
  fprintf("Objective value: %f\n", fval);
  disp(output);
  % Extract vectors of pump stasuses and speeds from the optimal state vector x1
  % TODO: Check if `find_schedule_from_x` is generic. It may not be. It may be specific
  %       to 2p1t case study. In this case, generalize such that `calculate_schedule` is
  %       a generic function and not specific to any particular case study problem.
  [n, s] = find_schedule_from_x(exitflag, vars, x1);
end
