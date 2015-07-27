function [means, covariances, priors] = vl_supergmmcovariance(descrs, numWords, codedimention)
dimension=size(descrs,1);
num=dimension/codedimention;
if(num~=fix(num))error('codedimension error\n');end
id=0;
for n=1:(num-1)
    for m=(n+1):num
        fprintf('calculate globle GMM (%d,%d)\n',n,m);
        id=id+1;
        temp=[descrs(((codedimention*(n-1)+1):codedimention*n),:);descrs(((codedimention*(m-1)+1):codedimention*m),:)];
        [~, model, ~] = emgm(temp, vl_kmeans(temp, numWords, 'verbose', 'algorithm', 'elkan'));
        means{id} = model.mu;
        covariances{id} = model.Sigma;
        priors{id} = model.weight;
    end
end
end