function y = linearize_power_model(pump, q_op, s_op, domain_vertices,...
                                   constraint_signs)
  % Linearization of the power consumption model given in function
  % pump_power_consumption.m`
  % The linearized model is applied to a single pump, hence the nonlinear
  % power consumption for a group of equal pumps working at the same speed s
  % is linearized under assumption n = 1.
  
  % Args:
  %   pump - structure with pump data
  %   q_op - operating point pump flow, L/s
  %   s_op - operting point pump speed, -
  % Return:
  % 1x1 vector of structures with coeff and constraints fields
  %   coeff is z 3x1 vector of linear power equation coefficients
  %   constraints is a cell of cells with a 1x2 vector of line equation
  %   coefficients and a string representing the direction of the inequality
  
  %   The linear power equation coefficients are the coefficients of a linear 
  %   power consumption model:
  %   P_lin = m_dq * q + m_ds * s + c where
  %   c = P(q_op, s_op) - m_dq * q_op - m_ds * s_op
  
  %% Currently only supports the TANGENT surface model
  % TODO: ALLOW DIFFERENT LINEARIZATION METHODS ON THE POWER MODEL
  % Tangent in the x direction (flow)
  m_dq = 3*pump.ep*q_op^2 + 2*pump.fp*q_op*s_op + pump.gp*s_op^2;
  % Tangent in the y direction (speed)
  m_ds = pump.fp*q_op^2 + 2*pump.gp*q_op*s_op + 3*pump.hp*s_op^2;
  % Get the tangent point
  p_t = [q_op, s_op, pump_power_consumption(pump, q_op, s_op, 1)];
  
  % Get the tangent surface (linearized) power consumption model
  y = create_tangent_surface(p_t, m_dq, m_ds, domain_vertices, constraint_signs);
end
