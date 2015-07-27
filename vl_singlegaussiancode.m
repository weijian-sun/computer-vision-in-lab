function z = vl_singlegaussiancode(descrs, means, covariances)
% description: calculation fisher vector for evert two dimentio in
% the descrs
[dimetion] = size(descrs,1);
id=0;
for n=1:(dimetion-1)
    for m=(n+1):dimetion
        temp=[descrs(n,:);descrs(m,:)];
        code=vl_singcode(temp);
        z=[z,code];
    end
end

end