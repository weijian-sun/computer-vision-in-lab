function code = vl_singcode3(descrs, mean, covariance)
numdescrs=size(descrs,2);
[u,s,v]=svd(covariance);
sigmainverse=v*s^(-1)*u';
codeu=sigmainverse*(sum(descrs,2)/numdescrs-mean);
temp=bsxfun(@minus,descrs,mean);
codesigma=-1/2*sigmainverse+1/2*sigmainverse*(temp*temp'/numdescrs)*sigmainverse;
code=[codeu;codesigma(1,1);codesigma(1,2);codesigma(2,2)];
% % power normalization
% code = sign(code) .* sqrt(abs(code));
% % L2 normalization
% code = double(code/sqrt(code'*code));
end
