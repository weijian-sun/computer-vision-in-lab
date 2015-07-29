function [means, covariances, priors] = vl_fvsinglegaussianmodel(descrs)
[dimention, num] = size(descrs);
id=0;
means=cell(1,dimention+dimention*(dimention+1)/2);
covariances=cell(1,dimention+dimention*(dimention+1)/2);
for n=1:(dimention-1)
    for m=(n+1):dimention
        fprintf('calculate model %d-%d\n',n,m);
        id=id+1;
        temp=[descrs(n,:);descrs(m,:)];
        
                    v = var(descrs')' ;
            [means{id}, covariances{id}, priors{id}] = ...
                vl_gmm(temp, 1, 'verbose', ...
                'Initialization', 'kmeans', ...
                'CovarianceBound', double(max(v)*0.0001), ...
                'NumRepetitions', 1) ;

    end
end
end