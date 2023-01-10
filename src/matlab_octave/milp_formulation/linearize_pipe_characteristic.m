function out = linearize_pipe_characteristic(R, q_op, Upipe)
  % Divide pipe characteristics into linear segments
  % Args:
  %   R - pipe resistance
  %   q_op - pipe operating point (sorf of nominal flow). Could be set from
  %          simulation e.g. as the flow at 12 o'clock, for instance.
  %   Upipe - a large number representing the maximum possible flow
  %          that can flow through the pipe
  % Returns:
  %   out: struct array with fields: coeffs and limits
  %     coeffs is a struct with coefficients m and c of each linear segment
  %         defined with equation dh = m * q + c
  %     limits is a cell containing two 1x2 vectors specifying the start and end
  %         points of each segment in the (q, dh) plane.
  % 
  
  % TODO: GENERALIZE TO MORE THAN THREE SEGMENTS
  N_SEGMENTS = 3;
  
  % Find the head drop for the operating point and Upipe
  dh_op = pipe_characteristic(R, q_op);
  dh_Upipe = pipe_characteristic(R, Upipe);
  % We exploit pipe characteristic symmetry around point (0,0)
  limit_points = {[-Upipe, -dh_Upipe], [-q_op, -dh_op];...
    [-q_op, -dh_op], [q_op, dh_op];...
    [q_op, dh_op], [Upipe, dh_Upipe]};
  % Populate the `out` variable with data
  for i = 1:N_SEGMENTS
    % Coefficients of the line equations
    [out(i).coeffs.m, out(i).coeffs.c] = get_line(...
        limit_points{i,1}, limit_points{i, 2});
    % Limits of each segment
    out(i).limits = {limit_points{i,1}, limit_points{i, 2}};
  end 
end
