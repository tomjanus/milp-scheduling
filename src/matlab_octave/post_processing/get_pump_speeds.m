function spump_vec = get_pump_speeds(x_vector, vars, no_pumps)
    % Retrieve pump group flows from the vector of decision variables x
    % TODO: Generalize the function to work with multiple pump groups
    length_spump = size(vars.x_cont.s, 1);
    spump_vec = zeros(length_spump, 1);
    for i = 1:length_spump
        s_pump = 0;
        pumps_on = 0;
        for j = 1:no_pumps
            x_index_s = map_var_index_to_lp_vector(vars, 's', {i, j});
            x_index_n = map_var_index_to_lp_vector(vars, 'n', {i, j});
            n = x_vector(x_index_n);
            s = x_vector(x_index_s);
            if n == 1
                pumps_on = pumps_on + 1;
                s_pump = s_pump + s;
        end
        if pumps_on == 0
            pumps_on = 1;
        end
        spump_vec(i) = s_pump/pumps_on;
    end
end
