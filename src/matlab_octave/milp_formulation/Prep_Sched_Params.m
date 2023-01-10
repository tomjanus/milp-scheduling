%% TANK
% ht0(k) - initial tank trajectory from the diqpipe0mulator
% ht_min(24) -Lower bounds on the level
% ht_mak(24) - Upper bounds on the tank level

%% POWER
% P0(j,k) -  initial conditiond, power from Simulator j=1,2; k=1:24
% ep_s(j) - coefficient in power equation - new
% fp_s(j) - coefficient in power equation - new
% gp_s(j)   coefficient in power equation
% hp_s(j)  - coefficient in power equation

% n0(j,k) - pump ON/OFF schedule from the simulator
% s0(j,k)  - pump speed from simulator
% qpump0(j,k)   - pump flow from simulator


% qitcp(j)   - intercept flow for a pump
% M_pump(j,i)  line i slope for line defining domain
% C_pump(j,1)   - constant in line defining domain
% dd(j,i)    coefficient of the plane over i-th domain
% ee(j,i)   - coefficient of the plane over i-th domain
 % ff(j,i)   -  coefficien of the plane over i-th domain
 
 % PIPES
 % dh0 - head drop on all elements from Simulator
 % xp(j,i) - segment breakpoints for pipe characteristics i=1,2,3,4
% M_pipe(j,i) - slope of a pipe characteristic segmant j=1,2; i=1,2,3,4
% C_pipe(j,i)  - cons tant of a pipe characteristic segmant j=1,2; i=1,2,3
% qpipe0(j,k) - pipe flow from simulator, j=1,2,3,4; k-1:24
% q0(j,k) - flow in all components from Simulator j=1:6; k=1:2


 global At nc nf e Lc Lf hr et x_min x_max gp hp d  T time

function y = create_pipe_linprog_vars(network)
  % Create variables that describe pipes in a linprog model structure and
  % initialize those variables from the results obtained from the original
  % network model
  % Args:
  %
  % Returns:
  % 
  % ww0 - initial flowS in pipe segments
  % BB0 - intial segment selectionS  in pipes
  ww0=zeros(network.npipes, NO_PIPE_SEGMENTS, TIME_HORIZON);
  BB0=zeros(network.npipes, NO_PIPE_SEGMENTS, TIME_HORIZON);
end

function y = create_pump_linprog_vars(network, pump)
  %
  
  % ss0 - initial pump domain speed
  % qq0 - initial pump domain flow
  % AA0 - initial pump domain selection variable
  ss0=zeros(network.np, NO_PUMP_SEGMENTS, TIME_HORIZON);
  qq0=zeros(network.np, NO_PUMP_SEGMENTS, TIME_HORIZON);
  AA0=zeros(network.np, NO_PUMP_SEGMENTS, TIME_HORIZON);
end

function y = create_tank_linprog_vars()
  %
end

function y = create_power_linprog_vars(network)
  %
  P0=zeros(network.np, TIME_HORIZON);
  qitcp=zeros(network.np, 1);

  % Iterate through pumps
  for j=1:network.np
    smin(j)=pump.smin;
    smax(j)=pump.smax;
    
    detq=pump.B^2-4*pump.A*pump.C;
    qitcp(j)=(-pump.B-sqrt(detq))/(2*pump.A);
    gp_s(j)=gp;
    hp_s(j)=hp;
    %% Co-ordinates of points fo approximation of the pump hydraulic characteristic
    p_nominal(j,1)=1;
    p_nominal(j,2)=qitcp(j)/2;
    p_nominal(j,3)=pump.A*p_nominal(j,2)^2+pump.B*p_nominal(j,2)+pump.C;
    dh_null(j,1)=pump.C*smin(j)^2;
    dh_null(j,2)=pump.C*smax(j)^2;
    dh_itcp(j,1)=pump.A*qitcp(j)^2+pump.B*qitcp(j)*smin(j)+pump.C*smin(j)^2;
    dh_itcp(j,2)=pump.A*qitcp(j)^2+pump.B*qitcp(j)*smax(j)+pump.C*smax(j)^2;
  end

end


 Lambda=[Lc;Lf];
 dh0=Lambda'*h;



U_power=1000;
U_pump=100;

%% Preparing coefficients dd, ee, ff
dd=zeros(2,4);
ee=zeros(2,4);
ff=zeros(2,4);
pump_points=zeros(2,5,3);

for j=1:2
    pump_points(j,1,:)=p_nominal(j,:);
    pump_points(j,2,:)=[smin(j);0;dh_null(j,1)];
    pump_points(j,3,:)=[smax(j);0;dh_null(j,2)];
    pump_points(j,4,:)=[smax(j);qitcp(j);dh_itcp(j,2)];
    pump_points(j,5,:)=[smin(j);qitcp(j);dh_itcp(j,1)];
end

%% POINTERS WHICH POINTS DEFINE WHICH DOMAIN
    dom_pointers(1,:)=[1; 2; 3];
    dom_pointers(2,:)=[1; 3; 4];
    dom_pointers(3,:)=[1; 4; 5];
    dom_pointers(4,:)=[1; 5; 2];
    
 %% COEFFICIENTS OF THE LINE DEFINING THE PUMP DOMAINS
 M_pump=zeros(2,4);
 C_pump=zeros(2,4);
  
 for j=1:2
     for i=1:4
     detE=(pump_points(j,i+1,1)-pump_points(j,1,1));
     M_pump(j,i)=(pump_points(j,i+1,2)-pump_points(j,1,2))/detE;
     C_pump(j,i)=(pump_points(j,1,2)*pump_points(j,i+1,1)-pump_points(j,i+1,2)*...
         pump_points(j,1,1))/detE;
 end
 end
          
     
%% COEFFICIENYS OF THE PLANE EQUATIONS OVER PUMP DOMAINS
E=zeros(3);
E1=zeros(3);
E2=zeros(3);
E3=zeros(3);

for j=1:2
    for i=1:4
        point=dom_pointers(i,1);
        E3(1,:)=pump_points(j,point,:);
        point=dom_pointers(i,2);
        E3(2,:)=pump_points(j,point,:);
        point=dom_pointers(i,3);
        E3(3,:)=pump_points(j,point,:);
        
        E=E3;
        E(:,3)=[1;1;1];
        
        E1=E;
        E1(:,1)=E3(:,3);
        
        E2=E;
        E2(:,2)=E3(:,3);
        
        % CRAMER SOLUTIONS
        detE=det(E);
        dd(j,i)=det(E1)/detE;
        ee(j,i)=det(E2)/detE;
        ff(j,i)=det(E3)/detE;
        
    end
    
end
%% END OF COEFFICIENYS OF THE PLANE EQUATIONS OVER PUMP DOMAINS

%% Preparing pipe dara

for j=1:4
    pointer=pipe_index(j);
    p_flow=q(pointer,12);
    if p_flow>=0
        xp(j,1)=-1.5*p_flow;
        xp(j,2)=-p_flow;
        xp(j,3)=p_flow;
        xp(j,4)=1.5*p_flow;
    elseif p_flow<0
        xp(j,1)=1.5*p_flow;
        xp(j,2)=p_flow;
        xp(j,3)=-p_flow;
        xp(j,4)=-1.5*p_flow;
    end
end

%% PREPARING M_pipe and C_pipe coefficienys

for j=1:4
     pointer=pipe_index(j);
    for k=1:TIME_HORIZON
     qpipe0(j,k)=q(pointer,k);
     end
end

for j=1:4
     for i=1:3
       xim1=xp(j,i);
       xi=xp(j,i+1);
       yim1=R_pipe(j)*xim1*abs(xim1);
       yi=R_pipe(j)*xi*abs(xi);
       M_pipe(j,i)=(yi-yim1)/(xi-xim1);
       C_pipe(j,i)=(yim1*xi-yi*xim1)/(xi-xim1);
    end
end

       
       


%% INITIAL VALUES

%% INITIAL POWER VALUS


%% TANK INITIAL STATE trajectory and bounds on the level
 for k=1:TIME_HORIZON
     ht0(k)=ht(k+1);
     ht_min(k)=231;
     ht_max(k)=235;
 end;
 
 
%% Initial conditions for power consumption, ON/OFF, speed, flow for pumps
    for k=1:TIME_HORIZON
        if N0(k)==2
        n0(1,k)=1;
        n0(2,k)=1;
        s0(1,k)=S0(k);
        s0(2,k)=S0(k);
        qpump0(1,k)=q(2,k)/2;
        qpump0(2,k)=q(2,k)/2;
        P0(:,k)=[P(k)/2;P(k)/2];
        
        elseif N0(k)==1
        n0(1,k)=1;
        n0(2,k)=0;
        s0(1,k)=S0(k);
        s0(2,k)=0;
        qpump0(1,k)=q(2,k);
        qpump0(2,k)=0;
        P0(:,k)=[P(k);0];
        else
        n0(1,k)=0;
        n0(2,k)=0;
        s0(1,k)=0;
        s0(2,k)=0;
        qpump0(1,k)=0;
        qpump0(2,k)=0;
         P0(:,k)=[0;0];
        end
    end
    
    %% INITIAL HEAD AT CONNECTION NODES
        hc0=hc;
        
    %% INITIAL FLOW IN ALL ELEMENTS
    
            
    for j=1:2
        pointer=pump_index(j);
        for k=1:TIME_HORIZON
        q0(pointer,k)=qpump0(j,k);
        end
    end
    
    for j=1:4
        pointer=pipe_index(j);
        for k=1:TIME_HORIZON
         q0(pointer,k)=qpipe0(j,k);
        end
    end
    
    %% AUXILIRY VARIABLES FOR PICE-LINEAR PIPE CHARACTERISTICS
    for j=1:4
       
          for k=1:TIME_HORIZON for i=1:3
            if (xp(j,i)<=qpipe0(j,k))& (qpipe0(j,k)<xp(j,i+1))
                ww0(j,i,k)=qpipe0(j,k);
                BB0(j,i,k)=1;
            else
                 ww0(j,i,k)=0;
                 BB0(j,i,k)=0;
            end
          end
        end
    end
    
    
    %% AUXILIRY VARIABLES FOR PICE-LINEAR PUMP CHARACTERISTICS
    
   for j=1:2
       for  k=1:TIME_HORIZON
    % Domain A1
        if (qpump0(j,k)<=M_pump(j,1)&s0(j,k)+C_pump(j,1))&...
                (qpump0(j,k)<=M_pump(j,2)&s0(j,k)+C_pump(j,2))
            qq0(j,1,k)=qpump0(j,k);
            ss0(j,1,k)=s0(j,k);
            AA0(j,1,k)=1;
        end
    % Nomain A2
        if (-qpump0(j,k)<=-M_pump(j,2)*s0(j,k)-C_pump(j,2))&...
                (qpump0(j,k)<=M_pump(j,3)*s0(j,k)+C_pump(j,3))
           qq0(j,2,k)=qpump0(j,k);
            ss0(j,2,k)=s0(j,k);
            AA0(j,2,k)=1;
        end
    % Nomain A3 
        if (-qpump0(j,k)<=-M_pump(j,3)*s0(j,k)-C_pump(j,3))&...
                (-qpump0(j,k)<=-M_pump(j,4)*s0(j,k)-C_pump(j,4))
           qq0(j,3,k)=qpump0(j,k);
            ss0(j,3,k)=s0(j,k);
            AA0(j,3,k)=1;
        end
    % Domain 4
        if  (qpump0(j,k)<=M_pump(j,4)*s0(j,k)+C_pump(j,4))&...
                (-qpump0(j,k)<=-M_pump(j,1)*s0(j,k)-C_pump(j,1))
             qq0(j,4,k)=qpump0(j,k);
            ss0(j,4,k)=s0(j,k);
            AA0(j,4,k)=1;
        end
       end
   end
   
       
            
            
               
            
            
    
    
        
    
    

        
            

        
        
            
        
        




