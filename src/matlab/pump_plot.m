ss=0.7:0.05:1.2;
qq=0:10:100;

ddh=zeros(11);

for i=1:11
for j=1:11
    ddh(i,j)=A*qq(i)^2+B*qq(i)*ss(j)+C*ss(j);
end
end

% 2D surface
figure;
surf(ss,qq,ddh);
grid;

% fi=unction of flow
figure;
plot(qq,ddh(:,6));
grid;

% function of speed
figure;
plot(ss,ddh(6,:));
grid;

