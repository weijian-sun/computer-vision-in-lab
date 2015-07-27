function[ansg]=vlag_calg(gmean,gcov)
numword=size(gmean,2);
n=size(gmean{1},1);
num=1;
xi=0;
for xe=1:n
    idx{num}=[xi,xe];
    num=num+1;
end
for xi=1:n
    for xe=xi:n
      idx{num}=[xi,xe];
      num=num+1;
    end
end
num=num-1;
parfor numw=1:numword
    fprintf('calculate G process word %d\n',numw);
    cov=gcov{numw};
    mean=gmean{numw};
    cov=cov+1*exp(-4)*eye(n);
    covf=inv(cov);
    G=zeros(n+n*(n+1)/2,n+n*(n+1)/2);
for i=1:num
    for e=i:num
        i1=idx{i}(1);
        i2=idx{i}(2);
        e1=idx{e}(1);
        e2=idx{e}(2);
        if((i1==0)&&(i2~=0)&&(e1==0)&&(e2~=0))G(i,e)=cal1(i2,e2,mean,covf);
        elseif((i1==0)&&(i2~=0)&&(e1~=0)&&(e2~=0)&&(e1<e2))G(i,e)=cal2(i2,e1,e2,mean,covf);
        elseif((i1==0)&&(i2~=0)&&(e1~=0)&&(e2~=0)&&(e1==e2))G(i,e)=cal3(i2,e1,mean,covf);
        elseif((i1~=0)&&(i2~=0)&&(e1~=0)&&(e2~=0)&&(i1<i2)&&(e1<e2))G(i,e)=cal4(i1,i2,e1,e2,mean,covf);
        elseif((i1~=0)&&(i2~=0)&&(e1~=0)&&(e2~=0)&&(i1<i2)&&(e1==e1))G(i,e)=cal5(i1,i2,e1,mean,covf);
        elseif((i1~=0)&&(i2~=0)&&(e1~=0)&&(e2~=0)&&(i1==i2)&&(e1==e2))G(i,e)=cal6(i1,e1,mean,covf);
        end
    end
end
for i=2:num
    for e=1:i-1
        G(i,e)=G(e,i);
    end
end
G=G^(1/2);
ansg{numw}=G;
end
end

function[ans]=cal1(i,j,mean,covf)
ans=covf(i,j)*(1+mean'*covf*mean)+sum(mean.*covf(:,i))*sum(mean.*covf(:,j));
end
function[ans]=cal2(i,p,q,mean,covf)
ans=-covf(p,i)*sum(mean.*covf(:,q))-covf(q,i)*sum(mean.*covf(:,p));
end
function[ans]=cal3(i,p,mean,covf)
ans=-covf(p,i)*sum(mean.*covf(:,p));
end
function[ans]=cal4(p,q,r,s,mean,covf)
ans=covf(p,s)*covf(q,r)+covf(q,s)*covf(p,r);
end
function[ans]=cal5(p,q,r,mean,covf)
ans=covf(p,r)*covf(r,q);
end
function[ans]=cal6(p,r,mean,covf)
ans=1/2*(covf(p,r)^2);
end


