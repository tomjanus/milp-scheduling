function y = plot_nodal_heads_2p1t(time_horizon, hc1, hc2, hc3, hc4, ht, file_name, plot_title, save_to_pdf)
    % Plot heads in calculated nodes in the two pump one tank system
    AXIS_FONTSIZE = 18;
    ANNOTATION_FONTSIZE = 20;
    LABEL_FONTSIZE = 21;
    TITLE_FONTSIZE = 24;
    LEGEND_FONTSIZE = 18;
    y = 0;
    hf2 = figure();
    hold on;
    hc1=[hc1(1:time_horizon) hc1(time_horizon)];
    hc2=[hc2(1:time_horizon) hc2(time_horizon)];
    hc3=[hc3(1:time_horizon) hc3(time_horizon)];
    hc4=[hc4(1:time_horizon) hc4(time_horizon)];
    ht=[ht(1:time_horizon) ht(time_horizon)];
    time_1=[0:time_horizon];
    stairs(time_1, hc1, 'LineWidth',2);
    stairs(time_1, hc2, 'LineWidth',2);
    stairs(time_1, hc3, 'LineWidth',2);
    stairs(time_1, hc4, 'LineWidth',2);
    plot(time_1, ht, 'k-*');
    xticks(0:1:time_horizon);
    xlabel ('Time, hrs', 'fontsize', LABEL_FONTSIZE, 'interpreter', 'latex');
    ylabel('Head, m', 'fontsize', LABEL_FONTSIZE, 'interpreter', 'latex');
    title(plot_title, 'fontsize', TITLE_FONTSIZE,...
      'interpreter', 'latex');
    ll = legend('$h_2$ - pump inlet','$h_3$ - pump outlet',...
      '$h_4$ - node 4','$h_6$ - demand node', '$h_t$ - tank level');
    set(ll,...
     'fontsize', LEGEND_FONTSIZE,...
     'interpreter', 'latex',...
     'color', 'none',...
     'box', 'off',...
     'Location','southwest');   
    set(gca,'fontsize', AXIS_FONTSIZE)
    xlim([0 time_horizon])
    ylim([210 240])
    xticks([0:2:time_horizon])    
    grid on;
    hold off;
    if (save_to_pdf == 1) && (get_system() == "OCTAVE")
        print(hf2, file_name, '-dpdflatexstandalone');
        pdflatex_command = sprintf('pdflatex %s', file_name);
        system(pdflatex_command);   
    end
    y = 1;
end
