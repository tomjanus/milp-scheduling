function y = eq_ineq_constraint_report(report_title, filename, A_matrix, b_vector, vars)
    % Writes a report about constraint formulation into a text file
    y = 0;
    fileID = fopen(filename,'w');
    fprintf(fileID, "REPORT TITLE: %s \n", report_title);
    fprintf(fileID, "------------------------ REPORT START -----------------------------\n");
    for i=1:length(b_vector)
        fprintf(fileID, "Entry %d \n", i);
        fprintf(fileID, "\tRHS = %.1f \n", b_vector(i));
        nonzero_indices = find(A_matrix(i,:));
        fprintf(fileID, "\tLHS: \n");
        for j = 1:length(nonzero_indices)
            ix = nonzero_indices(j);
            out_map = map_lp_vector_index_to_var(vars, ix);
            coeff = A_matrix(i,ix);
            variable = out_map.subfield_name;
            var_index = out_map.index;
            var_index_str = strjoin(string(var_index), ', ');
            fprintf(fileID, "\t\tCoefficient: %f , Variable: %s , Index: [%s] \n", ...
                    coeff, variable, var_index_str);
        end
    end
    fprintf(fileID, "------------------------ REPORT END -----------------------------\n");
    fclose(fileID);
    y = 1;
end
