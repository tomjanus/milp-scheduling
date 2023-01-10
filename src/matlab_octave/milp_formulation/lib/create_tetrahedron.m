function y = create_tetrahedron(p_1, p_2, p_3, p_4, p_a, inequality_signs)
  % Create a tetrahedron with base defined by four points, p_1, p_2, p_3, p_4
  % and apex defined by point p_a
  % Each of the points is defined by a 1x3 vector of x,y,z coordinates
  % Args:
  %   Four base points in 3D - p_1, p_2, p_3, p_4
  %   Apex point in 3D - p_a
  %   inequality_signs - 4 x 3 cell of '<' and '>' signs determining the
  %       "direction" of inequalities. The inequalities are in the order 
  %       defined by the order of base points, e,g, 
  %       Face1: p_1, p_2, p_a; Face2: p_2, p_3, p_a, etc.
  %       In each face the order of inequality lines is: (e.g. for Face1
  %       (1) p_1 - p_2, (2) p_1 - p_a, (3) p_2 - p_a
  % Return:
  % 4x1 array of structures with coeff and constraints fields
  %   coeff is z 3x1 vector of plane equation coefficients
  %   constraints is a cell of cells with a 1x2 vector of line equation
  %   coefficients and a string representing the direction of the inequality
  
  
  triangle_vertices = {...
    p_1,p_a,p_2; ...
    p_2,p_a,p_3; ...
    p_3,p_a,p_4; ...
    p_4,p_a,p_1};
  NO_TRIANGLES = size(triangle_vertices,1);
  NO_VERTICES = size(triangle_vertices, 2);
  
  % Project the vertices on the plane z = 0
  triangle_vertices_2D = cell(size(triangle_vertices));
  for triangle = 1:size(triangle_vertices, 1)
    for vertex = 1:size(triangle_vertices, 2)
      triangle_vertices_2D{triangle, vertex} = rem_z_coordinate(...
        triangle_vertices{triangle, vertex});
    end
  end
  
  % Find equations of each side of the sides of the tetrahedron
  for i = 1:NO_TRIANGLES
    p1 = triangle_vertices{i,1};
    p2 = triangle_vertices{i,2};
    p3 = triangle_vertices{i,3};    
    [m_x1, m_x2, c] = get_plane(p1,p2,p3);
    y(i).coeffs = [m_x1, m_x2, c];
  end
  
  % Project point onto z = 0
  %base_points_2D = cellfun(@rem_z_coordinate,  {p_1, p_2, p_3, p_4}, ...
  %    'UniformOutput',false);
  
  % Iterate through every triangle and obtain constraints for each triangles domain
  for i = 1:NO_TRIANGLES
    vertices = triangle_vertices_2D(i,:);
    for j = 1:NO_VERTICES
      p1 = vertices{j};
      if j<NO_VERTICES
        p2 = vertices{j+1};
      else
        p2 = vertices{1};
      end
      [m_coeff, c_coeff] = get_line(p1, p2);
      ineq_sign = inequality_signs{i, j};
      y(i).constraints{j} = {[m_coeff, c_coeff], ineq_sign};
    end
  end  
end
