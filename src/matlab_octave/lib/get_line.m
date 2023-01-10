function [m, c] = get_line(p1, p2)
  % Find coefficients m and c of a line equation in 2D
  % y = mx + c from two points in 2D lying on the line
  % Args:
  %   p1 = [x1, y1]
  %   p2 = [x2, y2]
  % Note: points must have a single row and two columns
  
  % If line vertical, i.e. infinite gradient and zero intercept 
  if p1(1) == p2(1)
      m = nan;
      c = p1(1); % Return c as the x coordinate of the vertical line
  else
      m = (p2(2) - p1(2))/(p2(1)-p1(1));
      c = (p1(2)*p2(1) - p2(2)*p1(1))/(p2(1)-p1(1));
  end
end


