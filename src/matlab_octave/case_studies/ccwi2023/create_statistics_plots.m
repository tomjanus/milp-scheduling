%
% Assume that batch_outputs are loaded into workspace

AXIS_FONTSIZE = 14;
ANNOTATION_FONTSIZE = 20;
LABEL_FONTSIZE = 18;
TITLE_FONTSIZE = 18;
LEGEND_FONTSIZE = 16;


times = [];
milp_cost = [];
simulator_cost = [];
rmse = []; % Root mean squared error of the tank level (simulation vs milp), (m)
mae = []; % Mean absolute error of the tank level (simulation vs milp), (m)

tank_diameters = [];
tank_elevations = [];
mean_demands = [];
final_level_diffs = [];

batch_outputs_1d = reshape(batch_outputs, 1, []);
failed_runs = 0;
for i=1:numel(batch_outputs)
    if batch_outputs{i}.statistics.failed_run == 1;
        % Skip failed run times
        failed_runs = failed_runs + 1;
        continue
    end
    times(i) = batch_outputs{i}.statistics.optimization_time;
    milp_cost(i) = batch_outputs{i}.outputs.milp_cost;
    simulator_cost(i) = batch_outputs{i}.outputs.simulated_cost;
    
    %cost_diff(i) = 100*(simulator_cost(i) - milp_cost(i))/simulator_cost(i);
    rmse(i) = batch_outputs{i}.outputs.ht_rmse;
    mae(i) = batch_outputs{i}.outputs.ht_mae;
    
    tank_diameters(i) = batch_outputs{i}.inputs.tank_diameter;
    tank_elevations(i) = batch_outputs{i}.inputs.elevation;
    mean_demands(i) = batch_outputs{i}.inputs.mean_demand;
    final_level_diffs(i) = batch_outputs{i}.inputs.elevation + 2.5 - batch_outputs{i}.inputs.final_level;
end

sprintf("No. of counted failer runs: %d", failed_runs)

hf1 = figure();
histogram(times);
set(gca,'fontsize', AXIS_FONTSIZE)
% Add labels and title
xlabel('Optimization time, seconds', 'fontsize', LABEL_FONTSIZE, 'interpreter', 'latex');
ylabel('Number of occurrences, -', 'fontsize', LABEL_FONTSIZE, 'interpreter', 'latex');
%title('Histogram of Optimization Run Times');

hf2 = figure();
histogram(mae);
set(gca,'fontsize', AXIS_FONTSIZE)
% Add labels and title
xlabel('Tank level MAE : simulation vs. MILP, m', ...
    'fontsize', LABEL_FONTSIZE, 'interpreter', 'latex');
ylabel('Number of occurrences, -', 'fontsize', LABEL_FONTSIZE, ...
    'interpreter', 'latex');
%itle('Histogram of operating cost relative differences');

% Todo: check the optimization cost gap in % between linprog and the simulator
% Present results only for which final_level_diff = -0.5
ix_diff_neg_half = find(final_level_diffs == -0.5);
ix_diff_pos_half = find(final_level_diffs == 0.5);

% Make a 4d multiplot
hf3 = figure();
ax1 = axes('Parent', hf3);
c = 40 + 40 * final_level_diffs;
scatter3(tank_diameters(ix_diff_neg_half),tank_elevations(ix_diff_neg_half),...
    mean_demands(ix_diff_neg_half),110,milp_cost(ix_diff_neg_half),...
    'filled', 'MarkerFaceAlpha', 1.0, 'MarkerEdgeColor', 'k');
font_scale = 0.8;
title("Tank level difference: +0.5m", 'fontsize', TITLE_FONTSIZE, 'interpreter', 'latex')
xlabel('Tank dia, m', ...
    'fontsize', font_scale*LABEL_FONTSIZE, 'interpreter', 'latex');
ylabel('Tank elev, m', ...
    'fontsize', font_scale*LABEL_FONTSIZE, 'interpreter', 'latex');
zlabel('Mean demand., m$^3$/s', ...
    'fontsize', font_scale*LABEL_FONTSIZE, 'interpreter', 'latex');
hold on
x_surface1 = [12, 18, 18, 12, 12]; % Replace with your values
y_surface1 = [230, 230, 230, 230, 230]; % Replace with your values
z_surface1 = [50, 50, 30, 30, 50]; % Replace with your values
surface_color = [0.0, 0.0, 0.0]; % Gray colorbar
h_surface1 = surf([x_surface1; x_surface1], [y_surface1; y_surface1], ...
                 [z_surface1; z_surface1], 'FaceColor', surface_color);
                 
x_surface2 = [12, 18, 18, 12, 12]; % Replace with your values
y_surface2 = [235, 235, 235, 235, 235]; % Replace with your values
z_surface2 = [50, 50, 30, 30, 50]; % Replace with your values
surface_color = [0.0, 0.0, 0.0]; % Gray colorbar
h_surface2 = surf([x_surface2; x_surface2], [y_surface2; y_surface2], ...
                 [z_surface2; z_surface2], 'FaceColor', surface_color);
                 
x_surface3 = [12, 18, 18, 12, 12]; % Replace with your values
y_surface3 = [225, 225, 225, 225, 225]; % Replace with your values
z_surface3 = [50, 50, 30, 30, 50]; % Replace with your values
surface_color = [0.0, 0.0, 0.0]; % Gray colorbar
h_surface3 = surf([x_surface3; x_surface3], [y_surface3; y_surface3], ...
                 [z_surface3; z_surface3], 'FaceColor', surface_color);

alpha_value = 1; % Adjust the transparency level (0 = fully transparent, 1 = fully opaque)
set(h_surface1, 'FaceAlpha', alpha_value);
set(h_surface2, 'FaceAlpha', alpha_value);
set(h_surface3, 'FaceAlpha', alpha_value);
view(ax1,[-69.65 17.4]);
cb = colorbar(ax1);                                     % create and label the colorbar
cb.Title.String = 'MILP cost, GBP';
cb.Title.FontSize = 12;
cb.Title.Interpreter = 'latex';
caxis_limits = caxis;

hf4 = figure();
ax2 = axes('Parent', hf4);
c = 40 + 40 * final_level_diffs;
scatter3(tank_diameters(ix_diff_pos_half),tank_elevations(ix_diff_pos_half),...
    mean_demands(ix_diff_pos_half),110,milp_cost(ix_diff_pos_half),...
    'filled', 'MarkerFaceAlpha', 1.0, 'MarkerEdgeColor', 'k');
font_scale = 0.8;
title("Tank level difference: -0.5m", 'fontsize', TITLE_FONTSIZE, 'interpreter', 'latex')
xlabel('Tank dia, m', ...
    'fontsize', font_scale*LABEL_FONTSIZE, 'interpreter', 'latex');
ylabel('Tank elev, m', ...
    'fontsize', font_scale*LABEL_FONTSIZE, 'interpreter', 'latex');
zlabel('Mean demand., m$^3$/s', ...
    'fontsize', font_scale*LABEL_FONTSIZE, 'interpreter', 'latex');
hold on
x_surface1 = [12, 18, 18, 12, 12]; % Replace with your values
y_surface1 = [230, 230, 230, 230, 230]; % Replace with your values
z_surface1 = [50, 50, 30, 30, 50]; % Replace with your values
surface_color = [0.0, 0.0, 0.0]; % Gray colorbar
h_surface1 = surf([x_surface1; x_surface1], [y_surface1; y_surface1], ...
                 [z_surface1; z_surface1], 'FaceColor', surface_color);
                 
x_surface2 = [12, 18, 18, 12, 12]; % Replace with your values
y_surface2 = [235, 235, 235, 235, 235]; % Replace with your values
z_surface2 = [50, 50, 30, 30, 50]; % Replace with your values
surface_color = [0.0, 0.0, 0.0]; % Gray colorbar
h_surface2 = surf([x_surface2; x_surface2], [y_surface2; y_surface2], ...
                 [z_surface2; z_surface2], 'FaceColor', surface_color);
                 
x_surface3 = [12, 18, 18, 12, 12]; % Replace with your values
y_surface3 = [225, 225, 225, 225, 225]; % Replace with your values
z_surface3 = [50, 50, 30, 30, 50]; % Replace with your values
surface_color = [0.0, 0.0, 0.0]; % Gray colorbar
h_surface3 = surf([x_surface3; x_surface3], [y_surface3; y_surface3], ...
                 [z_surface3; z_surface3], 'FaceColor', surface_color);

alpha_value = 1; % Adjust the transparency level (0 = fully transparent, 1 = fully opaque)
set(h_surface1, 'FaceAlpha', alpha_value);
set(h_surface2, 'FaceAlpha', alpha_value);
set(h_surface3, 'FaceAlpha', alpha_value);
view(ax2,[-69.65 17.4]);
cb2 = colorbar(ax2);                                     % create and label the colorbar
cb2.Title.String = 'MILP cost, GBP';
cb2.Title.FontSize = 12;
cb2.Title.Interpreter = 'latex';
caxis(caxis_limits);
