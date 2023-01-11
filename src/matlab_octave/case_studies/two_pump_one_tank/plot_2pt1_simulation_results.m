function y = plot_2pt1_simulation_results(output,N,S,input)
  % unpack the outputs structure
  q = output.q;
  hc = output.hc;
  ht = output.ht;
  P = output.P;
  
  % Plot simulation results
  AXIS_FONTSIZE = 18;
  ANNOTATION_FONTSIZE = 20;
  LABEL_FONTSIZE = 18;
  TITLE_FONTSIZE = 24;
  LEGEND_FONTSIZE = 16;
  TIME_HORIZON = 24;
  
  time_1=[0:TIME_HORIZON];
  
  print_plots = [1, 1, 1, 1];
  save_to_pdf = 0;
  
  if (print_plots(1) == 1)
    % Plot element flows and demand
    hf1=figure();
    hold on;
    q3=[q(3,:) q(3,TIME_HORIZON)];
    stairs(time_1,q3,'LineWidth',2);
    q4=[q(4,:) q(4,TIME_HORIZON)];
    stairs(time_1,q4,'LineWidth',2);
    q5=[q(5,:) q(5,TIME_HORIZON)];
    stairs(time_1, q5,'LineWidth',2);
    % Plot demand
    demand=[input.demand*input.df, input.demand(TIME_HORIZON)*input.df];
    demand_point = stairs(time_1, demand,'o');
    set(demand_point                         , ...
    'Marker'          , 'o'         , ...
    'MarkerSize'      , 8           , ...
    'MarkerFaceColor' , [1 1 1] );
    xticks(0:1:TIME_HORIZON);
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
    xlabel ("Time, hrs", 'fontsize', LABEL_FONTSIZE, 'interpreter', 'latex');
    ylabel ("Flow, L/s", 'fontsize', LABEL_FONTSIZE,...
      'interpreter', 'latex');
    set(gca,"fontsize", AXIS_FONTSIZE)
    xlim([0 24])
    xticks([0:2:24])
    grid on;
    hold  off;
    if (save_to_pdf == 1)
      print (hf1, "plots/flows_n_demand_initial", "-dpdflatexstandalone");
      system ("pdflatex plots/flows_n_demand_initial plots/flows_n_demand_initial");     
    end
  end
  
  if (print_plots(2) == 1)
    % HEAD AT NODES
    hf2 = figure();
    hold on;
    hc1=[hc(1,:) hc(1,TIME_HORIZON)];
    stairs(time_1,hc1,'LineWidth',2);
    hc2=[hc(2,:) hc(2,TIME_HORIZON)];
    stairs(time_1,hc2,'LineWidth',2);
    hc3=[hc(3,:) hc(3,TIME_HORIZON)];
    stairs(time_1,hc3,'LineWidth',2);
    hc4=[hc(4,:) hc(4,TIME_HORIZON)];
    stairs(time_1,hc4,'LineWidth',2);
    plot(time_1,ht,'k-*');
    xticks(0:1:TIME_HORIZON);
    xlabel ("Time, hrs", 'fontsize', LABEL_FONTSIZE, 'interpreter', 'latex');
    ylabel('Head, m', 'fontsize', LABEL_FONTSIZE, 'interpreter', 'latex');
    title('Heads at selected nodes', 'fontsize', TITLE_FONTSIZE,...
      'interpreter', 'latex');
    ll = legend('$h_2$ - pump inlet','$h_3$ - pump outlet',...
      '$h_4$ - node 4','$h_6$ - demand node', '$h_t$ - tank level');
    set(ll,...
     'fontsize', LEGEND_FONTSIZE,...
     'interpreter', 'latex',...
     'color', 'none',...
     'box', 'off',...
     'Location','southwest');   
    set(gca,"fontsize", AXIS_FONTSIZE)
    xlim([0 24])
    xticks([0:2:24])    
    grid on;
    hold off;
    if (save_to_pdf == 1)
      print (hf2, "scheduling_plots/heads_initial", "-dpdflatexstandalone");
      system ("pdflatex plots/heads_initial plots/heads_initial");     
    end
  end
  
  if (print_plots(3) == 1)
     % ENERGY CONSUMPTION
    hf3 = figure();
    P1=[P; P(TIME_HORIZON)];
    stairs(time_1,P1,'LineWidth',2);
    hold on;
    T1=[input.tariff input.tariff(TIME_HORIZON)];
    stairs(time_1,100*T1,'LineWidth',2);
    xticks(0:1:TIME_HORIZON);
    xlabel ("Time, hrs", 'fontsize', LABEL_FONTSIZE, 'interpreter', 'latex');
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
    set(gca,"fontsize", AXIS_FONTSIZE)
    xlim([0 24])
    xticks([0:2:24])    
    grid;
    hold off;
    if (save_to_pdf == 1)
      print (hf3, "scheduling_plots/energy_consumption", "-dpdflatexstandalone");
      system ("pdflatex plots/energy_consumption plots/energy_consumption");     
    end
  end

  if (print_plots(4) == 1)
    % PUMP SCHEDULES
    hf4 = figure();
    N1=[N N(TIME_HORIZON)];
    stairs(time_1,N1,'LineWidth',2);
    hold on;
    S1=[S S(TIME_HORIZON)];
    stairs(time_1,S1,'LineWidth',2);
    xticks(0:1:TIME_HORIZON);
    xlabel ("Time, hrs", 'fontsize', LABEL_FONTSIZE, 'interpreter', 'latex');
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
    set(gca,"fontsize", AXIS_FONTSIZE)
    xlim([0 24])
    xticks([0:2:24])    
    grid;
    hold off;
    if (save_to_pdf == 1)
      print (hf3, "scheduling_plots/schedule", "-dpdflatexstandalone");
      system ("pdflatex plots/schedule plots/schedule");     
    end
  end

end
