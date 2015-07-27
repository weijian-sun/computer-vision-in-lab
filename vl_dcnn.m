function descrs = vl_dcnn(im, net)
res = vl_simplenn(net, im);
number=res(14).x;
[n, m, y]=size(number);
a = reshape(number, n*m, y);
descrs=a';
end