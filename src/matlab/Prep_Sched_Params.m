
global R1 R2 R3 R4 A B C At nc nf e Lc Lf hr et x_min x_max gp hp d  T time

%% TANK
% ht0(k) - initial tank trajectory from the diqpipe0mulator
% ht_min(24) -Lower bounds on the level
% ht_mak(24) - Upper bounds on the tank level

%% POWER
% P0(j,k) -  initial conditiond, power from Simulator j=1,2; k=1:24
% gp_s(j)   coefficient in power equation
% hp_s(j)  - coefficient in power equation

% n0(j,k) - pump ON/OFF schedule from the si,ulator
% s0(j,k)  - pump speed from simulator
% qpump0(j,k)   - pump flow from simulator
% ss0(2,4,24) - initial pump domain speed
% qq0(2,4,24) - initial pump domain flow
% AA0(2,4,24) - initial pump domain selection variable

% qitcp(j)   - intercept flow for a pump
% M_pump(j,i)  line i slope for line defining domain
% C_pump(j,1)   - constant in line defining domain
% dd(j,i)    coefficien of the plane over i-th domain
% ee(j,i)   - coefficien of the plane over i-th domain
 % ff(j,i)   -  coefficien of the plane over i-th domain
 
 % PIPES
 % dh0 - head drop on all elements from Simulator
 % xp(j,i) - segment breakpoints for pipe characteristics i=1,2,3,4
% M_pipe(j,i) - slope of a pipe characteristic segmant j=1,2; i=1,2,3,4
% C_pipe(j,i)  - cons tant of a pipe characteristic segmant j=1,2; i=1,2,3
% qpipe0(j,k) - pipe flow from simulator, j=1,2,3,4; k-1:24
% q0(j,k) - flow in all components from Simulator j=1:6; k=1:2
% ww0(4,3,24) - initial flow in pipe segments
% BB0(4,3,240 - intial segment selection  in pipes

 global R1 R2 R3 R4 A B C At nc nf e Lc Lf hr et x_min x_max gp hp d  T time

 Lambda=[Lc;Lf];
 dh0=Lambda'*h;
 
ww0=zeros(4,3,24);
BB0=zeros(4,3,24);
ss0=zeros(2,4,24);
qq0=zeros(2,4,24);
AA0=zeros(2,4,24);

%% DEFINITION OF POINTERS
pipe_index=[1;3;4;5]; % Pie flow index for the simulator results
pump_index=[2;3];
hc_index=[1;2;3;4]; % Row number in the Lambda matrix
hr_index=[5]; % Row number in the Lambda matrix
ht_index=[6];  % Row number in the Lambda matrix


%% PUMP DATA
  P0=zeros(2,24);
qitcp=zeros(2,1);

for j=1:2
    smin(j)=0.7;
    smax(j)=1.2;
    detq=B^2-4*A*C;
    qitcp(j)=(-B-sqrt(detq))/(2*A);
    gp_s(j)=gp;
    hp_s(j)=hp;
    p_nominal(j,1)=1;
    p_nominal(j,2)=qitcp(j)/2;
    p_nominal(j,3)=A*p_nominal(j,2)^2+B*p_nominal(j,2)+C;
    dh_null(j,1)=C*smin(j)^2;
    dh_null(j,2)=C*smax(j)^2;
    dh_itcp(j,1)=A*qitcp(j)^2+B*qitcp(j)*smin(j)+C*smin(j)^2;
    dh_itcp(j,2)=A*qitcp(j)^2+B*qitcp(j)*smax(j)+C*smax(j)^2;
end



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
    for k=1:24
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
 for k=1:24
     ht0(k)=ht(k+1);
     ht_min(k)=231;
     ht_max(k)=235;
 end;
 
 
%% Initial conditions for power consumption, ON/OFF, speed, flow for pumps
    for k=1:24
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
        for k=1:24
        q0(pointer,k)=qpump0(j,k);
        end
    end
    
    for j=1:4
        pointer=pipe_index(j);
        for k=1:24
         q0(pointer,k)=qpipe0(j,k);
        end
    end
    
    %% AUXILIRY VARIABLES FOR PICE-LINEAR PIPE CHARACTERISTICS
    for j=1:4
        for i=1:3
          for k=1:24
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
       for  k=1:24
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
   
       
            
            
               
            
            
    
    
        
    
    

        
            

        
        
            
        
        




