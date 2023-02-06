function [m_x, m_y, c] = get_line_implicit(p1, p2)
  % Find coefficients m_x, m_y and c of a line equation in 2D
  % m_x * x + m_y * y = c from two points in 2D lying on the line
  % Args:
  %   p1 = [x1, y1]
  %   p2 = [x2, y2]
  % Note: points must have a single row and two columns
  
  % If line vertical, i.e. infinite gradient and zero intercept 
  if p1(1) == p2(1)
      m_x = 1;
      m_y = 0;
      c = p1(1); % Return c as the x coordinate of the vertical line
  else
      m_x = -(p2(2) - p1(2))/(p2(1)-p1(1));
      m_y = 1;
      c = (p1(2)*p2(1) - p2(2)*p1(1))/(p2(1)-p1(1));
  end
end


