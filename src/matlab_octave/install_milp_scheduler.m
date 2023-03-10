function succ = install_milp_scheduler(modify, verbose)
  % Installs milp_scheduler within MATLAB/OCTAVE environment
  % Args:
  %   modify: select how to set path
  %           0 (default) - generate relevant ADDPATH() commands, but
  %               don't execute them
  %           1 - modify the path directly executing the relevant
  %               ADDPATH() commands
  %   verbose: prints the relevant ADDPATH commands if true (default),
  %            silent otherwise
  % Returns:
  %   status - SUCCESS : 1 if all commands succeeded, 0 otherwise
  %
  % Examples:
  %   install_milp_scheduler;  %% print the required ADDPATH() commands
  %   install_milp_scheduler(0,0); %% save the commands to startup.m, no text output
  %   install_milp_scheduler(1,0); %% modify PATHS, no text output
  %   install_milp_scheduler(0,1); %% save the commands to startup.m, print paths to console
  %   install_milp_scheduler(1,1); %% modify PATHS, print paths to console
  
  %% installation data for each component
  min_ver.Octave = '4.0.0';
  min_ver.MATLAB = '7.5.0';
  install = struct( ...
      'name', { ...
          'milp-scheduler', ...
          'milp-formulation', ...
          'variable-structures', ...
          'case-studies', ...
          'post-processing'}, ...
      'dirs', { ...
          {{''}, {'lib'}}, ...
          {{'milp_formulation', ''}, {'milp_formulation', 'lib'}, ...
           {'milp_formulation', 'equality_constraints'}, ...
           {'milp_formulation', 'inequality_constraints'}}, ...
          {{'variable_structures', ''}, {'variable_structures', 'lib'}},...
          {{'case_studies', 'two_pump_one_tank'}},...
          {{'post_processing', ''}}}, ...
      'fcns', { ...
          {'scheduler'}, ...
          {'set_objective_vector', 'set_intcon_vector'}, ...
          {'initialise_bin_var_structure', 'initialise_cont_var_structure'}, ...
          {'simulator_2p1t'},...
          {'plot_optim_outputs'}} ...
  );
  ni = length(install);   %% number of components
  
  %% default arguments
  interactive = 0;
  if nargin < 2
      verbose = 1;
      if nargin < 1
          modify = 1;
      end
  end

  %% get path to new installation root. Obtain root folder, file_name and extension
  [root, n, e] = fileparts(which('install_milp_scheduler'));
  %% Check whether the user uses MATLAB or Octave
  sw = get_system();

  %% Check for the required version of MATLAB or Octave
  vstr = '';
  switch sw
      case 'Octave'
          v = ver('octave');
      case 'MATLAB'
          v = ver('matlab');
          if length(v) > 1
              warning('The built-in VER command is behaving strangely, probably as a result of installing a 3rd party toolbox in a directory named ''matlab'' on your path. Check each element of the output of ver(''matlab'') to find the offending toolbox, then move the toolbox to a more appropriately named directory.');
              v = v(1);
          end
  end
  if ~isempty(v) && isfield(v, 'Version') && ~isempty(v.Version)
      vstr = v.Version;
      if vstr2num(vstr) < vstr2num(min_ver.(sw))
          error('\n\n%s\n  MILP-SCHEDULER requires %s %s or later.\n      You are using %s %s.\n%s\n\n', repmat('!',1,45), sw, min_ver.(sw), sw, vstr, repmat('!',1,45));
      end
  else
      warning('\n\n%s\n  Unable to determine your %s version. This indicates\n  a likely problem with your %s installation.\n%s\n', repmat('!',1,60), sw, sw, repmat('!',1,60));
  end
  
  %% find available new components
  available = zeros(ni, 1);
  for i = 1:ni
      if exist(fullfile(root, install(i).dirs{1}{:}), 'dir')
          available(i) = 1;
      end
  end
  
  %% Generate paths to add
  newpaths = {};
  for i = 1:ni
      if available(i)     %% only available components
          for k = 1:length(install(i).dirs)
              p = fullfile(root, install(i).dirs{k}{:});
              if ~isempty(p) && ~ismember(p, newpaths)
                  newpaths{end+1} = p;
              end
          end
      end
  end
  
  %% Build addpath string
  cmd = sprintf('addpath( ...\n');
  for k = 1:length(newpaths)
      cmd = sprintf('%s    ''%s'', ...\n', cmd, newpaths{k});
  end
  cmd = sprintf('%s    ''%s'' );\n', cmd, '-end');
  
  div_line = sprintf('\n-------------------------------------------------------------------\n\n');
  %% print addpath
  if verbose
      fprintf(div_line);
      if modify
          fprintf('Your %s path will be updated using the following command:\n\n%s', sw, cmd);
          if interactive
              s = input(sprintf('\nHit any key to continue ...'), 's');
          end
      else
          fprintf('Use the following command to add MILP-SCHEDULER to your %s path:\n\n%s\n', sw, cmd);
      end
  end
  
  %% add the new paths
  if modify
      addpath(newpaths{:}, '-end');
      if verbose
          fprintf('Your %s path has been updated.\n', sw);
      end
  end
  
  %% Modify the path if modify flag is set to True
  if modify                   %% modify the path directly
      savepath;                   %% save the updated path
      if verbose
          fprintf(div_line);
          fprintf('Your updated %s path has been saved using SAVEPATH.\n', sw);
      end
  end
  
  if verbose
      fprintf(div_line);
      if modify
          fprintf('Now that you have added the required directories to your %s path\n', sw);
          fprintf('MILP-SCHEDULER is installed and ready to use.\n\n');
      else
          fprintf('Once you have added the required directories to your %s path\n', sw);
          fprintf('MILP-SCHEDULER will be installed and ready to use.\n\n');
      end
  end

  if nargout
    succ = success;
  end
  
end

function num = vstr2num(vstr)
  % Converts version string to numerical value suitable for < or > comparisons
  % E.g. '3.11.4' -->  3.011004
  pat = '\.?(\d+)';
  [s,e,tE,m,t] = regexp(vstr, pat);
  b = 1;
  num = 0;
  for k = 1:length(t)
      num = num + b * str2num(t{k}{1});
      b = b / 1000;
  end
end
