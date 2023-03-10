function levels = get_tank_levels(x_vector, vars, tank_number)
    % Retrieves a Nx1 vector of tank levels for a given tank
    % in the network, where N is the simulation/optimization
    % time horizon
    length_levels = length(vars.x_cont.ht(:,tank_number));
    levels = zeros(length_levels, 1);
    for i = 1:length_levels
        x_index = map_var_index_to_lp_vector(vars, 'ht', {i,tank_number});
        levels(i) = x_vector(x_index);
    end
end
