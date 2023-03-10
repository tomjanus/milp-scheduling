function power_vec = get_pump_powers(x_vector, vars, no_pumps)
    % Get the power consumption of the pump group
    % TODO: Generalize the function to work with multiple pump groups
    length_power = size(vars.x_cont.p, 1);
    power_vec = zeros(length_power, 1);
    for i = 1:length_power
        p_pump = 0;
        pumps_on = 0;
        for j = 1:no_pumps
            x_index_p = map_var_index_to_lp_vector(vars, 'p', {i, j});
            x_index_n = map_var_index_to_lp_vector(vars, 'n', {i, j});
            n = x_vector(x_index_n);
            p = x_vector(x_index_p);
            if n == 1
                pumps_on = pumps_on + 1;
                p_pump = p_pump + p;
        end
        power_vec(i) = p_pump;
    end
end
