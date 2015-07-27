function [z]=supervlagcode(kdtree, encoderwords, descrs, list)
dimention=size(descrs,1);
z=[];
num=0;
last=-1;
for n=1:2:(dimention-1)
        m=n+1;
        num=num+1;
        
        %fprintf('calculate %d-(%d,%d)\n',num,n,m);
        temp=[descrs(n,:);descrs(m,:)];
        [words,~] = vl_kdtreequery(kdtree{list(num)}, encoderwords{list(num)}, temp, 'MaxComparisons', 100) ;
        code=vlagcodenocov(temp,encoderwords{list(num)},words);
        z=[z;code];
end
end