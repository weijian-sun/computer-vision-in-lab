function code = vl_singcode(descrs, mean, covariance)
[dimention, numdescrs]=size(descrs);
[u,s,v]=svd(covariance);
sigmainverse=v*s^(-1)*u';
S0=sum(descrs,2)/numdescrs;
S1=zeros(dimention, dimention);
for n=1:numdescrs
    S1=S1+descrs(:,n)*descrs(:,n)';
end
S1=S1/numdescrs;
codeu=sigmainverse*(S0-mean);
codesigma=-1/2*sigmainverse+1/2*sigmainverse*(S1-S0*mean'-mean*S0'+mean*mean')*sigmainverse;
code=[codeu;getup(codesigma)];
% power normalization
code = sign(code) .* sqrt(abs(code));
% L2 normalization
code = double(code/sqrt(code'*code));
end

function z=getup(cov)
dimention=size(cov,2);
z=zeros(dimention*(dimention+1)/2,1);
id=0;
for n=1:dimention
    for m=n:dimention
        id=id+1;
        z(id)=cov(n,m);
    end
end
end

