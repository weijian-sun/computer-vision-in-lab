function imdb = setupFMD(datasetDir, varargin)
% SETUPSCENE67    Setup Flickr Material Dataset
%    This is similar to SETUPCALTECH101(), with modifications to setup
%    the Flickr Material Dataset accroding to the standard
%    evaluation protocols.
%
%    See: SETUPCALTECH101().

% Author: Andrea Vedaldi

% Copyright (C) 2013 Andrea Vedaldi
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

opts.imagedateDir='imagefeature';
opts.usepreprocessfeature=false;
opts.savefeature=false;

opts.codedimention = 0;
opts.nettype = 'imagenet-vgg-m.mat';
opts.factor = 0;
opts.step = -1;
opts.type = 'bovw' ;
opts.numWords = [] ;
opts.seed = 1 ;
opts.numPcaDimensions = +inf ;
opts.whitening = false ;
opts.whiteningRegul = 0 ;
opts.numSamplesPerWord = [] ;
opts.renormalize = false ;
opts.layouts = {'1x1'} ;
opts.geometricExtension = 'none' ;
opts.subdivisions = zeros(4,0) ;
opts.readImageFn = @readImage2 ;
opts.extractorFn = @getDenseCnn ;

opts.lite = false ;
opts.seed = 1 ;
opts.numTrain = 50 ;
opts.numTest = 50 ;
opts.autoDownload = true ;
opts = vl_argparse(opts, varargin) ;

% Download and unpack
vl_xmkdir(datasetDir) ;
if exist(fullfile(datasetDir, 'image', 'wood'))
  % ok
elseif opts.autoDownload
  url = 'http://people.csail.mit.edu/celiu/CVPR2010/FMD/FMD.zip' ;
  fprintf('Downloading FMD data to ''%s''. This will take a while.', datasetDir) ;
  unzip(url, datasetDir) ;
else
  error('FMD not found in %s', datasetDir) ;
end

imdb = setupGeneric(fullfile(datasetDir,'image'), ...
  'numTrain', opts.numTrain, 'numVal', 0, 'numTest', opts.numTest,  ...
  'expectedNumClasses', 10, ...
  'seed', opts.seed, 'lite', opts.lite) ;


imdb.imagedataDir = ['data\fmd\',opts.imagedateDir];
if(opts.savefeature)
switch opts.type
    case {'cnn-vlag','cnn-fv','cnn-gradient-fv'}
        net = load(opts.nettype) ;
        image=imdb.images.name;
%         getfeuture=opts.extractorFn;
        cacheChunkSize=50
        numChunks = ceil(numel(image) / cacheChunkSize) ;
        for c = 1:numChunks
            fprintf('process %d chunk',c);
            n  = min(cacheChunkSize, numel(image) - (c-1)*cacheChunkSize) ;
            range = (c-1)*cacheChunkSize + (1:n) ;
            
        parfor i=1:numel(image(range))
            fprintf('process %d\n',i);
            im = opts.readImageFn(fullfile(datasetDir,'image',image{range(i)})) ;
            [pathstr,name,ext] = fileparts(image{range(i)});
            
            descrs = opts.extractorFn(im, net) ;
            descrs.size = size(im);
            descrs.w = size(im,2) ;
            descrs.h = size(im,1) ;
            dress=fullfile(datasetDir,'imagefeature',image{range(i)}(1:(end-4)));
            descrsA{i}=descrs;
            placeA{i}=dress;
            
%             mkdir(fullfile(datasetDir,'imagefeature',pathstr));
%             save(dress,'-struct', 'descrs') ;
        end
        
        for i=1:numel(image(range))
             fprintf('save descrs %d\n',i);
             descrs=descrsA{i};
             [pathstr,name,ext] = fileparts(placeA{i});
             mkdir(pathstr);
            save(placeA{i},'-struct','descrs');
        end
        end
    otherwise
end
end