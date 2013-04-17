function model = pose_train(cls, n, subtype, note, augmented)

% model = pascal_train(cls, n, note)
% Train a model with 2*n components using the PASCAL dataset.
% note allows you to save a note with the trained model
% example: note = 'testing FRHOG (FRobnicated HOG)

% At every "checkpoint" in the training process we reset the 
% RNG's seed to a fixed value so that experimental results are 
% reproducible.
initrand();

if nargin < 3
  note = '';
  augmented = false;
end
addpath ~/codes/eccv_indoor/IndoorLayoutUnderstanding/common/

globals; 
[pos, neg] = pose_data(cls, augmented);
% split data by aspect ratio into n groups
[spos, index_pose] = pose_split(pos, n, subtype);

cachesize = 10*numel(pos);
maxneg = min(800, numel(pos));

try 
	matlabpool open 6
end

% train root filters using warped positives & random negatives
try
  load([cachedir cls '_root']);
catch
  initrand();
  for i = 1:numel(index_pose)
    % split data into two groups: left vs. right facing instances
    models{i} = initmodel(cls, spos{index_pose(i)}, note, 'N');
%     models{i} = train(cls, models{i}, spos{index_pose(i)}, neg, i, 1, 1, 1, ... % negiter
%                       cachesize, true, 0.7, false, ['root_' num2str(i)]);
    models{i} = train(cls, models{i}, spos{index_pose(i)}, neg(1:maxneg), i, 1, ...
						1, ... % iter
						5, ... % negiter
                      cachesize, true, 0.7, false, ['root_' num2str(i)]);
  end
  save([cachedir cls '_root'], 'models');
end

% merge models and train using hard negatives
try 
  load([cachedir cls '_mix']);
catch
  initrand();
  model = mergemodels(models);
  model = train(cls, model, pos, neg(1:maxneg), 0, 0, ...
                1, ...
                5, ...
                cachesize, true, 0.7, false, 'mix');
%   model = train(cls, model, pos, neg(1:maxneg), 0, 0, ...
%                 3, ...
%                 3, ...
%                 cachesize, true, 0.7, false, 'mix');
% 
%   model = train(cls, model, pos, neg, 0, 0, ...
%                 1, ...
%                 5, ...
%                 cachesize, true, 0.7, false, 'mix');
  save([cachedir cls '_mix'], 'model');
end

% return;

% add parts and update models using hard negatives.
try 
  load([cachedir cls '_parts']);
catch
  initrand();
	try 
	  load([cachedir cls '_parts_1']);
	catch
	  for i = 1:numel(index_pose)
		model = model_addparts(model, model.start, i, i, 8, [6 6]);
	  end
	  model = train(cls, model, pos, neg(1:maxneg), 0, 0, ...
					5, ...
					5, ...
					cachesize, true, 0.7, false, 'parts_1');
	  save([cachedir cls '_parts_1'], 'model');
	end

  model = train(cls, model, pos, neg, 0, 0, ...
                1, ...
                5, ...
                cachesize, true, 0.7, true, 'parts_2');
  save([cachedir cls '_parts'], 'model');
end

model.view_num = n;
model.index_pose = index_pose;
save([cachedir cls '_final'], 'model');
