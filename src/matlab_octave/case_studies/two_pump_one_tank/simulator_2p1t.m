function output = simulator_2p1t(schedule, network, input, sim)
  % Simulate a simple two-pumps one-tank network
  % Args:
  % schedule (struct): pump control schedule N: (0/1), pump speed schedule, (0-1)
  % network (struct): network parameters
  % input (struct): input data
  % sim: (struct): simulation parameters
  
  % Returns:
  % output struct with the following fields:
  % q: vector of flows in each pipe for time steps 1 to time horizon, L/S
  % hc: vector of calculated heads for time steps 1 to time horizon, m
  % P: vector of power consumption for time steps 1 to time horizon, ??
  % ht: vector of tank heads for time steps 1 to time horizon, m
  % h: vector of all nodal haeds for time step 1 to time horizon, m

  if nargin == 7
    time_step = 1; % Add default time step of 1hr if time step not provided
  else
    time_step = sim.delta_t;
  end
  
  tank = network.tanks(1);
  pump = network.pump_groups(1).pump;

  ht(1)=tank.ht0;
  htt=ht(1);
  %   q1 q2 q3 q4 q5  h2  h3  h4  h5
  x0=[0  0  0  30 -30 210 210 232 232];
  P=zeros(sim.TIME_HORIZON,1); % Initialize the power consumption vector

  % Run extended period simulation for the period of K steps
  for k=1:sim.TIME_HORIZON
    n=schedule.N(k); % Get number of working pumps at time step k
    s=schedule.S(k); % Get pump speed at time step k
    dk=input.df*input.demands(:,k); % Get scaled demand at time step k
    % Solve the network equations for time-step k
    x=fsolve(@(x)hydraulics_2p1t(x, n, s, dk, htt, input, network, pump), x0);
    % Retrieve vector of pipe flows from solution x
    q(:,k)=x(1:network.ne);
    % Retrieve vector of calculated heads from solution x
    hc(:,k)=x(network.ne+1 : network.ne+network.nc);
    % Get pump consumption from the pump group flow and speed and number of
    % operating pumps at time step k
    P(k) = pump_power_consumption(pump, q(network.pump_group_indices(1),k), ...
                                  s, n) * input.tariff(k);
    % Advance state in time
    % Calculate water of volume passing through the tank feed pipe
    dV = q(4,k)*time_step;
    ht(k+1)=ht(k)+vol_to_h_constant_area(tank.area, dV);
    % Update the h vector
    h(:,k)=[hc(:,k);input.hr;ht(k)];
    % Tank water head for the next iteration is the projected tank water head
    htt=ht(k+1);
  end
  output.q = q;
  output.h = h;
  output.P = P;
  output.hc = hc;
  output.ht = ht;

end
