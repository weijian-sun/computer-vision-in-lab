function [means, covariances, priors] = vl_supergmm(descrs, numWords, codedimention)
dimension=size(descrs,1);
num=dimension/codedimention;
if(num~=fix(num))error('codedimension error\n');end
id=0;
for n=1:(num-1)
    for m=(n+1):num
        fprintf('calculate GMM (%d,%d)\n',n,m);
        id=id+1;
        temp=[descrs(((codedimention*(n-1)+1):codedimention*n),:);descrs(((codedimention*(m-1)+1):codedimention*m),:)];
        v = var(temp')';
        [means{id},covariances{id},priors{id}]=vl_gmm(temp, numWords, 'verbose', ...
                 'Initialization', 'kmeans', ...
                 'CovarianceBound', double(max(v)*0.0001), ...
                 'NumRepetitions', 1) ;
    end
end
end