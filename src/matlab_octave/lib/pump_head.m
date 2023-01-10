function h = pump_head(pump, q, n, s)
  % Find head of a group of n equal pumps, each operating at speed s
  % q denotes the (total) flow going through the group of pumps
  h = pump.A*q^2 + pump.B*q*n*s + pump.C*n^2*s^2;
end
