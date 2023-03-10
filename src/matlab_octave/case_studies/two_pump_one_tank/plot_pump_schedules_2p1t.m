function y = plot_pump_schedules_2p1t(time_horizon, n_pumps, s_pumps, file_name, save_to_pdf)
    % Plot pump schedules from the results of the 2 pump 1 tank model
    AXIS_FONTSIZE = 22;
    ANNOTATION_FONTSIZE = 20;
    LABEL_FONTSIZE = 25;
    TITLE_FONTSIZE = 28;
    LEGEND_FONTSIZE = 18;
    
    hf4 = figure();
    time_1=[0:time_horizon];
    n_pumps=[n_pumps(1:time_horizon) n_pumps(time_horizon)];
    stairs(time_1,n_pumps,'LineWidth',2);
    hold on;
    s_pumps=[s_pumps(1:time_horizon) s_pumps(time_horizon)];
    stairs(time_1,s_pumps,'LineWidth',2);
    xticks(0:1:time_horizon);
    xlabel ('Time, hrs', 'fontsize', LABEL_FONTSIZE, 'interpreter', 'latex');
    ylabel('No. of pumps and pump speed', 'fontsize', LABEL_FONTSIZE, ...
      'interpreter', 'latex');
    title('Pump schedule', 'fontsize', TITLE_FONTSIZE,...
      'interpreter', 'latex');
    ll = legend('No. working pumps','Pump speed (relative to nominal)');
    set(ll,...
     'fontsize', LEGEND_FONTSIZE,...
     'interpreter', 'latex',...
     'color', 'none',...
     'box', 'off',...
     'Location','southwest');  
    set(gca,'fontsize', AXIS_FONTSIZE);
    xlim([0 time_horizon])
    xticks([0:2:time_horizon]);
    grid;
    hold off;
    if (save_to_pdf == 1) && (get_system() == "OCTAVE")
        print(hf4, file_name, '-dpdflatexstandalone');
        pdflatex_command = sprintf('pdflatex %s', filename);
        system(pdflatex_command);   
    end
end
