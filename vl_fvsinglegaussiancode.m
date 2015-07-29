function z = vl_fvsinglegaussiancode(descrs, means, covariances, priors)
[dimetion] = size(descrs,1);
id=0;
z=[];
for n=1:(dimetion-1)
    for m=(n+1):dimetion
       %fprintf('%d %d\n',n,m);
        id=id+1;
        temp=[descrs(n,:);descrs(m,:)];
                    code = vl_fisher(temp, ...
                means{id}, ...
                covariances{id}, ...
                priors{id}, ...
                'Improved') ;

        z=[z;code];
    end
end
% power normalization
z = sign(z) .* sqrt(abs(z));
% L2 normalization
z = double(z/sqrt(z'*z));
end