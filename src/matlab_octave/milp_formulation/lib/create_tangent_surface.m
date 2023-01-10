function y = create_tangent_surface(p_t, x_tan, y_tan, ...
                                    domain_vertices, constraint_signs)
  % Create a surface which passes through point p_t at which the gradients
  % in x and y direction are given by x_tan and y_tan
  
  % Args:
  % pt - point at which the tangent is derived
  % x_tan - tangent in the x direction
  % y_tan - tangent in the y direction
  % domain_vertices - a cell of four points in the order around the perimeter
  %                   defining the x-y domain over which the plane eq. is valid.
  % constraint signs - directions of inequalities determining the domain of
  %   the tangent surface (of the nonlinear surface model). Valid signs
  %   are "<" and ">". Cell of size no_of_vertices x 1
  %
  % Return:
  % 1x1 array of structures with coeff and constraints fields
  %   coeff is z 3x1 vector of plane equation coefficients
  %   constraints is a cell of cells with a 1x2 vector of line equation
  %   coefficients and a string representing the direction of the inequality
  
  % If domain vertices are in 3D, cast them to 2D by removing z coordinate
  for i = 1:numel(domain_vertices)
    vertex = domain_vertices{i};
    if length(vertex) == 3
      domain_vertices{i} = rem_z_coordinate(vertex);
    end
  end
  
  c_coeff = p_t(3); % Value at the point at which the tangent had been derived
  % Convert the equation from deviation variables dx, dy to absolute values, x 
  % and y
  c_coeff = c_coeff - x_tan * p_t(1) - y_tan * p_t(2);
  
  y(1).coeff = [x_tan, y_tan, c_coeff];
  
  number_vertices = numel(domain_vertices);
  for i = 1:number_vertices
    p_1 = domain_vertices{i}
    if i<number_vertices
      p_2 = domain_vertices{i+1};
    else
      p_2 = domain_vertices{1}; % Get the line between the last point and the first
    end
    % Get the line equation between p_1 and p_2
    [m, c] = get_line(p_1, p_2);
    y(1).constraints{i} = {[m, c], constraint_signs(i)};
  end
end
