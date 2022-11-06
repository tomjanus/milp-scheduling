function y = Plot_results(q,hc,P,ht,N,S)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
global R1 R2 R3 R4 A B C At nc nf e Lc Lf hr et x_min x_max gp hp d  T time

time_1=[0 time];

% ELEMENT FLOWA
figure;
q3=[q(3,:) q(3,24)];
stairs(time_1,q3,'LineWidth',2);
hold;
q4=[q(4,:) q(4,24)];
stairs(time_1,q4,'LineWidth',2);
q5=[q(5,:) q(5,24)];
stairs(time_1,q5,'LineWidth',2);

xticks(0:1:24);
xtickangle(90);
ylabel('Flows in elements [l/s]');
title('FLOW in ELEMENTS [l/s]');
legend('q4','q5','q6');
grid;
hold  off;


% HEAD AT NODES
figure;
hc1=[hc(1,:) hc(1,24)];
stairs(time_1,hc1,'LineWidth',2);
hold;
hc2=[hc(2,:) hc(2,24)];
stairs(time_1,hc2,'LineWidth',2);
hc3=[hc(3,:) hc(3,24)];
stairs(time_1,hc3,'LineWidth',2);
hc4=[hc(4,:) hc(4,24)];
stairs(time_1,hc4,'LineWidth',2);

plot(time_1,ht,'k-*');
xticks(0:1:24);
xtickangle(90);
ylabel('Head at nodes [m]');
title('HEAD at NODES');
legend('h2','h3','h4','h6');
grid;
hold off;

% ENERGY CONSUMPTION
figure;
P1=[P; P(24)];
stairs(time_1,P1,'LineWidth',2);
hold;
T1=[T T(24)];
stairs(time_1,100*T1,'LineWidth',2);
xticks(0:1:24);
xtickangle(90);
ylabel('Energy cost [£/kWh]');
title('ENERGY COST [£/kWh]');
legend('energy cost','tariff');
grid;
hold off;

% PUMP SCHEDULES
figure;
N1=[N N(24)];
stairs(time_1,N1,'LineWidth',2);
hold;
S1=[S S(24)];
stairs(time_1,S1,'LineWidth',2);
xticks(0:1:24);
xtickangle(90);
ylabel('PUMP ON/OFF and SPEED');
title('PUMP OPERATION');
legend('PUMP ON/FF','PUMP SPEED');
grid;
hold off;

end
