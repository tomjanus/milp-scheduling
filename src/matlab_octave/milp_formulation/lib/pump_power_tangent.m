function out = pump_power_tangent(pump, q_op, s_op)
   % Find tangents in the `q` and `s` directions and the operating point in the
   % (q, s, P) coordinates
   %   The linear power equation coefficients are the coefficients of a linear 
   %   power consumption model:
   %   P_lin = m_dq * q + m_ds * s + c where
   %   c = P(q_op, s_op) - m_dq * q_op - m_ds * s_op
   % Tangent in the x direction (flow)
   out.m_dq = 3*pump.ep*q_op^2 + 2*pump.fp*q_op*s_op + pump.gp*s_op^2;
   % Tangent in the y direction (speed)
   out.m_ds = pump.fp*q_op^2 + 2*pump.gp*q_op*s_op + 3*pump.hp*s_op^2;
   % Get the tangent point
   out.p_t = [q_op, s_op, pump_power_consumption(pump, q_op, s_op, 1)];
end
