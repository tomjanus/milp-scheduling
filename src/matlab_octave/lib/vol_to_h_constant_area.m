function h = vol_to_h_constant_area(A, V, elev)
  % Calculate tank head from fill volume for a tank with constant surface area
  % Args:
  %   A - tank area, m2
  %   V - tank fill volume, m3
  %   elev - tank elevation in metres (optional)
  % Return
  %   tank head in metres
  
  if nargin == 2
    elev = 0;
  end
  
  h = V / A + elev;
end

