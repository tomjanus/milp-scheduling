function q_int = pump_intercept_flow(pump, n, s)
  % Calculate pump intercept flow, i.e. flow for which head produced by n
  % equal working pumps at speed s is zero
  % Args
  %   pump - pump data structure
  %   n - number of working pumps
  %   s - pump speed (each of the n working pumps has the same speed)
  % Solves equation h = pump.A*q^2 + pump.B*q*n*s + pump.C*n^2*s^2
  % defined in function pump_head.m for flow q
  
  delta = (pump.B*n*s)^2 - 4*pump.A*pump.C*n^2*s^2;
  q_int = (-pump.B*n*s - sqrt(delta))/(2*pump.A);
end
