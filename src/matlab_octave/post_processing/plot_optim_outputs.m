function y = plot_optim_outputs(...
    input, x_vector, vars, optim_output, titles, folder)
    % Plot optimization outputs of the 2 pump 1 tank scheduling problem
    y = 0;
    time_horizon = 24;
    save_to_pdf = false;
    
    % Flows and demands
    q3 = get_element_flows(x_vector, vars, 3)';
    q4 = get_element_flows(x_vector, vars, 4)';
    q5 = get_element_flows(x_vector, vars, 5)';
    file_name1 = fullfile(folder, "optimized_system_flows");
    plot_elem_flows_demands_2p1t(time_horizon, input, q3, q4, q5, file_name1, titles{1}, save_to_pdf);
    % Nodal heads
    hc1 = get_heads(x_vector, vars, 1)';
    hc2 = get_heads(x_vector, vars, 2)';
    hc3 = get_heads(x_vector, vars, 3)';
    hc4 = get_heads(x_vector, vars, 4)';
    ht = get_tank_levels(x_vector, vars, 1)';
    file_name2 = fullfile(folder, "optimized_system_heads");
    plot_nodal_heads_2p1t(time_horizon, hc1, hc2, hc3, hc4, ht, file_name2, titles{2}, save_to_pdf);
    % Energy consumption
    file_name3 = fullfile(folder, 'optimized_energy_consumption');
    pump_power = get_pump_powers(x_vector, vars, 2);
    pump_cost = pump_power.*input.tariff';
    plot_energy_consumption_2p1t(time_horizon, input, pump_cost, file_name3, titles{3}, save_to_pdf);
    % Pump schedules
    file_name4 = fullfile(folder, 'optimized_schedule');
    n_pumps = get_number_working_pumps(x_vector, vars, 2)';
    %s_pumps = get_pump_speeds(x_vector, vars, 2)';
    s_pumps = optim_output.s;
    plot_linprog_pump_schedules_2p1t(time_horizon, n_pumps, s_pumps, file_name4, titles{4}, save_to_pdf);
    y = 1;
end
