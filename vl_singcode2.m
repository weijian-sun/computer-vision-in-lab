function code = vl_singcode2(descrs, mean, covariance)
numdescrs=size(descrs,2);
[u,s,v]=svd(covariance);
sigmainverse=v*s^(-1)*u';
S0=sum(descrs,2)/numdescrs;
S1=descrs*descrs';
S1=S1/numdescrs;
codeu=sigmainverse*(S0-mean);
codesigma=-1/2*sigmainverse+1/2*sigmainverse*(S1-S0*mean'-mean*S0'+mean*mean')*sigmainverse;


code=[codeu;codesigma(1,1);codesigma(1,2);codesigma(2,2)];
% % power normalization
% code = sign(code) .* sqrt(abs(code));
% % L2 normalization
% code = double(code/sqrt(code'*code));
end
