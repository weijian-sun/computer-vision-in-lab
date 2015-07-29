function recognition_demo(varargin)
% RECOGNITION_DEMO  Demonstrates using VLFeat for image classification


S = RandStream('mt19937ar','seed',1024);
RandStream.setGlobalStream(S);

total_start_time = round(clock);

%if ~exist('vl_version')
  run(fullfile(fileparts(which(mfilename)), ...
               'vlfeat-0.9.20-for test2', 'toolbox', 'vl_setup.m')) ;
  run(fullfile(fileparts(which(mfilename)), ...
               'vlfeat-0.9.20-for test2', 'matconvnet-1.0-beta12', 'matlab', 'vl_setupnn.m')) ;
%end

opts.usepreprocessfeature=false;
opts.savefeature=false;

opts.imagedateDir='imagefeature';
opts.dataset = 'caltech101' ;
opts.prefix = 'bovw' ;
opts.encoderParams = {'type', 'bovw'} ;
opts.seed = 1 ;
opts.lite = true ;
opts.C = 10 ;
opts.kernel = 'linear' ;
opts.dataDir = 'data';
opts.setupdata=@(x)setupFMD(x);
for pass = 1:2
  opts.datasetDir = fullfile(opts.dataDir, opts.dataset) ;
  opts.resultDir = fullfile(opts.dataDir, opts.prefix) ;
  opts.imdbPath = fullfile(opts.resultDir, 'imdb.mat') ;
  opts.encoderPath = fullfile(opts.resultDir, 'encoder.mat') ;
  opts.modelPath = fullfile(opts.resultDir, 'model.mat') ;
  opts.diaryPath = fullfile(opts.resultDir, 'diary.txt') ;
  opts.cacheDir = fullfile(opts.resultDir, 'cache') ;
  opts = vl_argparse(opts,varargin) ;
end

% do not do anything if the result data already exist
if exist(fullfile(opts.resultDir,'result.mat')),
  load(fullfile(opts.resultDir,'result.mat'), 'ap', 'confusion') ;
  fprintf('%35s mAP = %04.1f, mean acc = %04.1f\n', opts.prefix, ...
          100*mean(ap), 100*mean(diag(confusion))) ;
  return ;
end

vl_xmkdir(opts.cacheDir) ;
diary(opts.diaryPath) ; diary on ;
disp('options:' ); disp(opts) ;

% --------------------------------------------------------------------
%                                                   Get image database
% --------------------------------------------------------------------

if exist(opts.imdbPath)
  imdb = load(opts.imdbPath);
else
 switch opts.dataset
   case 'scene15', imdb = setupScene15(opts.datasetDir, 'lite', opts.lite, ...
                                             'variant', 'scene15', 'seed', opts.seed);
   case 'scene67', imdb = setupScene67(opts.datasetDir, 'lite', opts.lite,  'seed', opts.seed) ;
   case 'caltech101', imdb = setupCaltech256(opts.datasetDir, 'lite', opts.lite, ...
                                             'variant', 'caltech101', 'seed', opts.seed) ;
   case 'caltech256', imdb = setupCaltech256(opts.datasetDir, 'lite', opts.lite, 'seed', opts.seed) ;
   case 'voc07', imdb = setupVoc(opts.datasetDir, 'lite', opts.lite, 'edition', '2007', 'seed', opts.seed) ;
   case 'fmd', imdb = setupFMD(opts.datasetDir, 'lite', opts.lite,...
           'seed', opts.seed, 'usepreprocessfeature',opts.usepreprocessfeature,...
           'savefeature', opts.savefeature,...
           opts.encoderParams{:} ,'imagedateDir',opts.imagedateDir) ;
           opts.setupdata=@(x)setupFMD(x);
   otherwise, error('Unknown dataset type.') ;
 end
 save(opts.imdbPath, '-struct', 'imdb') ;
end

% --------------------------------------------------------------------
%                                      Train encoder and encode images
% --------------------------------------------------------------------

fprintf('****************************************************************\n');
fprintf('Generating the code book... \n');
fprintf('****************************************************************\n');
start_time = round(clock);

  if(opts.usepreprocessfeature)
      pathdir=imdb.imagedataDir;
  else
      pathdir=imdb.imageDir;
  end

if exist(opts.encoderPath)
  encoder = load(opts.encoderPath) ;
else
  numTrain = 5000 ;
  if opts.lite, numTrain = 10 ; end
  train = vl_colsubset(find(imdb.images.set <= 2), numTrain, 'uniform') ;
  

  encoder = trainEncoder(fullfile(pathdir,imdb.images.name(train)), ...
                         opts.encoderParams{:}, ...
                         'lite', opts.lite, 'seed', opts.seed,...
                         'usepreprocessfeature',opts.usepreprocessfeature) ;
%   save(opts.encoderPath, '-struct', 'encoder') ;
  save(opts.encoderPath, '-struct', 'encoder','-v7.3') ;
  diary off ;
  diary on ;
end
end_time = round(clock);
elapsed_time = end_time - start_time;
fprintf('Time taken: %5d days %5d hours %5d minutes %5d seconds\n\n',...
    elapsed_time(3), elapsed_time(4), elapsed_time(5), elapsed_time(6));

fprintf('****************************************************************\n');
fprintf('Encoding the images... \n');
fprintf('****************************************************************\n');
start_time = round(clock);

descrs = encodeImage(encoder, fullfile(pathdir, imdb.images.name), ...
 'usepreprocessfeature',opts.usepreprocessfeature, 'cacheDir', opts.cacheDir, opts.encoderParams{:}) ;

end_time = round(clock);
elapsed_time = end_time - start_time;
fprintf('Time taken: %5d days %5d hours %5d minutes %5d seconds\n\n', elapsed_time(3), elapsed_time(4), elapsed_time(5), elapsed_time(6));



diary off ;
diary on ;

% --------------------------------------------------------------------
%                                            Train and evaluate models
% --------------------------------------------------------------------
fprintf('****************************************************************\n');
fprintf('Runing svm classification... \n');
fprintf('****************************************************************\n');
start_time = round(clock);

if isfield(imdb.images, 'class')
  classRange = unique(imdb.images.class) ;
else
  classRange = 1:numel(imdb.classes.imageIds) ;
end
numClasses = numel(classRange) ;


% apply kernel maps
switch opts.kernel
%switch 'chi2'
  case 'linear'
  case 'hell'
    descrs = sign(descrs) .* sqrt(abs(descrs)) ;
  case 'chi2'
    descrs = vl_homkermap(descrs,1,'kchi2') ;
  otherwise
    assert(false) ;
end
descrs = bsxfun(@times, descrs, 1./sqrt(sum(descrs.^2))) ;

% train and test
iter_num = 5;
accuracies = zeros(iter_num, 1);


for iter = 1:iter_num
    imdb = opts.setupdata(opts.datasetDir) ;
    train = find(imdb.images.set <= 2) ;
    test = find(imdb.images.set == 3) ;
    lambda = 1 / (opts.C*numel(train)) ;
    par = {'Solver', 'sdca', 'Verbose', ...
           'BiasMultiplier', 1, ...
           'Epsilon', 0.001, ...
           'MaxNumIterations', 100 * numel(train)} ;

    scores = cell(1, numel(classRange)) ;
    ap = zeros(1, numel(classRange)) ;
    ap11 = zeros(1, numel(classRange)) ;
    w = cell(1, numel(classRange)) ;
    b = cell(1, numel(classRange)) ;
    for c = 1:numel(classRange)
     if isfield(imdb.images, 'class')
        y = 2 * (imdb.images.class == classRange(c)) - 1 ;
     else
        y = - ones(1, numel(imdb.images.id)) ;
        [~,loc] = ismember(imdb.classes.imageIds{classRange(c)}, imdb.images.id) ;
        y(loc) = 1 - imdb.classes.difficult{classRange(c)} ;
     end
      if all(y <= 0), continue ; end

    [w{c},b{c}] = vl_svmtrain(descrs(:,train), y(train), lambda, par{:}) ;
    scores{c} = w{c}' * descrs + b{c} ;

     [~,~,info] = vl_pr(y(test), scores{c}(test)) ;
     ap(c) = info.ap ;
      ap11(c) = info.ap_interp_11 ;
     fprintf('class %s AP %.2f; AP 11 %.2f\n', imdb.meta.classes{classRange(c)}, ...
          ap(c) * 100, ap11(c)*100) ;
    end
    scores = cat(1,scores{:}) ;

    diary off ;
    diary on ;

    % confusion matrix (can be computed only if each image has only one label)
    if isfield(imdb.images, 'class')
      [~,preds] = max(scores, [], 1) ;
      confusion = zeros(numClasses) ;
      for c = 1:numClasses
        sel = find(imdb.images.class == classRange(c) & imdb.images.set == 3) ;
        tmp = accumarray(preds(sel)', 1, [numClasses 1]) ;
        tmp = tmp / max(sum(tmp),1e-10) ;
        confusion(c,:) = tmp(:)' ;
      end
    else
     confusion = NaN ;
    end

    % save results
%     save(opts.modelPath, 'w', 'b') ;
%     save(fullfile(opts.resultDir,'result.mat'), ...
%          'scores', 'ap', 'ap11', 'confusion', 'classRange', 'opts') ;

    % figures
    meanAccuracy = sprintf('mean accuracy: %f\n', mean(diag(confusion)));
    accuracies(iter) = mean(diag(confusion));
    mAP = sprintf('mAP: %.4f %%; mAP 11: %.4f', mean(ap) * 100, mean(ap11) * 100) ;

%     figure(1) ; clf ;
%     imagesc(confusion) ; axis square ;
%     title([opts.prefix ' - ' meanAccuracy]) ;
%     vl_printsize(1) ;
%     print('-dpdf', fullfile(opts.resultDir, 'result-confusion.pdf')) ;
%     print('-djpeg', fullfile(opts.resultDir, 'result-confusion.jpg')) ;
% 
%     figure(2) ; clf ; bar(ap * 100) ;
%     title([opts.prefix ' - ' mAP]) ;
%     ylabel('AP %%') ; xlabel('class') ;
%     grid on ;
%     vl_printsize(1) ;
%     ylim([0 100]) ;
%     print('-dpdf', fullfile(opts.resultDir,'result-ap.pdf')) ;

    fprintf('traintest: Iteration %2d  accuracy: %5.2f\n', iter,  accuracies(iter));
%     disp(meanAccuracy) ;
%     disp(mAP) ;

end

end_time = round(clock);
elapsed_time = end_time - start_time;
fprintf('Time taken: %5d days %5d hours %5d minutes %5d seconds\n\n', ...
    elapsed_time(3), elapsed_time(4), elapsed_time(5), elapsed_time(6));

accuracies
fprintf('Average accuracy over %d times: mean+std %5.4f+%3.4f\n', iter_num,...
    mean(accuracies), std(accuracies));  

total_end_time = round(clock);
fprintf('Total time of the classification program is:\n');
disp(total_start_time);
disp(total_end_time);
diary off ;


end
