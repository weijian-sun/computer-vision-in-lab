function features = getDenseCnn(im, net, varargin)
% GETDENSESIFT   Extract dense SIFT features
%   FEATURES = GETDENSESIFT(IM) extract dense SIFT features from
%   image IM.

% Author: Andrea Vedaldi

% Copyright (C) 2013 Andrea Vedaldi
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
opts.netlevel=-1;
opts.sqrt_map=0;
opts.aug_frames=0;
opts.binSize=4;
opts.scales = logspace(log10(1), log10(.25), 5) ;
opts.contrastthreshold = 0 ;
opts.rootSift = false ;
opts.normalizeSift = false ;
opts = vl_argparse(opts, varargin) ;
% 
% dsiftOpts = {'norm', 'fast', 'floatdescriptors', ...
%              'step', opts.step, ...
%              'size', opts.binSize, ...
%              'geometry', opts.geometry} ;

if size(im,3)==1, im = repmat(im,1,1,3); end


%preprocess image
im = single(im);
im = im-imresize((net.normalization.averageImage), [size(im,1) size(im,2)]);

% im = single(im) ; % note: 255 range
% im = imresize(im, net.normalization.imageSize(1:2)) ;
% im = im - net.normalization.averageImage ;


for si = 1:numel(opts.scales)
  
%   if(opt.scales(si)>1)
  im_ = imresize(im, opts.scales(si)) ;
%   else im_ = im;
%   end
  

  descrs{si} = extractCNNFeat(im_, net, opts) ;
  [y1,y2]=size(descrs{si});
  frames{si}=zeros(3, y2);

  % root SIFT
  if opts.rootSift
    descrs{si} = sqrt(descrs{si}) ;
  end
  if opts.normalizeSift
    descrs{si} = snorm(descrs{si}) ;
  end

  % zero low contrast descriptors
  info.contrast{si} = frames{si}(3,:) ;
  kill = info.contrast{si} < opts.contrastthreshold  ;
  descrs{si}(:,kill) = 0 ;

  % store frames
  frames{si}(1:2,:) = (frames{si}(1:2,:)-1) / opts.scales(si) + 1 ;
  frames{si}(3,:) = opts.binSize / opts.scales(si) / 3 ;
end

features.frame = cat(2, frames{:}) ;
features.descr = cat(2, descrs{:}) ;
features.contrast = cat(2, info.contrast{:}) ;
end

function x = snorm(x)
x = bsxfun(@times, x, 1./max(1e-5,sqrt(sum(x.^2,1)))) ;
end



function feat = extractCNNFeat( img, net, opts)
%EXTRACTCNNFEAT Extract conv5 layer features densely from un-resized image
%
% net   CNN structure. Optionally with layers after 'conv5' removed.
% img   3-channel image, un-preprocessed.

    res = vl_simplenn(net, img);
    y = res(opts.netlevel).x;    % 13 x 13 x 512
%     y = res(30).x;
    feat = reshape(y, size(y,1) * size(y,2), size(y,3)); % 169 x 512
    feat = feat'; % 512 x 169, column-wise data points
    
    if opts.sqrt_map
        feat = feat./sum(sum(feat));
        feat = sign(feat).*sqrt(abs(feat));
    end
    
    if opts.aug_frames
        [xPos, yPos] = meshgrid([1:size(y,2)], [1:size(y,1)]);
        xyPos = cat(3, xPos/size(y,2), yPos/size(y,1));
        sp_aug = reshape(xyPos, size(y,1) * size(y,2), 2); % 169 x 2
        feat = cat(1, feat, sp_aug');
    end
    
end
