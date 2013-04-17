function [feats, warped, responses] = featwarp(model, itm_examples)
% assumption: the model only has a single structure rule 
% of the form Q -> F.
addpath ./detector

numpos = length(itm_examples);
warped = fastwarppos(model, itm_examples);

fi = model.symbols(model.rules{model.start}.rhs).filter;
% fbl = model.filters(fi).blocklabel;
% obl = model.rules{model.start}.offset.blocklabel;
% width1 = ceil(model.filters(fi).size(2)/2);
% width2 = floor(model.filters(fi).size(2)/2);
pixels = model.filters(fi).size * model.sbin;
minsize = prod(pixels);

feats = cell(1, numpos);
for i = 1:numpos
  bbox = itm_examples(i).bbox;
  % skip small examples
  if (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1) < minsize
    continue
  end    
  % get example
  im = warped{i};
  feats{i} = features(im, model.sbin);
end

if(nargout == 3)
    % w = get_dpm_model(model);
    w = model.filters.w(:);
    responses = zeros(1, numpos);
    for i = 1:numpos
        if(isempty(feats{i}))
            responses(i) = nan;
        else
            responses(i) = dot(w, feats{i}(:));
        end
    end
end
rmpath ./detector

function warped = fastwarppos(model, pos)

% warped = warppos(name, model, pos)
% Warp positive examples to fit model dimensions.
% Used for training root filters from positive bounding boxes.

fi = model.symbols(model.rules{model.start}.rhs).filter;
fsize = model.filters(fi).size;
pixels = fsize * model.sbin;
%heights = [pos(:).y2]' - [pos(:).y1]' + 1;
%widths = [pos(:).x2]' - [pos(:).x1]' + 1;
numpos = length(pos);
warped = cell(numpos);
cropsize = (fsize+2) * model.sbin;
for i = 1:numpos
  % fprintf('%s: warp: %d/%d\n', model.class, i, numpos);
  im = imread2(pos(i));
  padx = model.sbin * (pos(i).bbox(3) - pos(i).bbox(1)) / pixels(2);
  pady = model.sbin * (pos(i).bbox(4) - pos(i).bbox(2)) / pixels(1);
  x1 = round(pos(i).bbox(1) - padx);
  x2 = round(pos(i).bbox(3) + padx);
  y1 = round(pos(i).bbox(2) - pady);
  y2 = round(pos(i).bbox(4) + pady);
  
  w = x2 - x1;
  h = y2 - y1;
  
  r1 = w / cropsize(2);
  r2 = h / cropsize(1);
  
  minratio = min(r1, r2);
  if(minratio > 2.0)
      minratio = minratio / 2.0;
      im = imresize(im, 1 / minratio);
      x1 = floor(x1 / minratio);
      y1 = floor(y1 / minratio);
      x2 = floor(x2 / minratio);
      y2 = floor(y2 / minratio);
  end
  window = subarray(im, y1, y2, x1, x2, 1);
  warped{i} = imresize(window, cropsize, 'bilinear');
end

function im = imread2(ex)

% Read a training example image.
%
% ex  an example returned by pascal_data.m

im = color(imread(ex.imfile));
if ex.flip
  im = im(:,end:-1:1,:);
end
