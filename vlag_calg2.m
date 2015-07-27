function[ansg]=vlag_calg2(gmean,gcov)
numword=size(gmean,2);
n=size(gmean{1},1);
for numw=1:numword
    fprintf('calculate G process word %d\n',numw);
    cov=gcov{numw};
    mean=gmean{numw};
    cov=cov+1*exp(-4)*eye(n);
    covf=inv(cov);
    G=zeros(n+n*(n+1)/2,n+n*(n+1)/2);
    for i=1:n
        for j=i:n
            G(i,j)=cal1(i,j,mean,covf);
        end
    end
    for i=1:n
        for p=1:n
            for q=(p+1):n
                G(i,calid(p,q,n))=cal2(i,p,q,mean,covf);
            end
        end
    end
    for i=1:n
        for p=1:n
            G(i,calid(p,p,n))=cal3(i,p,mean,covf);
        end
    end
    for p=1:n
        for q=(p+1):n
            for r=1:n
                for s=(r+1):n
                    G(calid(p,q,n),calid(r,s,n))=cal4(p,q,r,s,mean,covf);
                end
            end
        end
    end
    for p=1:n
        for q=(p+1):n
            for r=1:n
                G(calid(p,q,n),calid(r,r,n))=cal5(p,q,r,mean,covf);
            end
        end
    end
    for p=1:n
        for r=1:n
            G(calid(p,p,n),calid(r,r,n))=cal6(p,r,mean,covf);
        end
    end
    for i=2:(n+n*(n+1)/2)
        for e=1:i-1
            G(i,e)=G(e,i);
        end
    end
    C=eig(G);
    cova=fix(abs(C(1)))+1
    G=G+cova*eye(n+n*(n+1)/2);
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
 
function[id]=calid(p,q,demention)
id=demention+(2*demention-p+2)*(p-1)/2+q-p+1;
end