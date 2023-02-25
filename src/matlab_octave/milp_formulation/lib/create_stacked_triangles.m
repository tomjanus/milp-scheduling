function y = create_stacked_triangles(...
      p_1, p_2, p_3, p_4, p_14, p_23, inequality_signs)
      
  % Divide the area into four stacked triangles created by the four points
  % defining the outline of the domain and the two points lying on the boundary
  % of the plane along the direction of maximum curvature
  
  % Args:
  %   Four base points in 3D - p_1, p_2, p_3, p_4
  %   p_14 - Apex point lying on the curve belonging to the surface and
  %          connecting points p_1 and p_4
  %   p_23 - Apex point lying on the curve belonging to the surface and
  %          connecting points p_2 and p_3
  %   inequality_signs - 4 x 3 cell of '<' and '>' signs determining the
  %       "direction" of inequalities. The inequalities are in the order 
  %       defined by the order of triangle vertices, e,g, 
  %       Face1: p_1, p_2, p_23; Face2: p_1, p_23, p_14, etc.
  %       In each face the order of inequality follows the direction (order) of 
  %       vertices - e.g. for Face1 (1) p_1 - p_2, (2) p_2 - p_23, (3) p_23 - p_1
  %
  % Return:
  % 4x1 array of structures with coeff and constraints fields
  %   coeff is z 3x1 vector of plane equation coefficients
  %   constraints is a cell of cells with a 1x2 vector of line equation
  %   coefficients and a string representing the direction of the inequality
  
  % TODO
  % Add checks that the two points picked lie on the edge of the surface
  
  % by convention the points are listed for each triangle counter-clockwise
  triangle_vertices = {...
    p_1, p_2, p_23; ...
    p_1, p_23, p_14; ...
    p_14, p_23, p_3; ...
    p_14, p_3, p_4};
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
  
  % Find equations of each side of the stacked triangle
  for i = 1:NO_TRIANGLES
    p1 = triangle_vertices{i,1};
    p2 = triangle_vertices{i,2};
    p3 = triangle_vertices{i,3};
    [m_x1, m_x2, c] = get_plane(p1,p2,p3);
    y(i).coeffs = [m_x1, m_x2, c];
  end
  
  % Iterate through every triangle and obtain constraints for each triangles domain
  for i = 1:NO_TRIANGLES
    vertices = triangle_vertices_2D{i,:};
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
