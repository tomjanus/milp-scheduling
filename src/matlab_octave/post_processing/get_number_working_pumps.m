function npump_vec = get_number_working_pumps(x_vector, vars, no_pumps)
    % Retrieve the number of working pumps at each time step
    % TODO: Generalize the function to work with multiple pump groups
    length_npump = size(vars.x_bin.n, 1);
    npump_vec = zeros(length_npump, 1);
    for i = 1:length_npump
        n_pump = 0;
        for j = 1:no_pumps
            x_index = map_var_index_to_lp_vector(vars, 'n', {i, j});
            n_pump = n_pump + x_vector(x_index);
        end
        npump_vec(i) = n_pump;
    end
end
