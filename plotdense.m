function [feat]=plotdense(res)
% [y,x]=hist(data,100);
% y=y/length(data)/mean(diff(x));
% bar(x,y,b); 

    %res = vl_simplenn(net, img);
    for i=1:44
    y = res(i).x;    % 13 x 13 x 512
    feat{i} = reshape(y, size(y,1) * size(y,2), size(y,3)); % 169 x 512
    feat{i} = feat{i}'; % 512 x 169, column-wise data points
    end
end