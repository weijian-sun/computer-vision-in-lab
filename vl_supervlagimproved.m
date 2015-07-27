function z = vl_supervlagimproved(kdtree, encoderwords, descrs, codedimention)
dimension=size(descrs,1);
num=dimension/codedimention;
id=0;
z=[];
for n=1:(num-1)
    for m=(n+1):num
        id = id+1;
        temp = [descrs(((codedimention*(n-1)+1):codedimention*n),:);descrs(((codedimention*(m-1)+1):codedimention*m),:)];
        [words,~] = vl_kdtreequery(kdtree{id}, encoderwords{id}, temp, 'MaxComparisons', 100) ;
        code=vlagcode1(temp,encoderwords{id},words);
        z=[z;code];
    end
end
% power normalization
z = sign(z) .* sqrt(abs(z));
% L2 normalization
z = double(z/sqrt(z'*z));
end