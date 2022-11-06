ind_row=1;
A1=zeros(2016,1560);
b1=zeros(2016,1);

%% MAIN TIME LOOP

for k=1:24
    
            
    %% Group 1 - pumps which contribute to power
    for j=1:2
        ind_col=PP(j,k,2);
        A1(ind_row,ind_col)=-1;
        b1(ind_row)=0;
        ind_row=ind_row+1;
        A1(ind_row,ind_col)=1;
        ind_col=NN(j,k,2);
         A1(ind_row,ind_col)=-U_power;
         b1(ind_row)=0;
         ind_row=ind_row+1;
    end
    
    %% Group 2 - Power consumption equaton
    for j=1:2
        ind_col=q1(j,k,2);
        A1(ind_row,ind_col)=gp_s(j)*s0(j,k)^2;
        ind_col=s1(j,k,2);
         A1(ind_row,ind_col)=2*gp_s(j)*qpump0(j,k)*s0(j,k)+3*hp_s(j)*s0(j,k)^2;
        ind_col=PP(j,k,2);
        A1(ind_row,ind_col)=-1;
        ind_col=NN(j,k,2);
        A1(ind_row,ind_col)=U_power;
        b1(ind_row)=gp_s(j)*s0(j,k)^2*qpump0(j,k)+2*gp_s(j)*qpump0(j,k)*s0(j,k)^2+3*hp_s(j)*s0(j,k)^3+U_power;
        ind_row=ind_row+1;
        
     %% Group 3 - the same with the opposite sign
        ind_col=q1(j,k,2);
        A1(ind_row,ind_col)=-gp_s(j)*s0(j,k)^2;
        ind_col=s1(j,k,2);
         A1(ind_row,ind_col)=-(2*gp_s(j)*qpump0(j,k)*s0(j,k)+3*hp_s(j)*s0(j,k)^2);
        ind_col=PP(j,k,2);
        A1(ind_row,ind_col)=1;
        ind_col=NN(j,k,2);
        A1(ind_row,ind_col)=U_power;
        b1(ind_row)=-gp_s(j)*s0(j,k)^2*qpump0(j,k)-2*gp_s(j)*qpump0(j,k)*s0(j,k)^2-3*hp_s(j)*s0(j,k)^3+U_power;
         ind_row=ind_row+1;
    end
    
      
    %% Group 4 - Flow ww in pipe segments
       for j=1:4
           for i=1:3
               % Right side inequality
               ind_col=ww(j,i,k,2);
               A1(ind_row,ind_col)=1;
               ind_col=BB(j,i,k,2);
               A1(ind_row,ind_col)=-xp(j,i+1);
               b1(ind_row)=0;
               ind_row=ind_row+1;
               
               % Left side inequality
               ind_col=ww(j,i,k,2);
               A1(ind_row,ind_col)=-1;
               ind_col=BB(j,i,k,2);
               A1(ind_row,ind_col)=xp(j,i);
               b1(ind_row)=0;
               ind_row=ind_row+1;
           end
       end
       
     %% Group 5 - speed in pump domains
       for j=1:2
           for i=1:4
               % Right inequality
               ind_col=ss(j,i,k,2);
               A1(ind_row,ind_col)=1;
               ind_col=AA(j,i,k,2);
               A1(ind_row,ind_col)=-smax(j);
               b1(ind_row)=0;
               ind_row=ind_row+1;
               
               % Left inequality
                ind_col=ss(j,i,k,2);
               A1(ind_row,ind_col)=-1;
               ind_col=AA(j,i,k,2);
               A1(ind_row,ind_col)=smin(j);
               b1(ind_row)=0;
               ind_row=ind_row+1;
           end
       end
       
    %% Group 6 - flowin pump domains
        for j=1:2
           for i=1:4
               % Right inequality
               ind_col=qq(j,i,k,2);
               A1(ind_row,ind_col)=1;
               ind_col=AA(j,i,k,2);
               A1(ind_row,ind_col)=-qitcp(j);
               b1(ind_row)=0;
               ind_row=ind_row+1;
               
               % Left inequality
                ind_col=qq(j,i,k,2);
               A1(ind_row,ind_col)=-1;
               b1(ind_row)=0;
               ind_row=ind_row+1;
           end
        end
        
     %% group 7 - Definition of pump characteristic domains
        for j=1: 2
           % domain A1
             % Line 1  
                ind_col=qq(j,1,k,2);
                A1(ind_row,ind_col)=1;
                ind_col=ss(j,1,k,2);
                A1(ind_row,ind_col)=-M_pump(j,1);
                b1(ind_row)=C_pump(j,1);
                ind_row=ind_row+1;
               % Line 2
                ind_col=qq(j,1,k,2);
                A1(ind_row,ind_col)=1;
                ind_col=ss(j,1,k,2);
                A1(ind_row,ind_col)=-M_pump(j,2);
                b1(ind_row)=C_pump(j,2);
                ind_row=ind_row+1;        
                
             % domain A2
             % Line 2  
                ind_col=qq(j,2,k,2);
                A1(ind_row,ind_col)=-1;
                ind_col=ss(j,2,k,2);
                A1(ind_row,ind_col)=M_pump(j,2);
                b1(ind_row)=-C_pump(j,2);
                ind_row=ind_row+1;
               % Line 3
                ind_col=qq(j,2,k,2);
                A1(ind_row,ind_col)=1;
                ind_col=ss(j,2,k,2);
                A1(ind_row,ind_col)=-M_pump(j,3);
                b1(ind_row)=C_pump(j,3);
                ind_row=ind_row+1;       
                
             % domain A3
                % Line 3  
                ind_col=qq(j,3,k,2);
                A1(ind_row,ind_col)=-1;
                ind_col=ss(j,3,k,2);
                A1(ind_row,ind_col)=M_pump(j,3);
                b1(ind_row)=-C_pump(j,3);
                ind_row=ind_row+1;
               % Line 4
                ind_col=qq(j,2,k,2);
                A1(ind_row,ind_col)=-1;
                ind_col=ss(j,3,k,2);
                A1(ind_row,ind_col)=M_pump(j,4);
                b1(ind_row)=-C_pump(j,4);
                ind_row=ind_row+1;   
                
              % domain A4
                % Line 4  
                ind_col=qq(j,4,k,2);
                A1(ind_row,ind_col)=1;
                ind_col=ss(j,4,k,2);
                A1(ind_row,ind_col)=-M_pump(j,4);
                b1(ind_row)=C_pump(j,4);
                ind_row=ind_row+1;
               % Line 1
                ind_col=qq(j,4,k,2);
                A1(ind_row,ind_col)=1;
                ind_col=ss(j,4,k,2);
                A1(ind_row,ind_col)=M_pump(j,1);
                b1(ind_row)=-C_pump(j,1);
                ind_row=ind_row+1;  
        end
        
                
       %% group 8 - Pump equations
                
               for j=1:2
                   % Right inequality
                  ind_col=hc1(3,k,2);
                  A1(ind_row,ind_col)=1; 
                  ind_col=hc1(2,k,2);
                  A1(ind_row,ind_col)=-1;
                  
                  ind_col=ss(j,1,k,2);
                  A1(ind_row,ind_col)=-dd(j,1); 
                  ind_col=ss(j,2,k,2);
                  A1(ind_row,ind_col)=-dd(j,2);
                  ind_col=ss(j,3,k,2);
                  A1(ind_row,ind_col)=-dd(j,3);
                  ind_col=ss(j,4,k,2);
                  A1(ind_row,ind_col)=-dd(j,4); 
                                    
                  ind_col=qq(j,1,k,2);
                  A1(ind_row,ind_col)=-ee(j,1); 
                  ind_col=qq(j,2,k,2);
                  A1(ind_row,ind_col)=-ee(j,2);
                  ind_col=qq(j,3,k,2);
                  A1(ind_row,ind_col)=-ee(j,3);
                  ind_col=qq(j,4,k,2);
                  A1(ind_row,ind_col)=-ee(j,4);
                  
                  ind_col=AA(j,i,k,2);
                  A1(ind_row,ind_col)=-ff(j,1); 
                   ind_col=AA(j,2,k,2);
                  A1(ind_row,ind_col)=-ff(j,2);
                   ind_col=AA(j,3,k,2);
                  A1(ind_row,ind_col)=-ff(j,3);
                   ind_col=AA(j,4,k,2);
                  A1(ind_row,ind_col)=-ff(j,4);
                  
                   ind_col=NN(j,k,2);
                   A1(ind_row,ind_col)=U_pump;
                   b1(ind_row)=U_pump;
                   ind_row=ind_row+1;
                   
                % Left inequality
                  ind_col=hc1(3,k,2);
                  A1(ind_row,ind_col)=-1; 
                  ind_col=hc1(2,k,2);
                  A1(ind_row,ind_col)=1;
                  
                  ind_col=ss(j,1,k,2);
                  A1(ind_row,ind_col)=dd(j,1); 
                  ind_col=ss(j,2,k,2);
                  A1(ind_row,ind_col)=dd(j,2);
                  ind_col=ss(j,3,k,2);
                  A1(ind_row,ind_col)=dd(j,3);
                  ind_col=ss(j,4,k,2);
                  A1(ind_row,ind_col)=dd(j,4); 
                                    
                  ind_col=qq(j,1,k,2);
                  A1(ind_row,ind_col)=ee(j,1); 
                  ind_col=qq(j,2,k,2);
                  A1(ind_row,ind_col)=ee(j,2);
                  ind_col=qq(j,3,k,2);
                  A1(ind_row,ind_col)=ee(j,3);
                  ind_col=qq(j,4,k,2);
                  A1(ind_row,ind_col)=ee(j,4);
                  
                  ind_col=AA(j,i,k,2);
                  A1(ind_row,ind_col)=ff(j,1); 
                   ind_col=AA(j,2,k,2);
                  A1(ind_row,ind_col)=ff(j,2);
                   ind_col=AA(j,3,k,2);
                  A1(ind_row,ind_col)=ff(j,3);
                   ind_col=AA(j,4,k,2);
                  A1(ind_row,ind_col)=ff(j,4);
                  
                   ind_col=NN(j,k,2);
                   A1(ind_row,ind_col)=U_pump;
                   b1(ind_row)=U_pump;
                   ind_row=ind_row+1;
               end
                 
        
end
A1_sparse=sparse(A1);
b1_sparse=sparse(b1);
no_of_inequalities=ind_row-1;
        
    
    