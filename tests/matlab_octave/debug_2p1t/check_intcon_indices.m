function y = check_intcon_indices(intcon_vector, vars)
    %
    number_intcon_indices = length(intcon_vector);
    var_names = cell(number_intcon_indices, 1);
    for i = 1:number_intcon_indices
        ix = intcon_vector(i);
        out = map_lp_vector_index_to_var(vars, ix);
        var_names{i} = out.subfield_name;
        %indices(i, :) = out.index;
    end
    fprintf("Checking the intcon vector ...\n")
    fprintf("Integer variables: \n")
    fprintf('%s, ',var_names{:})
    fprintf('\n')
    % There needs to be 528 integer variables
    assert(isequal(length(var_names), 528), "Number of integer variables needs to be equal to 528")
    fprintf("Intcon vector OKAY. \n\n")
end
