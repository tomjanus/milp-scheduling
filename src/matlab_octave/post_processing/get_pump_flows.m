function qpump_vec = get_pump_flows(x_vector, vars, no_pumps)
    % Retrieve pump group flows from the vector of decision variables x
    % TODO: Generalize the function to work with multiple pump groups
    length_qpump = size(vars.x_cont.q, 1);
    qpump_vec = zeros(length_qpump, 1);
    for i = 1:length_qpump
        q_pump = 0;
        for j = 1:no_pumps
            x_index = map_var_index_to_lp_vector(vars, 'q', {i, j});
            q_pump = q_pump + x_vector(x_index);
        end
        qpump_vec(i) = q_pump;
    end
end
