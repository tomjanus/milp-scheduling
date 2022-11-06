function [diag1,diag2,diag3]=Diagnostics(lb,x,ub,A1,b1)


%% CHECK bound constraints

diag=zeros(65,4);

for m=1:65
    diag1(m,2)=lb(m);
    diag1(m,3)=x(m);
    diag1(m,4)=ub(m);
    diag1(m,1)=m;
end

count=0;
for m=1:1560
    if x(m)>=lb(m) & x(m)<=ub(m)
    ind(m)=1;
    else
        ind(m)=0;
        count=int16(count);
        count=count+1;
        diag2(count,1)=m;
        diag2(count,2)=lb(m);
        diag2(count,3)=x(m);
        diag2(count,4)=ub(m);
    end
end

    if count==0
        diag2=0;
    end
    size(ind)
    
    
    %% CHECK INEQUALITY CONSTRAINTS
    count1=0;
    left_side=A1*x';
    for m=1:2016
        if left_side(m)<=b1(m)
            ind1(m)=1;
        else
            count1=count1+1;
            diag3(count1,1)=m;
            diag3(count1,2)=left_side(m);
            diag3(count1,3)=b1(m);
        end
    end
    disp(count1);
    
end



    