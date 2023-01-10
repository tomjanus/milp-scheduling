function pump_power = pump_power_consumption(pump, q, s, n)
  % Third degree polynomial equation describing power consumption of a group
  % of n identical pumps operating at and speed s and flow (through the
  % group of pumps) q
  
  % Uses the following equations
  % P(q,n,s) = n * s^3 * P(q/(n*s))
  % P(q/(n*s)) = a3 * (q/(n*s))^3 + a2 * (q/(n*s))^2 + a1 * (q/(n*s)) + a0
  
  % The above equations, when combined, produce the following equation:
  % P(q,n,s) = a3*n^(-2)*q^3 + a2*n^(-1)*s*q^2 + a1*n^0*s^2*q + a0*n*s^3
  
  % where coefficients a3, a2, a1, a0 are denoted as:
  % pump.ep, pump.fp, pump.gp and pump.hp respectively.
  
  % Args:
  %   pump - structure with pump data
  %   q - flow going via a group of n working pumps, L/s
  %   s - pump speed (assumed equal for each working pump in the group), -
  %   n - number of working pumps in parallel
  % Returns
  %   pump group power consumption in kW
  
  if n == 0
    pump_power = 0;
  else
    pump_power = pump.ep * n^(-2) * q^3 + pump.fp * 1/n * q^2 * s + ...
      pump.gp * q * s^2 + pump.hp * n * s^3;
  end

end
