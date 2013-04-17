function [pos, neg] = pose_data(cls, augmented)

% [pos, neg] = pascal_data(cls)
% Get training data from the PASCAL dataset.

globals;
VOC2006 = false;
pascal_init;

augclass = '';

switch cls
    case {'car'}
        index_train = 1:240;
    case {'chair'}
        index_train = 1:770;
        index_train2 = 1:1102;
        
        augclass = 'chair';
    case {'bed'};
        index_train = 1:400;
        index_train2 = 1:846;
    case {'sofa'}
        index_train = 1:800;
        index_train2 = 1:874;
        
        augclass = 'sofa';
    case {'table'}
        index_train = 1:670;        
        index_train2 = 1:685;
        
        augclass = 'diningtable';
        
	case {'diningtable'}
        index_train = [];        
        index_train2 = 1:1185;
        augclass = 'diningtable';
        
    case {'sidetable'}
        index_train = [];        
        index_train2 = 1:739;
end

try
  load([cachedir cls '_train_pose']);
catch
  % positive examples from train+val
  fprintf('Read 3DObject samples\n');
%   if(augmented)
%     pos4 = read_positive_augmented_human(cls);
%     pos3 = read_pascal_positive(augclass);
%   end
%   pos = read_positive(cls, index_train);
%   pos2 = read_positive2(cls, index_train2);
  
  if(augmented)
      pos = read_positive_augmented_human(cls);
%       pos = [pos, pos2, pos3, pos4];
%       clear pos2 pos3 pos4;
  else
    pos = [pos, pos2];
    clear pos2;
  end
  
  % negative examples from train (this seems enough!)
  ids = textread(sprintf(VOCopts.imgsetpath, 'train'), '%s');
  neg = [];
  numneg = 0;
  for i = 1:min(1000, length(ids));
    if(mod(i, 50) == 0)
        fprintf('%s: parsing negatives: %d/%d\n', cls, i, length(ids));
    end
    rec = PASreadrecord(sprintf(VOCopts.annopath, ids{i}));
    clsinds = strmatch(cls, {rec.objects(:).class}, 'exact');
    if isempty(clsinds)
      numneg = numneg+1;
      neg(numneg).im = [VOCopts.datadir rec.imgname];
      neg(numneg).flip = false;
    end
  end
  
  if(augmented)
        % load('~/codes/eccv_indoor/IndoorLayoutUnderstanding/cvpr13data/human/datasetlist.mat', 'excludelist');
        load('~/codes/eccv_indoor/IndoorLayoutUnderstanding/cvpr13data/human/datasetlist.mat', 'totalfiles');
        excludelist = totalfiles;
        
        annobase = '~/codes/human_interaction/DataAnnotation/MainDataset/';

        objnames = {'sofa' 'table' 'tv' 'chair' 'diningtable' 'sidetable'};
        [in, oid] = inlist(objnames, cls);
        assert(in);

        for i = 1:length(excludelist)
            [dname, fname] = fileparts(excludelist{i});
            [~, dname] = fileparts(dname);
            annofile = fullfile(fullfile(annobase, dname), [fname '_labels']);
            anno = load(annofile);
            
            % no object
            if(length(anno.objs) < oid || isempty(anno.objs{oid}))
                numneg = numneg+1;
                neg(numneg).im = excludelist{i};
                neg(numneg).flip = false;
            end
        end
  end
  
  save([cachedir cls '_train_pose'], 'pos', 'neg');
end

function pos = read_pascal_positive(cls)

globals;
pascal_init;

% negative examples from train (this seems enough!)
[ids, gt] = textread(sprintf(VOCopts.imgsetpath, [cls '_trainval']), '%s %d');

pos= [];
numpos = 0;

for i = 1:length(ids);
    if(gt(i) <= 0)
        continue;
    end
    
    if(mod(i, 50) == 0)
        fprintf('%s: parsing positives: %d/%d\n', cls, i, length(ids));
    end
    
    rec = PASreadrecord(sprintf(VOCopts.annopath, ids{i}));

    for j = 1:length(rec.objects)
        if(strcmp(rec.objects(j).class, cls))
            numpos = numpos + 1;
            pos(numpos).im = [VOCopts.datadir rec.imgname];
            pos(numpos).x1 = rec.objects(j).bbox(1);
            pos(numpos).y1 = rec.objects(j).bbox(2);
            pos(numpos).x2 = rec.objects(j).bbox(1)+rec.objects(j).bbox(3);
            pos(numpos).y2 = rec.objects(j).bbox(2)+rec.objects(j).bbox(4);
            pos(numpos).flip = false;
            pos(numpos).trunc = 0;
            
            if(~isempty(rec.objects(j).view) && ~strcmp(rec.objects(j).view, ''))
                if(strcmp(rec.objects(j).view, 'Frontal'))
                    pos(numpos).azimuth = 0;
                elseif(strcmp(rec.objects(j).view, 'Left'))
                    pos(numpos).azimuth = 90;
                elseif(strcmp(rec.objects(j).view, 'Right'))
                    pos(numpos).azimuth = 270;
                elseif(strcmp(rec.objects(j).view, 'Rear'))
                    pos(numpos).azimuth = 180;
                else
                    keyboard;
                end
            else
                pos(numpos).azimuth = nan;
            end
            pos(numpos).mirrored = false;
            pos(numpos).subid = nan;
            
            numpos = numpos + 1;
            pos(numpos).im = [VOCopts.datadir rec.imgname];
            pos(numpos).x1 = rec.objects(j).bbox(1);
            pos(numpos).y1 = rec.objects(j).bbox(2);
            pos(numpos).x2 = rec.objects(j).bbox(1)+rec.objects(j).bbox(3);
            pos(numpos).y2 = rec.objects(j).bbox(2)+rec.objects(j).bbox(4);
            pos(numpos).flip = false;
            pos(numpos).trunc = 0;
            
            if(~isempty(rec.objects(j).view) && ~strcmp(rec.objects(j).view, ''))
                if(strcmp(rec.objects(j).view, 'Frontal'))
                    pos(numpos).azimuth = 0;
                elseif(strcmp(rec.objects(j).view, 'Left'))
                    pos(numpos).azimuth = 270;
                elseif(strcmp(rec.objects(j).view, 'Right'))
                    pos(numpos).azimuth = 90;
                elseif(strcmp(rec.objects(j).view, 'Rear'))
                    pos(numpos).azimuth = 180;
                else
                    keyboard;
                end
            else
                pos(numpos).azimuth = nan;
            end
            pos(numpos).mirrored = true;
            pos(numpos).subid = nan;
        end
    end
end

% read positive training images
function pos = read_positive(cls, index_train)

N = numel(index_train);
path_image = sprintf('../../Data_Collection/yuxiangdata/Images/%s', cls);
path_anno = sprintf('../../Data_Collection/yuxiangdata/Annotations/%s', cls);

pos = struct('im', {}, 'x1', {}, 'y1', {}, 'x2', {}, 'y2', {}, 'flip', {}, 'trunc', {}, 'azimuth', {}, 'mirrored', {}, 'subid', {});
count = 0;
for i = 1:N
    index = index_train(i);
    file_ann = sprintf('%s/%04d.mat', path_anno, index);
    image = load(file_ann);
    object = image.object;
    if isfield(object, 'view') == 0
        continue;
    end
    bbox = object.bbox;
    n = size(bbox, 1);
    if n ~= 1
        fprintf('Training image %d contains multiple instances.\n', i);
    end
    view = object.view;
    file_img = sprintf('%s/%s', path_image, object.image);
    for j = 1:n
        if view(j,1) == -1
            continue;
        end
        count = count + 1;
        pos(count).im = file_img;
        pos(count).x1 = bbox(j,1);
        pos(count).y1 = bbox(j,2);
        pos(count).x2 = bbox(j,1)+bbox(j,3);
        pos(count).y2 = bbox(j,2)+bbox(j,4);
        pos(count).flip = false;
        pos(count).trunc = 0;
        pos(count).azimuth = view(j,1);
        %%% wongun added %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pos(count).mirrored = false;
        pos(count).subid = nan;
        count = count + 1;
        pos(count).im = file_img;
        pos(count).x1 = bbox(j,1);
        pos(count).y1 = bbox(j,2);
        pos(count).x2 = bbox(j,1)+bbox(j,3);
        pos(count).y2 = bbox(j,2)+bbox(j,4);
        pos(count).flip = false;
        pos(count).trunc = 0;
        pos(count).azimuth = 360 - view(j,1);
        %%% wongun added
        pos(count).mirrored = true;
        pos(count).subid = nan;
        %%% wongun added %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

%%% wongun added
% read positive training images
function pos = read_positive2(cls, index_train)

N = numel(index_train);
path_image = sprintf('../../Data_Collection/objdata/images/');
path_anno = sprintf('../../Data_Collection/objdata/annotation/%s', cls);

count = 0;
for i = 1:N
    index = index_train(i);
    file_ann = sprintf('%s/annotation%05d.mat', path_anno, index);
    anno = load(file_ann);
    
    object = anno.anno;
    view = (object.azimuth) * 180 / pi;
    if view < 0
        view = view + 360;
    end
    
    count = count + 1;
    
%     imfile = object.im(find(object.im == '/', 1, 'last')+1:end);
    imfile = object.im;
    if(~isempty(find(imfile == '/', 1, 'last')))
        imfile = imfile(find(imfile == '/', 1, 'last')+1:end);
    end
    imfile = fullfile(path_image, imfile);
    
    pos(count).im = imfile;
    pos(count).x1 = object.x1;
    pos(count).y1 = object.y1;
    pos(count).x2 = object.x2;
    pos(count).y2 = object.y2;
    pos(count).flip = false;
    pos(count).trunc = 0;
    pos(count).azimuth = view;
    %%% wongun added %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pos(count).mirrored = false;
    pos(count).subid = object.subid;
    
    count = count + 1;
    pos(count).im = imfile;
    pos(count).x1 = object.x1;
    pos(count).y1 = object.y1;
    pos(count).x2 = object.x2;
    pos(count).y2 = object.y2;
    pos(count).flip = false;
    pos(count).trunc = 0;
    pos(count).azimuth = 360 - view;
    %%% wongun added
    pos(count).mirrored = true;
    pos(count).subid = object.subid;
    %%% wongun added %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if isfield(object, 'view') == 0
%         continue;
%     end
%     bbox = object.bbox;
%     n = size(bbox, 1);
%     if n ~= 1
%         fprintf('Training image %d contains multiple instances.\n', i);
%     end
%     view = object.view;
%     file_img = sprintf('%s/%s', path_image, object.image);
%     for j = 1:n
%         if view(j,1) == -1
%             continue;
%         end
%         count = count + 1;
%         pos(count).im = file_img;
%         pos(count).x1 = bbox(j,1);
%         pos(count).y1 = bbox(j,2);
%         pos(count).x2 = bbox(j,1)+bbox(j,3);
%         pos(count).y2 = bbox(j,2)+bbox(j,4);
%         pos(count).flip = false;
%         pos(count).trunc = 0;
%         pos(count).azimuth = view(j,1);
%         %%% wongun added %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         pos(count).mirrored = false;
%         count = count + 1;
%         pos(count).im = file_img;
%         pos(count).x1 = bbox(j,1);
%         pos(count).y1 = bbox(j,2);
%         pos(count).x2 = bbox(j,1)+bbox(j,3);
%         pos(count).y2 = bbox(j,2)+bbox(j,4);
%         pos(count).flip = false;
%         pos(count).trunc = 0;
%         pos(count).azimuth = 360 - view(j,1);
%         %%% wongun added
%         pos(count).mirrored = true;
%         %%% wongun added %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     end
end

function pos = read_positive_augmented_human(cls)

%load('~/codes/eccv_indoor/IndoorLayoutUnderstanding/cvpr13data/human/datasetlist.mat', 'excludelist');
% contaminated experiment!
load('~/codes/eccv_indoor/IndoorLayoutUnderstanding/cvpr13data/human/datasetlist.mat', 'totalfiles');
excludelist = totalfiles;

annobase = '~/codes/human_interaction/DataAnnotation/MainDataset/';

objnames = {'sofa' 'table' 'tv' 'chair' 'diningtable' 'sidetable'};
[in, oid] = inlist(objnames, cls);
assert(in);

count = 0;
for i = 1:length(excludelist)
    [dname, fname] = fileparts(excludelist{i});
    [~, dname] = fileparts(dname);
    annofile = fullfile(fullfile(annobase, dname), [fname '_labels']);
    anno = load(annofile);
    
	if(length(anno.objs) < oid)
		continue;
	end

    objs = anno.objs{oid};
    poses = anno.obj_poses{oid};
    
    for j = 1:length(objs)
        imfile = excludelist{i};
        
        view = poses(j).az * 180 / pi;
        if view < 0
            view = view + 360;
        end
        count = count + 1;
        pos(count).im = imfile;
        pos(count).x1 = objs(j).bbs(1);
        pos(count).y1 = objs(j).bbs(2);
        pos(count).x2 = objs(j).bbs(1) + objs(j).bbs(3) - 1;
        pos(count).y2 = objs(j).bbs(2) + objs(j).bbs(4) - 1;
        pos(count).flip = false;
        pos(count).trunc = 0;
        pos(count).azimuth = view;
        %%% wongun added %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pos(count).mirrored = false;
        pos(count).subid = poses(j).subid;

        count = count + 1;
        pos(count).im = imfile;
        pos(count).x1 = objs(j).bbs(1);
        pos(count).y1 = objs(j).bbs(2);
        pos(count).x2 = objs(j).bbs(1) + objs(j).bbs(3) - 1;
        pos(count).y2 = objs(j).bbs(2) + objs(j).bbs(4) - 1;
        pos(count).flip = false;
        pos(count).trunc = 0;
        pos(count).azimuth = 360 - view;
        %%% wongun added
        pos(count).mirrored = true;
        pos(count).subid = poses(j).subid;
        %%% wongun added %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

disp(['found ' num2str(count) ' examples from humandataset'])
