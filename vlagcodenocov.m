%function [vlag_vector]=vlagcode(descrs,vocab,belongtoword,g)
function [vector]=vlagcodenocov(descrs,vocab,belongtoword)
[n,m]=size(descrs);
c=zeros(n,m);
for i=1:m
    c(:,i)=descrs(:,i)-vocab(:,belongtoword(i));
end
vector=[];
numword=size(vocab,2);
for i=1:numword
    ok=find(belongtoword==i);
    vector=[vector;sum(c(:,ok),2)];
end

% for i=1:size(vector,1)
%     vector(i)=sign(vector(i))*power(abs(vector(i)),1/2);
% end
% vector=vector/power(vector'*vector,1/2);

end