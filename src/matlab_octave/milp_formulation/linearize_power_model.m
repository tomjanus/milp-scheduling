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
  
  %% Currently only supports the TANGENT surface model
  % TODO: ALLOW DIFFERENT LINEARIZATION METHODS ON THE POWER MODEL
  tangent = pump_power_tangent(pump, q_op, s_op);
  p_t = tangent.p_t;
  m_dq = tangent.m_dq;
  m_ds = tangent.m_ds;
  % Get the tangent surface (linearized) power consumption model
  y = create_tangent_surface(p_t, m_dq, m_ds, domain_vertices, constraint_signs);
end
