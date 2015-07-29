function [means, covariances] = vl_singlegaussianmodel(descrs)
[dimention, num] = size(descrs);
id=0;
means=cell(1,dimention+dimention*(dimention+1)/2);
covariances=cell(1,dimention+dimention*(dimention+1)/2);
for n=1:(dimention-1)
    for m=(n+1):dimention
        fprintf('calculate model %d-%d\n',n,m);
        id=id+1;
        temp=[descrs(n,:);descrs(m,:)];
        means{id}=mean(temp,2);
        covariances{id}=cov(temp')';
    end
end
end