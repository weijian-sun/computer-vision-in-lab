function [words, kdtree] = vl_superkmeansimproved(descrs, numWords, codedimention)
dimension=size(descrs,1);
num=dimension/codedimention;
if(num~=fix(num))error('codedimension error\n');end
id=0;
for n=1:(num-1)
    for m=(n+1):num
        fprintf('calculate kmeans (%d,%d)\n',n,m);
        id=id+1;
        temp=[descrs(((codedimention*(n-1)+1):codedimention*n),:);descrs(((codedimention*(m-1)+1):codedimention*m),:)];
        words{id} = vl_kmeans(temp, numWords, 'verbose', 'algorithm', 'elkan') ;
        kdtree{id} = vl_kdtreebuild(words{id}, 'numTrees', 2) ;
    end
end
end