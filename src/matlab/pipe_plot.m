qq=-50:5:50;
dh=R2*qq.*abs(qq);
plot(qq,dh);
grid;
xlabel('flow [l/s]');
ylabel('head loss [m]');
xticks(-50:5:50);

