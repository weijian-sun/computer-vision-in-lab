function fvt=fisher_encode(feats, mean, var, coef)
% Perform Fisher Vector encoding using PCA coefficients and pretrained GMM
% parameters.

% L1 normalization & Square root
feats=sqrt(feats/norm(feats,1));


D=size(feats,1); %dimention
T=size(feats,2); %num of feature
K=size(mean,2);  %num of word

% Fisher vector, dimension (2D+1)*K
fvt=zeros((D+D*(D+1)/2+1)*K,1); 

% Initialize accumulators, K:numofword,D:dimension
S0=zeros(1,K);
S1=zeros(D,K); % DxK matrix
S2=zeros(D,D,K); % DxK matrix
% Compute statistics
for t=1:T
    %fprintf('%d\n',t);
    g=zeros(1,K); % Gaussians
    gamma=zeros(1,K); % soft assignment of x_t to Gaussian k
    for k=1:K
        % Compute the soft assignment of x_t to Gaussian k
        %g(k)=Gauss(feats(:,t),mean(:,k),var(:,:,k));
        g(k)=loggausspdf(feats(:,t),mean(:,k),var(:,:,k));
    end
    g=exp(g);
	g(isinf(g))=1e30; % Replace inf with a very large number
    gamma=coef.*g/(coef*g');
    
    S0=S0+gamma;
    S1=S1+feats(:,t)*gamma;
    for k=1:k
    S2(:,:,k)=S2(:,:,k)+(feats(:,t)*feats(:,t)')*gamma(k);
    end
end

% Compute the Fisher vector signature
Galpha=zeros(1,K);
Gmiu=zeros(D,K); % DxK matrix
Gcov=zeros(D,D,K); %DxDxK matrix

Galpha=(S0-T*coef)./sqrt(coef);
% TODO: substitute for loop by matrix multiplication
for k=1:K
    [u,s,v]=svd(var(:,:,k));
    it1=s^(1/2)*u';%sigma^(-1/2)
    it2=v*s^(-1)*u';%sigma^(-1)
    Gmiu(:,k)=it1*(S1(:,k)-mean(:,k)*S0(k))./(sqrt(coef(k)));
    Gcov(:,:,k)=(var(:,:,k)*(S2(:,:,k)-S1(:,k)*mean(:,k)'-mean(:,k)*S1(:,k)'+S0(k)*mean(:,k)*mean(:,k)')*(it2^2)-S0(k))./(sqrt(2*coef(k)));
end
f=getupper(Gcov);
fvt=[Galpha';Gmiu(:);f(:)];

% Replace NaN with very large number
fvt(isnan(fvt)) = 123456;

% Apply normalizations
% power normalization
fvt = sign(fvt) .* sqrt(abs(fvt));
% L2 normalization
fvt = double(fvt/sqrt(fvt'*fvt));

end

function u=Gauss(x,miu,sigma)
% Computer Gaussian distribution
%   x - 1xD input feature
%   miu - 1xD mean
%   sigma - DxD full covariance

D=size(x,1);
[U,S,V]=svd(sigma);
u=1./((2*pi)^(D/2)*sqrt(det(sigma)))*exp(-0.5*(x-miu)'*(V*S^(-1)*U')*(x-miu));

end

function c=getupper(cov)
% extra upper triangular matrix
% cov - covariance matrix
c=[];
d=size(cov,1);
for n=1:d
    for m=n:d
        c=[c;cov(n,m,:)];
    end
end
end


function y = loggausspdf(X, mu, Sigma)
d = size(X,1);
X = bsxfun(@minus,X,mu);
[U,p]= chol(Sigma);%u'*u=sigma
if p ~= 0 %judge whether is positive definite
    error('ERROR: Sigma is not PD.');
end
Q = U'\X;
q = dot(Q,Q,1);  % quadratic term (M distance)
c = d*log(2*pi)+2*sum(log(diag(U)));   % normalization constant
y = -(c+q)/2;
end