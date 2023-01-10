function dh = pipe_characteristic(R, q)
  % Calculate pipe head drop from pipe resistance and flow
  dh = R*q*abs(q);
end
