function y = plot_energy_consumption_2p1t(time_horizon, input, pump_power, file_name, save_to_pdf)
    % Plot energy consumption due to pumping in the 2 pump 1 tank network.
    AXIS_FONTSIZE = 22;
    ANNOTATION_FONTSIZE = 20;
    LABEL_FONTSIZE = 25;
    TITLE_FONTSIZE = 28;
    LEGEND_FONTSIZE = 18;
    y = 0;
    hf3 = figure();
    pump_power=[pump_power(1:time_horizon); pump_power(time_horizon)];
    time_1=[0:time_horizon];
    stairs(time_1, pump_power,'LineWidth',2);
    hold on;
    tariff=[input.tariff(1:time_horizon) input.tariff(time_horizon)];
    stairs(time_1, 100*tariff,'LineWidth',2);
    xticks(0:1:time_horizon);
    xlabel ('Time, hrs', 'fontsize', LABEL_FONTSIZE, 'interpreter', 'latex');
    ylabel('Energy cost [£/kWh]', 'fontsize', LABEL_FONTSIZE, ...
      'interpreter', 'latex');
    title('Energy cost and tariff', 'fontsize', TITLE_FONTSIZE,...
      'interpreter', 'latex');
    ll=legend('energy cost','tariff');
    set(ll,...
     'fontsize', LEGEND_FONTSIZE,...
     'interpreter', 'latex',...
     'color', 'none',...
     'box', 'off',...
     'Location','southwest');   
    set(gca,'fontsize', AXIS_FONTSIZE)
    xlim([0 time_horizon])
    xticks([0:2:time_horizon])    
    grid;
    hold off;
    if (save_to_pdf == 1) && (get_system() == "OCTAVE")
        print(hf3, file_name, '-dpdflatexstandalone');
        pdflatex_command = sprintf('pdflatex %s', filename);
        system(pdflatex_command);   
    end
    y = 1;
end
