function z = vl_singlegaussiancode(descrs, means, covarianceinverse)
[dimetion] = size(descrs,1);
id=0;
zu=zeros(dimention*(dimention+1),1);
zsigma=zeros(dimetion*(dimention+1)/2*3,1);

numu=1;
numsigma=1;

for n=1:(dimetion-1)
    for m=(n+1):dimetion
        %fprintf('%d %d\n',n,m);
        id=id+1;
        temp=[descrs(n,:);descrs(m,:)];
        [zu(numu:num+2), zsigma(numsigma:numsigma+3)]=vl_singcode2(temp, means{id}, covarianceinverse{id});
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