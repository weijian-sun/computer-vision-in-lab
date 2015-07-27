%function [vlag_vector]=vlagcode(descrs,vocab,belongtoword,g)
function [vlag_vector]=vlagcode1(descrs,vocab,belongtoword)
[n,m]=size(descrs);
c=zeros(n,m);
for i=1:m
    c(:,i)=descrs(:,i)-vocab(:,belongtoword(i));
end
numword=size(vocab,2);
for i=1:numword
    ok=find(belongtoword==i);
    n1{i}=sum(c(:,ok),2);
    b=c(:,ok);
    d=zeros(n,n);
    for e=1:size(b,2)
        d=d+b(:,e)*b(:,e)';
    end
    n2{i}=d;
end

for i=1:numword
    vec1=n1{i};
    d1=n2{i};
    d1=call(d1);
    d1=[vec1;d1];
%     d2=g{i};
%     vector{i}=d2*d1;
    vector{i}=d1;
end
vector=cat(1,vector{:});
for i=1:size(vector,1)
    vector(i)=sign(vector(i))*power(abs(vector(i)),1/2);
end
vector=vector/power(vector'*vector,1/2);
vlag_vector=vector;
end

function [tri]=call(b)
[a1,a2]=size(b);
tri=[];
for p=1:a1
    for q=p:a2
        tri=[tri;b(p,q)];
    end
end
end