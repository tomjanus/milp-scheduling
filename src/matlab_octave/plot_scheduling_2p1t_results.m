function y = plot_scheduling_2p1t_results(init_sim_output, optim_output, optim_sim_output, input, sim, vars)
    % Plot the results of the optimal pump scheduling exercise on a two pump one tank
    % system.
    % Args:
    % init_sim_output - output from the simulation with initial schedules
    % optim_output - output from the MILP model
    % optim_sim_output - output from the simulation with optimized schedules
    % input - input structure (shared between all models)
    % sim - sim structure with simulation configuration parameters
    % vars - variables structure
    y = 0;
    initial_simulation_titles = {...
        'Flow in selected elements - init', ...
        'Heads at selected nodes - init', ...
        'Energy cost and tariff - init schedule', ...
        'Pump schedule - initial'};
    lin_model_titles = {...
        'Flow in selected elements - linprog', ...
        'Heads at selected nodes - linprog', ...
        'Energy cost and tariff - linprog', ...
        'Pump schedule - linprog'};
    final_simulation_titles = {...
        'Flow in selected elements - optim', ...
        'Heads at selected nodes - optim', ...
        'Energy cost and tariff - optim schedule', ...
        'Pump schedule - optimized'};
    % Plot initial simulation results
        plot_2p1t_simulation_results(init_sim_output, ...
            input.init_schedule.N, input.init_schedule.S, input, sim, ...
            initial_simulation_titles, 1);
    % Plot optimization results
        plot_optim_outputs(input, optim_output.x, vars, lin_model_titles);
    % Plot results of simulation with optimized pump schedules
        plot_2p1t_simulation_results(optim_sim_output, ...
            optim_output.schedule.N, optim_output.schedule.S, input, ...
            sim, final_simulation_titles, 1);
    y = 1;
end