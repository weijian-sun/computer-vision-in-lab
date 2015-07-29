function z = vl_singlegaussiancode(descrs, means, covariance)
[dimetion] = size(descrs,1);
id=0;
z=[];
for n=1:(dimetion-1)
    for m=(n+1):dimetion
       %fprintf('%d %d\n',n,m);
        id=id+1;
        temp=[descrs(n,:);descrs(m,:)];
        code=vl_singcode2(temp, means{id}, covariance{id});
        z=[z;code];
    end
end
% power normalization
z = sign(z) .* sqrt(abs(z));
% L2 normalization
z = double(z/sqrt(z'*z));
end