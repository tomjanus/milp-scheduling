 % mappping decision variables
 
 %% Reset all variables to zero
 f=zeros(1560,1);
 ht1=zeros(24,2);
  PP=zeros(2,24,2);
  NN=zeros(2,24,2);
  s1=zeros(2,24,2);
  q1=zeros(6,24,2);
  hc1=zeros(4,24,2);
  ww=zeros(4,3,24,2);
  BB=zeros(4,3,24,2);
  ss=zeros(2,4,24,2);
  qq=zeros(2,4,24,2);
  AA=zeros(2,4,24,2);
  
  %% BONDS ON THE DECISION VARIABLES
  for k=1:24
      ht_min(k)=231;
      ht_max(k)=235;
  end
  PP_min=0;
  PP_max=10;
  n_min=0;
  n_max=1;
 
  qpump_min=0;
  qpump_max=70;
  qpipe_min=-70;
  qpipe_max=70;
  hc_min=205;
  hc_max=240;
  
  for j=1:2
      for i=1:4
          ss_min(j,i)=smin(j);
          ss_max(j,i)=smax(j);
          qq_min(j,i)=0;
          qq_max(j,i)=qitcp(j);
      end
      ss_min(j,2)=p_nominal(j,1);
      ss_max(j,4)=p_nominal(j,1);
      qq_min(j,3)=p_nominal(j,2);
      qq_max(j,1)=p_nominal(j,2);
  end
  
    
%% OBJECTIVE FUNCTION DATA
dt=1;
 x_pos=1;
 int_pos=1;
 
 
 %% TIME LOOP - MAPPING STARTS HERE
 for k=1:24
    
%%  Group 1 - tank level
 ht1(k,2)=x_pos;
 ht1(k,1)=ht0(k);
 x(x_pos)=ht1(k,1);
 lb(x_pos)=ht_min(k);
 ub(x_pos)=ht_max(k);
 x_pos=x_pos+1;
 
%% Group 2 - Power consumption
 for j=1:2
  PP(j,k,2)=x_pos+j-1;
  PP(j,k,1)=P0(j,k);
  x(x_pos+j-1)=PP(j,k,1);
  lb(x_pos+j-1)=PP_min;
  ub(x_pos+j-1)=PP_max;
  f(x_pos+j-1)=T(k)*dt;
 end
 x_pos=x_pos+2;
   
%% Group 3 - pump operation ON/OFF
  for j=1:2
  NN(j,k,2)=x_pos+j-1;
  NN(j,k,1)=n0(j,k);
  x(x_pos+j-1)=NN(j,k,1);
  lb(x_pos+j-1)=0;
  ub(x_pos+j-1)=1;
  intcon(int_pos+j-1)=x_pos+j-1;
 end
  x_pos=x_pos+2;
  int_pos=int_pos+2;
  
%% Group 4 - Pump speed
  for j=1:2
  s1(j,k,2)=x_pos+j-1;
  s1(j,k,1)=s0(j,k);
  x(x_pos+j-1)=s1(j,k,1);
  lb(x_pos+j-1)=0;
  ub(x_pos+j-1)=smax(j);
 end 
  x_pos=x_pos+2;
  
%% Group 5 an 6 together - flow in all elements 
 for j=1:6
      q1(j,k,2)=x_pos+j-1;
      q1(j,k,1)=q0(j,k);
      x(x_pos+j-1)=q1(j,k,1);
      if j==2 | j==3
          lb(x_pos+j-1)=qpump_min;
          ub(x_pos+j-1)=qpump_max;
      else
          lb(x_pos+j-1)=qpipe_min;
          ub(x_pos+j-1)=qpipe_max;
      end
 end
 x_pos=x_pos+6;
 
%% Group 7 - head at connection nodes
  for j=1:4
      hc1(j,k,2)=x_pos+j-1;
      hc1(j,k,1)=hc0(j,k);
      x(x_pos+j-1)=hc1(j,k,1);
      lb(x_pos+j-1)=hc_min;
      ub(x_pos+j-1)=hc_max;
 end
 x_pos=x_pos+4;
      
%% Group 8 - flow in pipe segments
for j=1:4
    for i=1:3
        ww(j,i,k,2)=x_pos+(j-1)*3+i-1;
        ww(j,i,k,1)=ww0(j,i,k);
        x(ww(j,i,k,2))=ww(j,i,k,1);
        lb(ww(j,i,k,2))=qpipe_min;;
        ub(ww(j,i,k,2))=qpipe_max;;
    end
end
x_pos=x_pos+12;

%% Group 9 - pipe segment selection
for j=1:4
    for i=1:3
        BB(j,i,k,2)=x_pos+(j-1)*3+i-1;
        BB(j,i,k,1)=BB0(j,i,k);
        x(BB(j,i,k,2))=BB(j,i,k,1);
        lb(BB(j,i,k,2))=0;
        ub(BB(j,i,k,2))=1;
        intcon(int_pos+(j-1)*3+i-1)=BB(j,i,k,2);
    end
end
x_pos=x_pos+12;
int_pos=int_pos+12;


%% Group 10 - speed in pump domains
for j=1:2
    for i=1:4
        ss(j,i,k,2)=x_pos+(j-1)*4+i-1;
        ss(j,i,k,1)=ss0(j,i,k);
        x(ss(j,i,k,2))=ss(j,i,k,1);
        lb(ss(j,i,k,2))=0;
        ub(ss(j,i,k,2))=smax(j);
      end
end
x_pos=x_pos+8;


%% Group 11 - flow in pump domains
for j=1:2
    for i=1:4
        qq(j,i,k,2)=x_pos+(j-1)*4+i-1;
        qq(j,i,k,1)=qq0(j,i,k);
        x(qq(j,i,k,2))=qq(j,i,k,1);
        lb(qq(j,i,k,2))=0;
        ub(qq(j,i,k,2))=qitcp(j);
    end
end
x_pos=x_pos+8;
 
%% Group 12 - pump domain selection
for j=1:2
    for i=1:4
        AA(j,i,k,2)=x_pos++(j-1)*4+i-1;
        AA(j,i,k,1)=AA0(j,i,k);
        x(AA(j,i,k,2))=AA(j,i,k,1);
        lb(AA(j,i,k,2))=0;
        ub(AA(j,i,k,2))=1;
        intcon(int_pos++(j-1)*4+i-1)=AA(j,i,k,2);
    end
end
x_pos=x_pos+8;
int_pos=int_pos+8;

 end
 
 

 x_sparse=sparse(x);
 f_sparse=sparse(f);

 
 



    
 
 