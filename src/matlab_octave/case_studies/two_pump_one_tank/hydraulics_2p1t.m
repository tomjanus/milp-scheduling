function y = hydraulics_2p1t(x,n,s,d,htt, input, network, pump)
  % Hydraulic function for the simple two-pump one-tank network
  % 
  % Args:
  % x - vector representing flows in the elements (5 vars) and heads at
  %     connection nodes (4 vars) at time step k. 
  % n - number of working pumps at time step k
  % s - pump speed s_min <= s <= s_max at time step k
  % d - nodal demands at time step k
  % htt - tank head at the nex time step
  % input - input structure
  % network - network structure
  % pump - pump structure
  % 
  % Returns:
  % y - the vector of mass balance equations at the connection nodes (4 eqs)
  %     and equations of components (5 eqs). 
  %
  qh=x(1:network.ne);
  hch=x(network.ne+1:network.ne+network.nc);
  hf(1)=input.hr;
  hf(2)=htt;
  y=zeros(network.ne+network.nc,1);
  %
  y(1:network.nc)=network.Lc*qh.';
  y(network.nc)=y(network.nc)-d(4);
  % Heads in pipes
  dH = zeros(network.ne,1)';
  for i = 1:length(network.pipe_indices)
    pipe_index = network.pipe_indices(i);
    dH(pipe_index) = network.Rs(i)*qh(pipe_index)*abs(qh(pipe_index));
  end
  % Heads in pumps
  for i = 1:length(network.pump_group_indices)
    pump_index = network.pump_group_indices(i);
    dH(pump_index) = pump_head(pump, qh(pump_index), n, s);
  end
  %
  y(network.nc+1:network.nc+network.ne)=...
    dH.'+ network.Lc.'*hch.'+ network.Lf.'*hf.';
  y(network.nc+2)=y(network.nc+2)-n^2*(hch(2)-hch(1))-(hch(2)-hch(1));
  %
end

