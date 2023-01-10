function [lb, ub] = set_variable_bounds(var_struct, constraints)
  % Set upper and lower boundaries for continuous and binary decision variables
  % Set constraints on continuous variables
  % Args:
  % var_struct - structure of variables with x_cont and x_bin fields
  % constarints - 
  
  % By convention: continuour variables are listed as first, e.g. in variable
  % vector, followed by binary variables
  
  [ht_lb, ht_ub] = tank_head_bounds(...
      var_struct.x_cont, constraints.ht(1), constraints.ht(2));
  [hc_lb, hc_ub] = calc_head_bounds(...
      var_struct.x_cont, constraints.hc(1), constraints.hc(2));
  [qpipe_lb, qpipe_ub] = calc_pipe_flow_bounds(...
      var_struct.x_cont, constraints.q_pipe(1), constraints.q_pipe(2));
  [ww_lb, ww_ub] = calc_pipe_seg_flow_bounds(...
      var_struct.x_cont, constraints.q_pipe(1), constraints.q_pipe(2));
  [ss_lb, ss_ub] = calc_pump_seg_speed_bounds(...
      var_struct.x_cont, constraints.q_pipe(1), constraints.q_pipe(2));
  [qq_lb, qq_ub] = calc_pump_seg_flow_bounds(...
      var_struct.x_cont, constraints.q_pump(1), constraints.q_pump(2));
  [p_lb, p_ub] = calc_pump_power_bounds(...
      var_struct.x_cont, constraints.p_pump(1), constraints.p_pump(2));
  [s_lb, s_ub] = calc_pump_speed_bounds(...
      var_struct.x_cont, constraints.s_pump(1), constraints.s_pump(2));
  [q_lb, q_ub] = calc_pump_flow_bounds(...
      var_struct.x_cont, constraints.q_pump(1), constraints.q_pump(2));
  % Set constraints on binary variables
  [bb_lb, bb_ub] = calc_pipe_seg_sel_bounds(...
      var_struct.x_bin, constraints.seg_sel(1), constraints.seg_sel(2));
  [aa_lb, aa_ub] = calc_pump_seg_sel_bounds(...
      var_struct.x_bin, constraints.seg_sel(1), constraints.seg_sel(2));
  [n_lb, n_ub] = calc_pump_no_sel_bounds(...
      var_struct.x_bin, constraints.pump_sel(1), constraints.pump_sel(2));
      
  lb = [ht_lb;hc_lb;qpipe_lb;ww_lb;ss_lb;qq_lb;p_lb;s_lb;q_lb;bb_lb;aa_lb;n_lb];
  ub = [ht_ub;hc_ub;qpipe_ub;ww_ub;ss_ub;qq_ub;p_ub;s_ub;q_ub;bb_ub;aa_ub;n_ub];
end

%% CONTINUOUS VARIABLES
% Define inner functions defining lower and upper bounds of all decision
% variables present in the MILP formulation of the scheduling problem
function [ht_lb, ht_ub] = tank_head_bounds(vars_cont, ht_min, ht_max)
  % Assign lower and upper bounds to the vector of tank heads
  [ht_lb, ht_ub] = constant_bounds(length(vars_cont.ht), ht_min, ht_max);
end

function [hc_lb, hc_ub] = calc_head_bounds(vars_cont, hc_min, hc_max)
  % Assign lower and upper bounds to the vector of calculated node heads
  [hc_lb, hc_ub] = constant_bounds(length(vars_cont.hc), hc_min, hc_max);
end

function [qpipe_lb, qpipe_ub] = calc_pipe_flow_bounds(...
    vars_cont, qpipe_min, qpipe_max)
  % Lower and upper bounds on the vector of pipe flows
  [qpipe_lb, qpipe_ub] = constant_bounds(...
    length(vars_cont.qpipe), qpipe_min, qpipe_max);
end

function [ww_lb, ww_ub] = calc_pipe_seg_flow_bounds(vars_cont, ww_min, ww_max)
  % Assign lower and upper bounds to the vector of calculated pipe flows in
  % pipe segments
  [ww_lb, ww_ub] = constant_bounds(length(vars_cont.ww), ww_min, ww_max);
end

function [ss_lb, ss_ub] = calc_pump_seg_speed_bounds(vars_cont, ss_min, ss_max)
  % Lower and upper bounds of the vector of calculated pump speeds in
  % pump characteristic segments
  [ss_lb, ss_ub] = constant_bounds(length(vars_cont.ss), ss_min, ss_max);
end

function [qq_lb, qq_ub] = calc_pump_seg_flow_bounds(vars_cont, qq_min, qq_max)
  % Lower and upper bounds on the vector of calculated pump flows in
  % pump characteristic segments
  [qq_lb, qq_ub] = constant_bounds(length(vars_cont.qq), qq_min, qq_max);
end

function [p_lb, p_ub] = calc_pump_power_bounds(vars_cont, p_min, p_max)
  % Lower and upper bounds on pump power consumption
  [p_lb, p_ub] = constant_bounds(length(vars_cont.p), p_min, p_max);
end

function [s_lb, s_ub] = calc_pump_speed_bounds(vars_cont, s_min, s_max)
  % Lower and upper bounds on pump speed
  [s_lb, s_ub] = constant_bounds(length(vars_cont.s), s_min, s_max);
end

function [q_lb, q_ub] = calc_pump_flow_bounds(vars_cont, q_min, q_max)
  % Lower and upper bounds on pump flows
  [q_lb, q_ub] = constant_bounds(length(vars_cont.q), q_min, q_max);
end

%% BINARY VARIABLES
function [bb_lb, bb_ub] = calc_pipe_seg_sel_bounds(vars_bin, bb_min, bb_max)
  % Lower and upper bounds on pipe segment selection variables
  [bb_lb, bb_ub] = constant_bounds(length(vars_bin.bb), bb_min, bb_max);
end

function [aa_lb, aa_ub] = calc_pump_seg_sel_bounds(vars_bin, aa_min, aa_max)
  % Lower and upper bounds on pump domain selection variables
  [aa_lb, aa_ub] = constant_bounds(length(vars_bin.aa), aa_min, aa_max);
end

function [n_lb, n_ub] = calc_pump_no_sel_bounds(vars_bin, n_min, n_max)
  % Lower and upper bounds on pump selection in the pump group
  [n_lb, n_ub] = constant_bounds(length(vars_bin.n), n_min, n_max);
end