function y = vector_report(report_title, filename, vector, vars)
    % Writes a report about coefficients stored in a vector
    % The positions of coefficients in the vector are mapped
    % onto the vars structure.
    y = 0;
    fileID = fopen(filename,'w');
    nonzero_indices = find(vector);
    fprintf(fileID, "REPORT TITLE: %s \n", report_title);
    fprintf(fileID, "------------------------ REPORT START -----------------------------\n");
    fprintf(fileID, "Vector length: %d\n", length(vector));
    fprintf(fileID, "Number of non-zero elements: %d\n", length(nonzero_indices));
    if issparse(vector)
        % NOTE: fprintf does not work with sparse matrix representations
        vector = full(vector);
    end
    for ix=1:length(nonzero_indices)
        out_map = map_lp_vector_index_to_var(vars, nonzero_indices(ix));
        variable = out_map.subfield_name;
        var_index = out_map.index;
        var_index_str = strjoin(string(var_index), ', ');
        fprintf(fileID, "Non-zero entry %d \t Index %d \t Value %f \t Variable %s \t Index: [%s] \n", ...
            ix, nonzero_indices(ix), vector(nonzero_indices(ix)), variable, var_index_str);
    end
    fprintf(fileID, "------------------------ REPORT END -----------------------------\n");
    fclose(fileID);
    y = 1;
end
