function list=calculate
list=[];
temp=-1;
num=0;
for n=1:511
    for m=(n+1):512
       num=num+1;
       if((m~=n+1)||(n~=temp+2))
           continue
       else
           temp=n;
           list=[list,num];
       end
    end
end
end