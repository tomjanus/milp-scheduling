function [q,hc,P,ht,h] = Simulator(ht0,K,schedule,network,input,pump)
  % Simulate a simple two-pumps one-tank network
  % Args:
  % ht0 - initial tank height, m
  % K - schedule time horizon, default == 24 (hours)
  % schedule (struct): pump control schedule N: (0/1), pump speed schedule, (0-1)
  % network (struct): network parameters
  % input (struct): input data
  % pump (struct): pump data
  % Returns
  % q: vector of flows in each pipe for time steps 1 to time horizon, L/S
  % hc: vector of calculated heads for time steps 1 to time horizon, m
  % P: vector of power consumption for time steps 1 to time horizon, ??
  % ht: vector of tank heads for time steps 1 to time horizon, m
  % h: vector of all nodal haeds for time step 1 to time horizon, m
  
  ht(1)=ht0;
  htt=ht(1);
  %   q1 q2 q3 q4 q5  h2  h3  h4  h5
  x0=[0  0  0  30 -30 210 210 232 232];
  P=zeros(K,1); % Initialize the power consumption vector
  
  % Run extended period simulation for the period of K steps
  for k=1:K
    n=schedule.N(k); % Get number of working pumps at time step k
    s=schedule.S(k); % Get pump speed at time step k
    dk=input.df*input.demand(k); % Get scaled demand at time step k
    % Solve the network equations for time-step k
    x=fsolve(@(x)Hydraulics(x, n, s, dk, input.hr, htt, network, pump), x0);
    % Retrieve vector of pipe flows from solution x
    q(:,k)=x(1:network.ne);
    % Retrieve vector of calculated heads from solution x
    hc(:,k)=x(network.ne+1 : network.ne+network.nc); 
    
    % TODO: SHALL WE UPDATE THIS EQUATION TO CONSIDER ALL OTHER COEFFICIENTS?
    P(k)=(pump.gp*q(network.pump_pipe_index,k)*s^2 + ...
          pump.hp*n*s^3)*input.tariff(k);
    % Advance state in time
    ht(k+1)=ht(k)+(1/network.At)*q(network.tank_feed_pipe_index,k);
    h(:,k)=[hc(:,k);input.hr;ht(k)];
    htt=ht(k+1);
  end
  %
end
    


