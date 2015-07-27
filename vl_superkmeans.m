function [words, kdtree] = vl_superkmeans(descrs, numWords)
dimention=size(descrs,1);
num=0;
for n=1:(dimention-1)
    for m=(n+1):dimention
        num=num+1;
        %fprintf('calculate superkmeans of %d--(%d,%d)\n',num,n,m);
        temp=[descrs(n,:);descrs(m,:)];
        words{num} = vl_kmeans(temp, numWords, 'verbose', 'algorithm', 'elkan') ;
        kdtree{num} = vl_kdtreebuild(words{num}, 'numTrees', 2) ;
    end
end
