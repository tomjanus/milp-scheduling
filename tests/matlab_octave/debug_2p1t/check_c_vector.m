function y = check_c_vector(c_vector, vars)
    % Check the nonzero indices in the objective vector and map them to the variable structure
    y = 0;
    fprintf("Checking the c vector ...\n");
    fprintf("Generating report...\n");
    report_title = "Objective vector c";
    filename = "reports/objective_function/c.report";
    vector_report(report_title, filename, c_vector, vars);
    fprintf("Done.\n");
    fprintf("Validating...\n");
    nonzero_indices = find(c_vector);
    p_vec_indices = get_array_indices(vars.x_cont.p);
    number_nozero_indices = length(nonzero_indices);
    var_names = cell(number_nozero_indices, 1);
    indices = zeros(size(p_vec_indices));
    for i = 1:number_nozero_indices
        ix = nonzero_indices(i);
        out = map_lp_vector_index_to_var(vars, ix);
        var_names{i} = out.subfield_name;
        indices(i, :) = out.index;
    end
    % Check if the variables are corresponding to power consumption
    if ~any(strcmp(var_names,'p'))
        error('some of the variables do not point to power (p)');
    end
    % Check if all of the indices match
    assert(isequal(indices,p_vec_indices), "Some of the indices do not match");
    % There should be 48 nonzero coefficients: 24 hours x 2 pumps
    assert(isequal(number_nozero_indices, 48), "Number of variables should equal 48");
    fprintf("c vector OKAY. \n\n");
    y = 1;
end
