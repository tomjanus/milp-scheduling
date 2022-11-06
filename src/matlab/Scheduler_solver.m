function [x1,fval,exitflag]=Scheduler_solver(f_sparse,intcon,A1_sparse,b1_sparse,A1eq_sparse,b1eq_sparse,lb,ub,x0)

% CALLING the SOLVER

[x1,fval,exitflag,output]= intlinprog(f_sparse,intcon,A1_sparse,b1_sparse,A1eq_sparse,b1eq_sparse,lb,ub,x0);

end
