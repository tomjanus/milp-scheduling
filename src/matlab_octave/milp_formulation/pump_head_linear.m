function h = pump_head_linear(linearized_model, q, s, domain_number)
  % Find head of a linearized pump model operating at speed s
  % and flow q.
  % The linearized pump model contains four planes and is derived using
  % function `linearize_pump_characteristic`.
  % Flow denotes the flow passing through a (single) pump, as opposed to
  % the nonlinear equation where the flow variable denotes the flow going
  % through the entire pump group of n equal pumps
  model = linearized_model(domain_number);
  h = model.coeffs(1) * q + model.coeffs(2) * s + model.coeffs(3);
end
