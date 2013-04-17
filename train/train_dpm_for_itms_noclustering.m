function train_dpm_for_itms_noclustering(trainset, name, allimlists)
curpwd = pwd();
cache_dir = fullfile(curpwd, 'cache/dpm_noclusters/');
if ~exist(cache_dir, 'dir')
    mkdir(cache_dir);
end
cd ../Detector/dpm_detector/

initrand();
note = '';

n = 4;

globals; 
[pos, neg] = itm_data(trainset, name, cache_dir, allimlists);
% split data by aspect ratio into n groups
spos = split(name, pos, n);

cachesize = 24000;
maxneg = max(200, min(1500, numel(pos)));

% train root filters using warped positives & random negatives
try
  load([cache_dir '/' name '_root']);
catch
  initrand();
  for i = 1:n
    % split data into two groups: left vs. right facing instances
    models{i} = initmodel(name, spos{i}, note, 'N');
    models{i} = train(name, models{i}, spos{i}, neg, i, 1, 1, 1, ...
                      cachesize, true, 0.7, false, ['root_' num2str(i)]);
  end
  save([cache_dir '/' name '_root'], 'models');
end

% merge models and train using hard negatives
try 
  load([cache_dir '/' name '_mix']);
catch
  initrand();
  model = mergemodels(models);
  model = train(name, model, pos, neg(1:maxneg), 0, 0, 4, 3, ...
                cachesize, true, 0.7, false, 'mix');
  save([cache_dir '/' name '_mix'], 'model');
end
% add parts and update models using hard negatives.
try 
  load([cache_dir cls '_parts']);
catch
  initrand();
  for i = 1:n % numel(index_pose)
    model = model_addparts(model, model.start, i, i, 8, [6 6]);
  end
  model = train(name, model, pos, neg(1:maxneg), 0, 0, 8, 10, ...
                cachesize, true, 0.7, false, 'parts_1');
  model = train(name, model, pos, neg, 0, 0, 1, 5, ...
                cachesize, true, 0.7, true, 'parts_2');
  save([cache_dir cls '_parts'], 'model');
end
% 
% model.index_pose = index_pose;
save([cache_dir cls '_final'], 'model');

cd(curpwd);

end


function [pos, neg] = itm_data(set, name, cache_dir, allimlist)
% Get training data from the PASCAL dataset.
globals;
VOC2006 = false;
pascal_init;

try
  load([cache_dir '/' name '_train_pos_set']);
catch
  % positive examples from train+val
  pos = parse_data(set.pos);
  save([cache_dir '/' name '_train_pos_set'], 'pos');
end

try
  load([cache_dir '/' name '_train_neg_set']);
catch
  % negative examples from train (this seems enough!)
  neg = [];
  numneg = 0;
  
  removelist = [];
  for i = 1:length(set.pos.itm_examples)
      [bin, idx] = inlist(allimlist, set.pos.itm_examples(i).imfile);
      if bin
          removelist(end+1) = idx;
      end
  end
  
  removelist = unique(removelist);
  allimlist(removelist) = [];
  
  for i = 1:length(allimlist)
      numneg = numneg+1;
      neg(numneg).im = allimlist{i};
      neg(numneg).flip = false;
  end
  
  ids = textread(sprintf(VOCopts.imgsetpath, 'trainval'), '%s');
  for i = 1:length(ids);
    if(mod(i, 50) == 0)
        fprintf('%s: parsing negatives: %d/%d\n', name, i, length(ids));
    end
    rec = PASreadrecord(sprintf(VOCopts.annopath, ids{i}));
    
    buse = true;
    for j = 1:length(set.objnames)
        % be careful about person...
        clsinds = strmatch(set.objnames{j}, {rec.objects(:).class}, 'exact');
        if ~isempty(clsinds)
            buse = false;
        end
    end
    
    if buse
      numneg = numneg+1;
      neg(numneg).im = [VOCopts.datadir rec.imgname];
      neg(numneg).flip = false;
    end
  end
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