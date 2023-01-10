function [q, s, H] = pump_nominal_point(pump)
  % Get the nominal point on the pump's hydraulic characteristics from pump data
  % Assumes nominal speed = 1 and nominal flow equal to maximum efficiency
  % flow given in the pump data
  q = pump.max_eff_flow;
  s = 1.0;
  H = pump_head(pump, q, 1, s);
end
