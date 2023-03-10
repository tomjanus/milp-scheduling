function y = plot_elem_flows_demands_2p1t(time_horizon, input, q3, q4, q5, file_name, save_to_pdf)
    % Plot element flows from the two pump one tank system
    AXIS_FONTSIZE = 22;
    ANNOTATION_FONTSIZE = 20;
    LABEL_FONTSIZE = 25;
    TITLE_FONTSIZE = 28;
    LEGEND_FONTSIZE = 18;
    y = 0;
    % Plot element flows and demand
    hf1=figure();
    hold on;
    % Add padding
    q3 = [q3(1:time_horizon) q3(time_horizon)];
    q4 = [q4(1:time_horizon) q4(time_horizon)];
    q5 = [q5(1:time_horizon) q5(time_horizon)];
    time_1=[0:time_horizon];
    stairs(time_1,q3,'LineWidth',2);
    stairs(time_1,q4,'LineWidth',2);
    stairs(time_1, q5,'LineWidth',2);
    % Plot demand
    demand=[input.demands(4,1:time_horizon)*input.df, input.demands(4, time_horizon)*input.df];
    demand_point = stairs(time_1, demand,'o');
    set(demand_point, ...
    'Marker', 'o', ...
    'MarkerSize', 8, ...
    'MarkerFaceColor', [1 1 1]);
    xticks(0:1:time_horizon);
    title('Flow in selected elements', 'fontsize', TITLE_FONTSIZE,...
      'interpreter', 'latex');
    ll = legend('$q_3$ - pump','$q_4$ - tank feed','$q_5$ - demand supply', ...
      'forced demand');
    set(ll,...
      'fontsize', LEGEND_FONTSIZE,...
      'interpreter', 'latex',...
      'color', 'none',...
      'box', 'off',...
      'Location','southwest');
    xlabel ('Time, hrs', 'fontsize', LABEL_FONTSIZE, 'interpreter', 'latex');
    ylabel ('Flow, L/s', 'fontsize', LABEL_FONTSIZE,...
      'interpreter', 'latex');
    set(gca,'fontsize', AXIS_FONTSIZE)
    xlim([0 time_horizon])
    xticks([0:2:time_horizon])
    grid on;
    hold  off;
    if (save_to_pdf == 1) && (get_system() == "OCTAVE")
      print(hf1, file_name, '-dpdflatexstandalone');
      pdflatex_command = sprintf('pdflatex %s', filename);
      system(pdflatex_command);     
    end
    y = 1;
end
