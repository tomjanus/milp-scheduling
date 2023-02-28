function y = check_intcon_vector(intcon_vector, vars)
    % Check which variables are marked as integer variables
    % in the intcon variable vector and generate report
    y = 0;
    fprintf("Checking the intcon vector ...\n");
    number_intcon_indices = length(intcon_vector);
    fprintf("Number of integer variables %d \n", number_intcon_indices);
    report_title = "Integer variables";
    filename = "reports/intcon_vector/intcon.report";
    intcon_vector_report(report_title, filename, intcon_vector, vars);
    fprintf("Checking the intcon vector finished.\n");
    y = 1;
end
