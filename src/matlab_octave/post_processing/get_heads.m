function heads = get_heads(x_vector, vars, calc_node_number)
    % Retrieve information about calculated head levels from decision
    % variable vector x 
    length_heads = length(vars.x_cont.hc(:,calc_node_number));
    heads = zeros(length_heads, 1);
    for i = 1:length_heads
        x_index = map_var_index_to_lp_vector(vars, 'hc', {i,calc_node_number});
        heads(i) = x_vector(x_index);
    end
end
