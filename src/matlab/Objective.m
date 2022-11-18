function ff = Objective(nv,K)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

for k=1:K
  for j=1:nv-2
      ff(j+(k-1)*nv)=0;
  end;
  ff(nv-1+(k-1)*nv)=1;
  ff(nv+(k-1)*nv)=1;
  end
end

