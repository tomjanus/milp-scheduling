function out = linearize_pumps(pump_groups)
  % Linearizes all pump (groups) in the network given in the network structure
  % Since all pumps in a pump group are assumed to be equal, linearization is
  % performed for a (representative) pump of each pump group.
  % Args:
  %   network - network structure
  % Return:
  %   Cell of linearized pipe output structures 

  out = cell(size(pump_groups));
  for i = 1:length(out)
    out{i} = linearize_pump_characteristic(pump_groups{i});
  end
end
