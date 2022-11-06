ss=0.7:0.05:1.2;
qq=0:10:100;

PP=zeros(11);
for i=1:11
for j=1:11
    PP(i,j)=gp*qq(j)*ss(i)^2+hp*ss(i)^3;
end
end
% surface plot
 figure;
surf(qq,ss,PP);
grid;

% function of speed
figure;
plot(ss,PP(:,6));
grid;

% function of flow
figure;
plot(qq,PP(6,:));
grid;

