for i=1:numel(batch_outputs)
    
    tank_diameters(i) = batch_outputs{i}.inputs.tank_diameter;
    tank_elevations(i) = batch_outputs{i}.inputs.elevation;
    mean_demands(i) = batch_outputs{i}.inputs.mean_demand;
    final_level_diffs(i) = batch_outputs{i}.inputs.elevation + 2.5 - batch_outputs{i}.inputs.final_level;
    mae(i) = batch_outputs{i}.outputs.ht_mae;
end

ix = find(mae > 0.6);
disp("Tank diameters: ")
disp(tank_diameters(ix))

disp("Tank elevations: ")
disp(tank_elevations(ix))

disp("Mean demands: ")
disp(mean_demands(ix))

disp("Final level diff")
disp(final_level_diffs(ix))

disp("MAES")
disp(mae(ix))
