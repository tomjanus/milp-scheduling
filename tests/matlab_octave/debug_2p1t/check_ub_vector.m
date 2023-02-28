function y = check_ub_vector(ub_vector, vars)
    % Check the nonzero indices in the objective vector and map them to the variable structure
    y = 0;
    fprintf("Checking the ub vector ...\n");
    fprintf("Generating report...\n");
    report_title = "Vector of upper bounds";
    filename = "reports/upper_lower_bounds/ub.report";
    vector_report(report_title, filename, ub_vector, vars);
    fprintf("Done.\n");
    y = 1;
end
