function y = intcon_vector_report(report_title, filename, vector, vars)
    % Writes a report about coefficients stored in a vector
    % The positions of coefficients in the vector are mapped
    % onto the vars structure.
    y = 0;
    fileID = fopen(filename,'w');
    vector_length = length(vector);
    fprintf(fileID, "REPORT TITLE: %s \n", report_title);
    fprintf(fileID, "------------------------ REPORT START -----------------------------\n");
    fprintf(fileID, "Vector length: %d\n", vector_length);
    for ix=1:length(vector)
        out_map = map_lp_vector_index_to_var(vars, vector(ix));
        variable = out_map.subfield_name;
        var_index = out_map.index;
        var_index_str = strjoin(string(var_index), ', ');
        fprintf(fileID, "Entry %d \t Value %d \t Variable %s \t Index: [%s] \n", ix, vector(ix), variable, var_index_str);
    end
    fprintf(fileID, "------------------------ REPORT END -----------------------------\n");
    fclose(fileID);
    y = 1;
end
