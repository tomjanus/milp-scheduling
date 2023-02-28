function y = check_lb_vector(lb_vector, vars)
    % Check the nonzero indices in the objective vector and map them to the variable structure
    y = 0;
    fprintf("Checking the lb vector ...\n");
    fprintf("Generating report...\n");
    report_title = "Vector of lower bounds";
    filename = "reports/upper_lower_bounds/lb.report";
    vector_report(report_title, filename, lb_vector, vars);
    fprintf("Done.\n");
    y = 1;
end
