function [codeu, codesigma]= vl_singcode2(descrs, mean, sigmainverse)
numdescrs=size(descrs,2);

S0=sum(descrs,2)/numdescrs;
S1=descrs*descrs'/numdescrs;

codeu=sigmainverse*(S0-mean);
codesigma=-1/2*sigmainverse+1/2*sigmainverse*(S1-S0*mean'-mean*S0'+mean*mean')*sigmainverse;

codesigma=[codesigma(1,1);codesigma(1,2);codesigma(2,2)];

% % power normalization
% code = sign(code) .* sqrt(abs(code));
% % L2 normalization
% code = double(code/sqrt(code'*code));
end
