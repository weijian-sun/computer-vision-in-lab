function z = vl_singlegaussiancode(descrs, means, covarianceinverse)
[dimension] = size(descrs,1);
id=0;
zu=zeros(dimension*(dimension+1),1);
zsigma=zeros(dimension*(dimension+1)/2*3,1);

numu=1;
numsigma=1;

for n=1:(dimension-1)
    for m=(n+1):dimension
        %fprintf('%d %d\n',n,m);
        id=id+1;
        temp=[descrs(n,:);descrs(m,:)];
        [zu(numu:(numu+1)), zsigma(numsigma:(numsigma+2))]=vl_singcode2(temp, means{id}, covarianceinverse{id});
        numu=numu+2;
        numsigma=numsigma+3;
    end
end

zu=norm(zu);
zsigma=norm(zsigma);
z=[zu;zsigma];
z=norm(z);
end

function z=norm(z)
% power normalization
z = sign(z) .* sqrt(abs(z));
% L2 normalization
z = double(z/sqrt(z'*z));
end