function y = plot_energy_consumption_2p1t(time_horizon, input, pump_power, file_name, plot_title, save_to_pdf)
    % Plot energy consumption due to pumping in the 2 pump 1 tank network.
    AXIS_FONTSIZE = 18;
    ANNOTATION_FONTSIZE = 20;
    LABEL_FONTSIZE = 21;
    TITLE_FONTSIZE = 24;
    LEGEND_FONTSIZE = 16;
    y = 0;
    hf3 = figure();
    xticks(0:1:time_horizon);
    xlabel ('Time, hrs', 'fontsize', LABEL_FONTSIZE, 'interpreter', 'latex');
    yyaxis left
    pump_power=[pump_power(1:time_horizon); pump_power(time_horizon)];
    time_1=[0:time_horizon];
    stairs(time_1, pump_power,'LineWidth',2);
    ylabel('Pumping cost [GBP/hr]', 'fontsize', LABEL_FONTSIZE, ...
      'interpreter', 'latex');
    hold on;
    ylim([0 10])
    yyaxis right
    tariff=[input.tariff(1:time_horizon) input.tariff(time_horizon)];
    stairs(time_1, tariff * 1000,'LineWidth',2);
    ylabel('Energy tariff [GBP/MWh]', 'fontsize', LABEL_FONTSIZE, ...
      'interpreter', 'latex');
    title(plot_title, 'fontsize', TITLE_FONTSIZE,...
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
    ylim([60 160])
    grid;
    hold off;
    if (save_to_pdf == 1) && (get_system() == "OCTAVE")
        print(hf3, file_name, '-dpdflatexstandalone');
        pdflatex_command = sprintf('pdflatex %s', file_name);
        system(pdflatex_command);   
    end
    y = 1;
end
