function y = plot_2p1t_simulation_results(output, N, S, input, sim, save_to_pdf)
 
  print_plots = [1, 1, 1, 1]; 
  y = 0;
  TIME_HORIZON = 24;
  
  % Plot element flows and demand
  if (print_plots(1) == 1)
    file_name1 = 'flows_n_demand_initial';
    q3 = output.q(3,:);
    q4 = output.q(4,:);
    q5 = output.q(5,:);
    plot_elem_flows_demands_2p1t(TIME_HORIZON, input, q3, q4, q5, file_name1, save_to_pdf);
  end
  % Plot heads at nodes
  if (print_plots(2) == 1)
    file_name2 = 'heads_initial';
    hc1 = output.hc(1,:);
    hc2 = output.hc(2,:);
    hc3 = output.hc(3,:);
    hc4 = output.hc(4,:);
    ht = output.ht(1:end-1);
    plot_nodal_heads_2p1t(TIME_HORIZON, hc1, hc2, hc3, hc4, ht, file_name2, save_to_pdf);
  end
  % Plot energy consumption
  if (print_plots(3) == 1)
    pump_power = output.P;
    file_name3 = 'energy_consumption';
    plot_energy_consumption_2p1t(TIME_HORIZON, input, pump_power, file_name3, save_to_pdf);
  end
  % Plot pump schedules
  if (print_plots(4) == 1)
    file_name4 = 'schedule';
    plot_pump_schedules_2p1t(TIME_HORIZON, N, S, file_name4, save_to_pdf);
  end
  y = 1;
end
