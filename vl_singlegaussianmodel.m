function [means, covariances] = vl_singlegaussianmodel(descrs)
[dimention, num] = size(descrs);
id=0;
means=cell(1,dimention+dimention*(dimention+1)/2);
covariances=cell(1,dimention+dimention*(dimention+1)/2);
for n=1:(dimention-1)
    for m=(n+1):dimention
        id=id+1;
        fprintf('calculate single gaussian (%d %d)\n',n,m);
        temp=[descrs(n,:);descrs(m,:)];
        means{id}=mean(temp,2);
        covariances{id}=cov(temp')';
    end
end
end