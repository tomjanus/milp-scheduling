function [a, b, c] = get_plane(p1, p2, p3)
  % Find coefficients a, b, c of a 2D plane equation in 3D
  % z = ax + by + c from three points in 3D lying on that plane
  % Args:
  %   p1 = [x1, y1, z1]
  %   p2 = [x2, y2, z2]
  %   p3 = [x3, y3, z3]
  % Note: points must have a single row and three columns
  % TODO: Modify this code to be generic and accept row and column vectors
  p1_p2 = vector_from_points(p1, p2);
  p1_p3 = vector_from_points(p1, p3);
  [a, b, c] = get_plane_from_vectors(p1_p2', p1_p3, p1);

  
  function [a, b, c] = get_plane_from_vectors(v1, v2, p1)
    % Find equation of a plane from two vectors lying on that plane and 
    % one point
    % TODO: Make the function generic by checking and adjusting vector and point
    % dimensions to assure dimension compatibility
    
    % Find normal vector n: n(1)∗x + n(2)∗y + n(3)∗z + K = 0
    n = cross(v1, v2');
    % Trick to make Octave and Matlab compatible because Octave returns a row
    % vector whilst Octave returns a column vector
    if (size(n)(1) < size(n)(2))
      n = n';
    end
    % Find offset K
    K = -n' * p1';
    % Get a, b, c coefficients
    a = -n(1)/n(3);
    b = -n(2)/n(3);
    c = -K/(n(3));
  end
end

function v = vector_from_points(p1, p2)
  % Return a vector from point p1 to point p2
  n_dim = length(p1);
  if (length(p1) ~= length(p2))
    error('Points p1 and p2 have different dimensions');
  end
  v = p1 - p2;
end
