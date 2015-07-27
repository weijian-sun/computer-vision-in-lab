function experiments()
% EXPERIMENTS   Run image classification experiments
%    The experimens download a number of benchmark datasets in the
%    'data/' subfolder. Make sure that there are several GBs of
%    space available.
%
%    By default, experiments run with a lite option turned on. This
%    quickly runs all of them on tiny subsets of the actual data.
%    This is used only for testing; to run the actual experiments,
%    set the lite variable to false.
%
%    Running all the experiments is a slow process. Using parallel
%    MATLAB and several cores/machiens is suggested.

% Author: Andrea Vedaldi

% Copyright (C) 2013 Andrea Vedaldi
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

lite = false ;
clear ex ;


ex(1).prefix = 'cnnvd37-superfv-fmd-256w-NOpca+muylescale-seed5' ;
ex(1).trainOpts = {'C', 10} ;
ex(1).datasets = {'fmd'} ;
ex(1).seed = 5;
ex(1).usepreprocessfeature = true;
ex(1).imagedateDir = '2^(-0.5-.5-1)-verydeep-19-level37';
%ex(1).net=load('imagenet-vgg-verydeep-19.mat');
ex(1).savefeature=false;
ex(1).opts = {
  'type', 'fv', ...
  'numWords', 256, ...
  'layouts', {'1x1'}, ...
  'geometricExtension', 'none', ...
  'numPcaDimensions',+inf, ...
  %'extractorFn', @(x) getDenseCnn(x, ex(1).net, 'netlevel', 38, 'scales', 2.^(-0.5:.5:1.5))
  }; 


ex(2).prefix = 'cnnvd37-superfvcovariance-fmd-64w-nopca-64D' ;
ex(2).trainOpts = {'C', 10} ;
ex(2).datasets = {'fmd'} ;
ex(2).seed = 1;
ex(2).usepreprocessfeature = true;
ex(2).imagedateDir = '2^(-0.5-.5-1)-verydeep-19-level37';
%ex(2).net=load('imagenet-vgg-verydeep-19.mat');
ex(2).savefeature=false;
ex(2).opts = {
  'type', 'cnn-superfv-covariance', ...
  'numWords', 64, ...
  'codedimention',64,...
  'layouts', {'1x1'}, ...
  'geometricExtension', 'none', ...
  'numPcaDimensions',+inf, ...
  %'extractorFn', @(x) getDenseCnn(x, net, 'netlevel', 38, 'scales', 2.^(-0.5:.5:1.5))
  }; 
           

ex(3).prefix = 'cnnvd37-supervlagimproved-fmd-8w-nopca-128D' ;
ex(3).trainOpts = {'C', 10} ;
ex(3).datasets = {'fmd'} ;
ex(3).seed = 1;
ex(3).usepreprocessfeature = true;
ex(3).imagedateDir = '2^(-0.5-.5-1)-verydeep-19-level37';
%ex(3).net=load('imagenet-vgg-verydeep-19.mat');
ex(3).savefeature=false;
ex(3).opts = {
  'type', 'cnn-supervlagimproved', ...
  'numWords', 8, ...
  'codedimention',64,...
  'layouts', {'1x1'}, ...
  'geometricExtension', 'none', ...
  'numPcaDimensions',+inf, ...
  %'extractorFn', @(x) getDenseCnn(x, net, 'netlevel', 38, 'scales', 2.^(-0.5:.5:1.5))
  };

ex(4).prefix = 'cnnvd37-singlegaussian-fmd-nopca' ;
ex(4).trainOpts = {'C', 10} ;
ex(4).datasets = {'fmd'} ;
ex(4).seed = 1;
ex(4).usepreprocessfeature = true;
ex(4).imagedateDir = '2^(-0.5-.5-1)-verydeep-19-level37';
%ex(4).net=load('imagenet-vgg-verydeep-19.mat');
ex(4).savefeature=false;
ex(4).opts = {
  'type', 'cnn-singlegaussian', ...
  'layouts', {'1x1'}, ...
  'geometricExtension', 'none', ...
  'numPcaDimensions',+inf, ...
  %'extractorFn', @(x) getDenseCnn(x, net, 'netlevel', 38, 'scales', 2.^(-0.5:.5:1.5))
  }; 


if lite, tag = 'lite' ;
else, tag = 'ex' ; end

%for i=1:numel(ex)
for i=4
  for j=1:numel(ex(i).datasets)
    dataset = ex(i).datasets{j} ;
    if ~isfield(ex(i), 'trainOpts') || ~iscell(ex(i).trainOpts)
      ex(i).trainOpts = {} ;
    end
    traintest(...
      'imagedateDir', ex(i).imagedateDir,...
      'usepreprocessfeature',ex(i).usepreprocessfeature, ...
      'savefeature',ex(i).savefeature, ...
      'prefix', [tag '-' dataset '-' ex(i).prefix], ...
      'dataset', char(dataset), ...
      'datasetDir', fullfile('data', dataset), ...
      'lite', lite, ...
      ex(i).trainOpts{:}, ...
      'encoderParams', ex(i).opts) ;
  end
end
