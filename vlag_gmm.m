function [mean, covariance]=vlag_gmm(descrs,words,wordtrain)
[n,m]=size(descrs);
c=zeros(n,m);
numword=size(words,2);
mu={};
co={};
for i=1:m
    c(:,i)=descrs(:,i)-words(:,wordtrain(i));
end
for i=1:numword
    ok=find(wordtrain==i);
    mu{i}=sum(c(:,ok),2)/length(ok);
end
for i=1:m
    c(:,i)=c(:,i)-mu{wordtrain(i)};
end
for i=1:numword
    ok=find(wordtrain==i);
    b=c(:,ok);
    d=zeros(n,n);
    for e=1:size(b,2)
        d=d+b(:,e)*b(:,e)';
    end
    co{i}=d/length(ok);
end
mean=mu;
covariance=co;
end

        
        