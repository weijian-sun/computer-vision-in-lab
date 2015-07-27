function [meana, covariance]=vlag_gmm2(descrs,words,wordtrain)
numword=size(words,2);
mu={};
co={};
for i=1:numword
    ok=find(wordtrain==i);
    c=descrs(:,ok);
    mu{i}=mean(c,2);
    co{i}=cov(c');
end
meana=mu;
covariance=co;
end