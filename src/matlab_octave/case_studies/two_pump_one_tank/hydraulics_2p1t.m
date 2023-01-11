function y = hydraulics_2p1t(x,n,s,d,hr,htt, network, pump)
  % Hydraulic function for the simple two-pump one-tank network
  % 
  % Args:
  % x - vector representing flows in the elements (5 vars) and heads at
  %     connection nodes (4 vars) at time step k. 
  % n - number of working pumps at time step k
  % s - pump speed s_min <= s <= s_max at time step k
  % d - demand at time step k
  % hr - reservoir head at time step k
  % htt - tank head at the nex time step
  % network - network structure
  % pump - pump structure
  % 
  % Returns:
  % y - the vector of mass balance equations at the connection nodes (4 eqs)
  %     and equations of components (5 eqs). 
  %
  qh=x(1:network.ne);
  hch=x(network.ne+1:network.ne+network.nc);
  hf(1)=hr;
  hf(2)=htt;
  y=zeros(network.ne+network.nc,1);
  %
  y(1:network.nc)=network.Lc*qh.';
  y(network.nc)=y(network.nc)-d;
  %
  dH(1)=network.R(1)*qh(1)*abs(qh(1));
  dH(2)=pump_head(pump, qh(2), n, s);
  dH(3)=network.R(2)*qh(3)*abs(qh(3));
  dH(4)=network.R(3)*qh(4)*abs(qh(4));
  dH(5)=network.R(4)*qh(5)*abs(qh(5));
  %
  y(network.nc+1:network.nc+network.ne)=...
    dH.'+ network.Lc.'*hch.'+ network.Lf.'*hf.';
  y(network.nc+2)=y(network.nc+2)-n^2*(hch(2)-hch(1))-(hch(2)-hch(1));
  %
end

