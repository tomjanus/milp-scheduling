y = set_constraints_2p1t(network, tank)
    % Create a constraint structure for the two pump one tank system
    constraints.ht = [tank.elevation+tank.x_min, tank.elevation+tank.x_max];
    constraints.hc = [205, 240];
    constraints.q_pipe = [-80, 80];
    constraints.q_pump = [0, 80];
    constraints.p_pump = [0, 10];
    constraints.s_pump = [0.7, 1.2];
    constraints.seg_sel = [0, 1];
    % Make this more generic so that it works with multiple pump (groups) each
    % one having different numbers of pumps for selection
    constraints.pump_sel = [0, network.np];
    y = constraints;
end