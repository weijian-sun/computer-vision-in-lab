function [ans] = vl_fishergradient(descrs, means, covariances, priors, step, factor)
% temp = vl_fisher(descrs, means, covariances, priors, 'Improved') ;
[n,m]=size(means);
temp=[reshape(means,n*m,1);reshape(covariances,n*m,1)];
ans=zeros(size(temp));
for i=1:step
    tempmean=reshape(temp(1:n*m),n,m);
    tempcovariances=reshape(temp((n*m+1):2*n*m),n,m);
    for n=1:size(tempcovariances,1)
        for m=1: size(tempcovariances,2)
            if tempcovariances(n,m)<0
                tempcovariances(n,m)=0.1;
            end
        end
    end
    fv=vl_fisher(descrs, tempmean, tempcovariances, priors, 'improved') ;
    temp = temp - factor* fv;
    ans=ans+fv;
end
end