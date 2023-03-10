function qel = get_element_flows(x_vector, vars, el_number)
    % Retrieve information about calculated element flows from decision
    % variable vector x 
    length_qel = length(vars.x_cont.qel(:, el_number));
    qel = zeros(length_qel, 1);
    for i = 1:length_qel
        x_index = map_var_index_to_lp_vector(vars, 'qel', {i, el_number});
        qel(i) = x_vector(x_index);
    end
end
