function a
load('Untitled.mat');
load('Untitled2.mat');
load('Untitled3.mat');
im = imread(im) ;
it=getImageDescriptor(model,im);
a=it;
% -------------------------------------------------------------------------
function hist = getImageDescriptor(model, im)
% -------------------------------------------------------------------------

im = standarizeImage(im) ;
width = size(im,2) ;
height = size(im,1) ;

% get PHOW features
features=getDenseSIFT2(im);
descrs = features.descr;
descrs=single(descrs);
frames=features.frame;
% run pca
descrs=(descrs'*model.vocab.U(:,1:model.retain_dimensions))';

  hist=[];
for i = 1:length(model.numSpatialX)
  binsx = vl_binsearch(linspace(1,width,model.numSpatialX(i)+1), frames(1,:)) ;
  binsy = vl_binsearch(linspace(1,height,model.numSpatialY(i)+1), frames(2,:)) ;
  
  for it=1:length(descrs)
      itbin(it)=model.numSpatialX(i)*(binsy(it)-1)+binsx(it);
  end

  for it=1:model.numSpatialX(i)*model.numSpatialY(i)
      [row,col]=find(itbin==it);
      c=single(descrs);
      no=c(:,col);
      hist=[hist;vl_fisher(no, model.vocab.means, model.vocab.covariances, model.vocab.priors,'normalized')];
  end
end


% -------------------------------------------------------------------------
function im = standarizeImage(im)
% -------------------------------------------------------------------------
im = im2single(im) ;

scale = 1 ;
if (size(im,1) > 480)
  scale = 480 / size(im,1) ;
  im = imresize(im, scale) ;
  im = min(max(im,0),1) ;
end