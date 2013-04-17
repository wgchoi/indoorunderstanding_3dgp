function [models, index_pose] = train_dpm_for_itms2(trainset, name, allimlists)
curpwd = pwd();
cache_dir = fullfile(curpwd, 'cache/dpm2/');
if ~exist(cache_dir, 'dir')
    mkdir(cache_dir);
end

% model = pascal_train(cls, n, note)
% Train a model with 2*n components using the PASCAL dataset.
% note allows you to save a note with the trained model
% example: note = 'testing FRHOG (FRobnicated HOG)
% At every "checkpoint" in the training process we reset the 
% RNG's seed to a fixed value so that experimental results are 
% reproducible.
initrand();
note = '';
[pos, neg, spos, index_pose] = itm_data(trainset, name, cache_dir);
% globals; 
if(isempty(index_pose))
    cd(curpwd);
    return;
end

cd ../Detector/dpm_detector/
cachesize = 10 * numel(pos);
% train root filters using warped positives & random negatives
try
  load([cache_dir '/' name '_root']);
catch
  initrand();
  
  for i = 1:numel(index_pose)
    models{i} = initmodel(name, spos{i}, note, 'N');
    models{i} = train_classifier(name, models{i}, spos{i}, neg, i, 0, ...
						1, ... % iter
						1, ... % negiter
                        cachesize, true, 0.7, false, ['root_' num2str(i)]);
  end
  
  save([cache_dir '/' name '_root'], 'models', 'index_pose');
end

cd(curpwd);

return;

% merge models and train using hard negatives
try 
  load([cache_dir '/' name '_mix']);
catch
  initrand();
  model = mergemodels(models);
  model = train(name, model, pos, neg(1:maxneg), 0, 0, ...
                1, ...
                5, ...
                cachesize, true, 0.7, false, 'mix');
            
  model = train(name, model, pos, neg, 0, 0, ...
                1, ...
                5, ...
                cachesize, true, 0.7, true, 'mix_2');
            
  save([cache_dir '/' name '_mix'], 'model', 'index_pose');
end

cd(curpwd);

end

function [pos, neg, spos, index_pose] = itm_data(set, name, cache_dir)
% Get training data from the PASCAL dataset.

try
  load([cache_dir '/' name '_train_pos_set']);
catch
  % positive examples from train+val
  pos = parse_data(set.pos);
  
  views = unique(set.pos.clusters);
  
  spos = cell(length(views), 1);
  index_pose = cell(length(views), 1);
  
  for v = 1:length(views);
      spos{v} = pos(views(v) == set.pos.clusters);
      index_pose{v} = set.pos.viewset{views(v)};
  end
  
  remove_idx = [];
  for v = 1:length(views);
      if(length(spos{v}) < 20)
          remove_idx(end+1) = v;
      end
  end
  spos(remove_idx) = [];
  index_pose(remove_idx) = [];
  
  save([cache_dir '/' name '_train_pos_set'], 'pos', 'spos', 'index_pose');
end

try
  load([cache_dir '/' name '_train_neg_set']);
catch
  % negative examples from train (this seems enough!)
  neg = parse_data(set.neg);
%   neg = [];
%   numneg = 0;
%   
%   removelist = [];
%   for i = 1:length(itm_examples)
%       [bin, idx] = inlist(allimlist, itm_examples(i).imfile);
%       if bin
%           removelist(end+1) = idx;
%       end
%   end
%   
%   removelist = unique(removelist);
%   allimlist(removelist) = [];
%   
%   for i = 1:length(allimlist)
%       numneg = numneg+1;
%       neg(numneg).im = allimlist{i};
%       neg(numneg).flip = false;
%   end
%   
%   ids = textread(sprintf(VOCopts.imgsetpath, 'train'), '%s');
%   for i = 1:length(ids);
%     if(mod(i, 50) == 0)
%         fprintf('%s: parsing negatives: %d/%d\n', name, i, length(ids));
%     end
%     rec = PASreadrecord(sprintf(VOCopts.annopath, ids{i}));
%     
%     % be careful about person...
%     clsinds = strmatch('person', {rec.objects(:).class}, 'exact');
%     if isempty(clsinds)
%       numneg = numneg+1;
%       neg(numneg).im = [VOCopts.datadir rec.imgname];
%       neg(numneg).flip = false;
%     end
%   end
  save([cache_dir '/' name '_train_neg_set'], 'neg');
end

end

% read positive training images
function pos = parse_data(set)
itm_examples = set.itm_examples;
if isfield(set, 'clusters')
    clusters = set.clusters;
else
    clusters = zeros(1, length(itm_examples));
end

assert(length(itm_examples) == length(clusters));

N = numel(itm_examples);
pos = struct('im', cell(N, 1), 'x1', 0, 'y1', 0, 'x2', 0, 'y2', 0, 'flip', 0, ...
            'trunc', 0, 'azimuth', 0, 'clusterid', 0, 'subid', 0);
        
for i = 1:N
    pos(i).im = itm_examples(i).imfile;
    pos(i).x1 = itm_examples(i).bbox(1);
    pos(i).y1 = itm_examples(i).bbox(2);
    pos(i).x2 = itm_examples(i).bbox(3);
    pos(i).y2 = itm_examples(i).bbox(4);
    pos(i).flip = itm_examples(i).flip;
    pos(i).trunc = 0;
    pos(i).azimuth = itm_examples(i).azimuth;
    pos(i).clusterid = clusters(i);
    pos(i).subid = 1;
end

end


% split positive training samples according to viewpoints
function [spos, index_pose, removeidx] = view_split(pos, n)
N = numel(pos);
view = zeros(N, 1);
for i = 1:N
    az = pos(i).azimuth / pi * 180;
    view(i) = find_interval(az, n);
end

spos = cell(n, 1);
index_pose = [];

removeidx = [];
maxperview = 150;
for i = 1:n
    idx = i;
    sets = find(view == i);
    
    if(length(sets) > maxperview)
        temp = randperm(length(sets));
        spos{idx} = pos(sets(temp(1:maxperview)));
        removeidx = [removeidx; sets(temp(maxperview+1:end))];
    else
        spos{idx} = pos(sets);
    end
    
    if numel(spos{idx}) >= 10
        index_pose = [index_pose idx];
    end
end

end

function [in, idx] = inlist(list, string)
idx = -1;
for i = 1:length(list)
    if(strcmp(list{i}, string))
        in = true;
        idx = i;
        return
    end
end
in = false;
end

function ind = find_interval(azimuth, num)

if azimuth < 0
    azimuth = azimuth + 360;
end

assert(azimuth >= 0 && azimuth <= 360);

if num == 8
    a = 22.5:45:337.5;
elseif num == 24
    a = 7.5:15:352.5;
end

for i = 1:numel(a)
    if azimuth < a(i)
        break;
    end
end
ind = i;
if azimuth > a(end)
    ind = 1;
end
end