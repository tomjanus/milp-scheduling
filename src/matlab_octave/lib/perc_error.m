function y = perc_error(true_value, approx_value)
  % Return relative error in % between two values
  if (true_value == 0) && (approx_value == 0)
    y = 0;
    return
  elseif true_value == 0
    den = approx_value;
  else
    den = true_value;
  end  
  y = 100 * abs((true_value - approx_value)/den);
end
