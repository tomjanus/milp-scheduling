function y = set_constraints_2p1t(network)
    % Create a constraint structure for the two pump one tank system
    % The returned structure must match the fields of the variable
    % structure used to formulate the MILP problem.

    % Note. Single lower and upper bound is currently supported for each
    % vector. Later, this and lb and ub boundary setting function should be
    % extended to allow different boundaries for different network components
    % e.g. for different tanks or pumps.
    x_cont = struct();
    y_cont = struct();
    % Get tank from the network structure - there's only one tank in this case study
    tank = network.tanks(1);

    x_cont.ht = [tank.elevation+tank.x_min, tank.elevation+tank.x_max];
    x_cont.hc = [205, 240];
    x_cont.qpipe = [-80, 80];
    x_cont.ww = [-80, 80];
    x_cont.ss = [0.7, 1.2];
    x_cont.qq = [0, 80];
    x_cont.p = [0, 10];
    x_cont.q = [0, 80];
    x_cont.s = [0.7, 1.2];

    x_bin.bb = [0, 1];
    x_bin.aa = [0, 1];
    x_bin.n = [0, 1]; % Each pump treated individually. Think later about changing
    % n value constraints so that it can also accept values larger than one and 
    % only consider one (representative) pump in a group instead of every pump
    % separately

    y.x_cont = x_cont;
    y.x_bin = x_bin;
end


