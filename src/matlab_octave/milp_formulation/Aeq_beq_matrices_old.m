
 global R1 R2 R3 R4 A B C At nc nf e Lc Lf hr et x_min x_max gp hp d  T time

 Lambda=[Lc;Lf];
 pipe_index1=[1;4;5;6]; % Pie flow index in Scheduler
 
ind_row=1;


function Aeq = create_Aeq()
  % Creates the equality constraint matrix
end

function beq = create_beq()
  % Creates the equality constraint vector
end

%% MAIN TIME LOOP

for k=1:TIME_HORIZON
    
%% Group 1 - Tank level equation
   
   ind_col=ht1(k,2);
    A1eq(ind_row,ind_col)=1;
    ind_col=ht1(k,2);
    A1eq(ind_row,ind_col)=-1;
    ind_col=q1(5,k,2);
    A1eq(ind_row,ind_col)=-1/At;
    b1eq(ind_row)=0;
    ind_row=ind_row+1;
    
    
  %% GROUP 2 - Flows in segments of pipes
    
      for j=1:4
           pointer=pipe_index(j);
           ind_col==q1(pointer,k,2);
           A1eq(ind_row,ind_col)=1;
           for i=1:3
               ind_col=ww(j,i,k,2);
               A1eq(ind_row,ind_col)=-1;
           end
           b1(ind_row)=0;
           ind_row=ind_row+1;
      end
      
           
   %% GROUP 3 - Selection of a pipe segment
         for j=1:4
           for i=1:3
               ind_col=BB(j,i,k,2);
                A1eq(ind_row,ind_col)=1;
           end
           b1eq(ind_row)=1;
           ind_row=ind_row+1;
       end
       
    %% GROUP 4  - Pipe equation
       
       for j=1:4
         pointer=pipe_index1(j);
         column=Lambda(:,j);
         for i=1:6
             if Lambda(i,j)==-1
                 origin=i;
             elseif Lambda(i,j)==1
                 destination=i;
             else
                % do nothing
             end
         end
             if origin==hr_index
                 ind_col=hc1(j,k,2);
                 A1eq(ind_row,ind_col)=-1;
                 b1eq(ind_row)=-hr;
             elseif destination==ht_index
                  ind_col=ht1(k,2);
                  A1eq(ind_row,ind_col)=1;
                  ind_col=hc1(j,k,2);
                   A1eq(ind_row,ind_col)=-1;
                   b1eq(ind_row)=0;
             else
                 ind_col=hc1(origin,TIME_HORIZON,2);
                 A1eq(ind_row,ind_col)=1;
                 ind_col=hc1(destination,TIME_HORIZON,2);
                 A1eq(ind_row,ind_col)=-1;
                  b1eq(ind_row)=0;
             end
                                        
           ind_col==q1(pointer,k,2); 
           for i=1:3
               ind_col=ww(j,i,k,2);
               A1eq(ind_row,ind_col)=-M_pipe(j,i);
               ind_col=BB(j,i,k,2);
                A1eq(ind_row,ind_col)=-C_pipe(j,i);
           end
           ind_row=ind_row+1;
         end
         
    %% GROUP 5 - speed and flow in pumps rqual to speed and flows in pump donains
   
        for j=1:2
            ind_col=s1(j,k,2);
             A1eq(ind_row,ind_col)=1;
             for i=1:4
                 ind_col=ss(j,i,k,2);
                 A1eq(ind_row,ind_col)=-1;
             end
             b1eq(ind_row)=0;
             ind_row=ind_row+1;
             
             pointer=pump_index(j);
             ind_col=q1(pointer,k,2);  
             A1eq(ind_row,ind_col)=1;
             for i=1:4
                 ind_col=qq(j,i,k,2);
                 A1eq(ind_row,ind_col)=-1;
             end
             b1eq(ind_row)=0;
             ind_row=ind_row+1;
        end
                
        
     %% GROUP 6 - Selection of a pump domain, only one is active
        for j=1:2
          ind_col=NN(j,k,2);  
          A1eq(ind_row,ind_col)=-1;
          for i=1:4
              ind_col=AA(j,i,k,2);
              A1eq(ind_row,ind_col)=1;
          end
          b1eq(ind_row)=0;
          ind_row=ind_row+1;
        end
        
        end
        
        A1eq_sparse=sparse(A1eq);
        b1eq_sparse=sparse(b1eq);
              

               
           
      