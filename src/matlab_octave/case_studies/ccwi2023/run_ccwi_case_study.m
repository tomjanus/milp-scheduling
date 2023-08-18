%% Script for running a study on the 2p1t system for the CCWI2023 conference
 % paper.

 % Runs a series of optimizations with different parameterizations of the 
 % network and inputs
 % - tank area
 make_plots = false;

%% Load 2p1t network and input data
[input,const,linprog,network,sim,pump_groups] = initialise_2p1t();

network_default = network;
input_default = input;
% Get default values of parameters that will be changed
tank_diameter_default = network_default.tanks.diameter;
tank_area_default = network_default.tanks.area;
tank_height_default = network_default.tanks.elevation;
init_level_default = network_default.tanks.init_level;
demands_default = input_default.demands;

n_vals = 3;
diameter_multipliers = [0.85, 1.0, 1.15];
tank_height_diff = [-5, 0, +5];
init_level_diff = [-0.5, 0, 0.5];
demand_multipliers = [0.8, 1.0, 1.10];

n_areas = length(diameter_multipliers);
n_elevs = length(tank_height_diff);
n_elev_final = length(init_level_diff);
n_demands = length(demand_multipliers);

tank_diameters = tank_diameter_default * diameter_multipliers;
tank_areas = zeros(size(tank_diameters));
for i = 1:n_areas
    tank_areas(i) = 0.25 * pi * tank_diameters(i)^2;
end
tank_heights = zeros(size(tank_height_diff));
for i = 1:n_elevs
    tank_heights(i) = tank_height_default + tank_height_diff(i);
end
demands_struct = {};
for i = 1:n_demands
    scaled_demands = demands_default * demand_multipliers(i);
    demands_struct{i} = scaled_demands;
end

% Run the study in nested for loops
% Breaking my commitment to being a seldom-nester. Blame it on MATLAB

% Create a unique outputs folder
current_time = now;
time_string = datestr(current_time, 'yyyymmdd_HHMMSS');
unique_id = time_string;
outputs_folder = sprintf('outputs_%s',unique_id);

failed_runs = 0;
counter = 0;
batch_outputs = cell(n_areas, n_elevs, n_demands, n_elev_final);
for tank_area_ix = 1:n_areas
    for tank_height_ix = 1:n_elevs
        for demand_ix = 1:n_demands
            for final_level_ix=1:n_elev_final
                counter = counter + 1;
                %% Initialise continuous and binary variable structures required 
                %  to construct linear programme 

                % Set the inputs
                inputs.tank_diameter = tank_diameters(tank_area_ix);
                inputs.tank_diameter_default = tank_diameter_default;
                inputs.area = tank_areas(tank_area_ix);
                inputs.area_default = tank_area_default;
                inputs.elevation = tank_heights(tank_height_ix);
                inputs.elevation_default = tank_height_default;
                inputs.demands = demands_struct{demand_ix}
                inputs.mean_demand = full(mean(demands_struct{demand_ix}(4,:)));
                inputs.mean_demand_default = full(mean(demands_struct{2}(4,:)));
                inputs.final_level = inputs.elevation + init_level_default + ...
                    init_level_diff(final_level_ix);
                inputs.init_schedule = input.init_schedule;
                
                % Set the variables read by the optimizer and the simulator
                vars = initialise_var_structure(network, linprog);
                % Change the area, height and demand parameters
                network.tanks.diameter = inputs.tank_diameter;
                network.tanks.area = inputs.area;
                network.tanks.elevation = inputs.elevation;
                network.tanks.ht0 = network.tanks.elevation + network.tanks.init_level;
                input.demands = inputs.demands;
                final_level = inputs.final_level;
                %% Initial simulation to simulate flows, calculated heads, power 
                 % consumption and tank levels

                % STEP 1 - initial simulation and MILP formulation
                init_sim_output = simulator_2p1t(...
                    input.init_schedule, network, input, sim);

                % Create a folder in which the data and figures will be saved
                % Write a readme text file that contains information about
                % the parameters selected for (this particular) optimization.
                folder_name = sprintf(...
                    'output_%d_%d_%d_%d', tank_area_ix, tank_height_ix,...
                    demand_ix, final_level_ix);
                local_output_folder = fullfile(outputs_folder,folder_name);
                mkdir(local_output_folder);
                file_path = fullfile(outputs_folder, folder_name, 'readme.txt');
                fileID = fopen(file_path, 'w');
                if fileID == -1
                    error('Could not open the file for writing.');
                end
                % Write three lines of text to the file
                fprintf(fileID, 'The folder contains optimization study results with the following parameters.\n');
                fprintf(fileID, "-----------------------------------------------------------------------------\n");
                fprintf(fileID, 'Tank area %.2f : %.2f of the original area.\n', ...
                    network.tanks.area, diameter_multipliers(tank_area_ix));
                fprintf(fileID, 'Tank elevation %.2f = original elevation + %.2f m.\n', ...
                    network.tanks.elevation, tank_height_diff(tank_height_ix));
                fprintf(fileID, 'Average demand %.2f : %.2f of original demand.\n', ...
                    full(mean(input.demands(4,:))), ...
                    demand_multipliers(demand_ix));
                fprintf(fileID, 'Initial tank level: %.2f m\n', ...
                    network.tanks.elevation + network.tanks.init_level);
                fprintf(fileID, 'Enforced final tank level: %.2f m\n', ...
                    final_level);
                fprintf(fileID, "-----------------------------------------------------------------------------");
                fclose(fileID);

                %% Transform network to a mixed integer linear model
                mps_filename = fullfile(local_output_folder, '2p1t_model.mps'); % Model formulation will be saved to this file in the mps file format
                mat_filename = fullfile(local_output_folder, '2p1t_model.mat'); % Model matrices will be saved to this file in the mat file format
                lin_model = transform_2p1t_to_milp_ccwi2023(...
                    input, linprog, network, ...
                    pump_groups, init_sim_output, 1, 1, 1, final_level, ...
                    mps_filename, mat_filename);
                % Save state for part 2 of the analysis
                optim_step1_path = fullfile(local_output_folder, "optim_step1.mat");
                save(optim_step1_path, "input", "network", "sim", "vars", "init_sim_output");

                % Optimization with cplex
                cplex_output_filename = fullfile(local_output_folder, 'cplex_results.mat');
                cmd = 'python run_cplex.py %s %s';
                command_full = sprintf(cmd, mps_filename, cplex_output_filename);

                [status, cmdout] = system(command_full);
                save(fullfile(local_output_folder, "optim_out.mat"), "status", "cmdout");
                statistics.status = status;
                statistics.cmd_out = cmdout;

                % Step 2
                load(optim_step1_path);
                
                try
                    load(cplex_output_filename, "x", "time", "obj"); % Needs to load optimization state variable `x`
                    % Retrieve pump schedule from the optimal state vector x
                    [n, s] = find_schedule_from_x(1, vars, x);
                    outputs.x = x;
                    outputs.n = n;
                    outputs.s = s;
                    outputs.milp_cost = obj;
                    statistics.optimization_time = time;
                    statistics.failed_run = false;
                    %% Obtain schedule structure that is compatible with the simulator
                    % NOTE: In scheduler, each pump is represented individually whilst simulator models
                    %       groups of pumps as one unit
                    % NOTE: This only works for a single pump group
                    
                catch
                    disp("CPLEX did not output results. It probably crashed. Solving other cases...");
                    statistics.failed_run = true;
                    failed_runs = failed_runs + 1;
                    batch_outputs{tank_area_ix, tank_height_ix, demand_ix, final_level_ix}.inputs = inputs;
                    batch_outputs{tank_area_ix, tank_height_ix, demand_ix, final_level_ix}.outputs = outputs;
                    batch_outputs{tank_area_ix, tank_height_ix, demand_ix, final_level_ix}.statistics = statistics;
                    continue;
                end
                
                [optim_n, optim_s] = linprog_to_sim_schedule(n,s);
                outputs.schedule.N = optim_n;
                outputs.schedule.S = optim_s;

                %% Run the simulator with optimized schedules
                optim_sim_output = simulator_2p1t(...
                    outputs.schedule, network, input, sim);
                    
                % Fetch tank levels from the decision variable vector x and from final simulation
                ht_milp = get_tank_levels(outputs.x, vars, 1)';
                ht_final_sim = optim_sim_output.ht(1:end-1);
                ht_rmse = rmse(ht_final_sim, ht_milp);
                ht_mae = mae(ht_final_sim, ht_milp);
                outputs.ht_rmse = ht_rmse;
                outputs.ht_mae = ht_mae;
                
                outputs.simulated_cost = sum(optim_sim_output.P .* input.tariff');
                batch_outputs{tank_area_ix, tank_height_ix, demand_ix, final_level_ix}.inputs = inputs;
                batch_outputs{tank_area_ix, tank_height_ix, demand_ix, final_level_ix}.outputs = outputs;
                batch_outputs{tank_area_ix, tank_height_ix, demand_ix, final_level_ix}.statistics = statistics;

                optim_step2_path = fullfile(local_output_folder, "optim_step2.mat");
                save(optim_step2_path, "optim_sim_output", "status", "cmdout");
                    
                %% Visualise results: 
                % 1. simulation with initial schedule
                % 2. optimizer output
                % 3. final_simulation with optimized schedule
                % optim_output -> outputs
                if make_plots == true
                    plot_scheduling_2p1t_results(init_sim_output, outputs, ...
                        optim_sim_output, input, sim, vars, local_output_folder);
                end
                        
                % Remove intermediate step .mat file `optim_step1.mat`
                %delete(optim_step1_path)
                %close all

            end
        end
    end
end
save(fullfile(outputs_folder, "batch_output.mat"), "batch_outputs");
disp("FAILED RUNS:")
disp(failed_runs)
