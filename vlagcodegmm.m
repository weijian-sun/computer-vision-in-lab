%function [vlag_vector]=vlagcode(descrs,vocab,belongtoword,g)
function [vlag_vector]=vlagcodegmm(descrs, mean, covariances, priors)
[n,m]=size(mean);
numword=m;
for i=1:numword
    u=mean(i,:);
    sigma=covariances(i,:);
    vector{i}=sum(priors *(descrs- u)/sigma);
end
vector=cat(1,vector);
for i=1:size(vector,1)
    vector(i)=sign(vector(i))*power(abs(vector(i)),1/2);
end
vector=vector/power(vector'*vector,1/2);
vlag_vector=vector;
end