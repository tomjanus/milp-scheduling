function y = test_var_intlinprog_vec_mapping()
    % Tests the procedures for bi-directional mapping between var 
    % structure elements and the decision variable vector.
    warning('off','all');
    test_name = 'test_var_intlinprog_vec_mapping';
    fprintf('\nRunning test: %s \n', test_name);
    % Initialize vars structure using the 2p1t network structure
    [input,const,linprog,network,sim,pump_groups] = initialise_2p1t();
    vars = initialise_var_structure(network, linprog);
    number_variables = vars.n_cont + vars.n_bin;
    rand_indices = randi([1 number_variables],1,100);
    for i = 1:length(rand_indices)
        var_index = rand_indices(i);
        % Map randomly generated index in the LP var vector to var structure
        y = map_lp_vector_index_to_var(vars, var_index);
        % Inverse map the calculated var struct access data back to the index in the LP var vector
        var_index2 = map_var_index_to_lp_vector(vars, y.subfield_name, num2cell(y.index));
        % Check if both indices are equal
        assert(isequal(var_index, var_index2), 'indices not equal');
    end
    fprintf('\nTest passed \n');
    y = 1;
    warning('on','all');
