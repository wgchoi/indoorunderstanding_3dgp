function preprocess_detector(basedir, resdir, files) 

if ~exist(basedir, 'dir')
    return;
end

load ./model/dpm/sofa_final.mat
detect_all( basedir, ...
                fullfile(resdir, 'sofa/'), files, ...
                {model}, {'sofa'}, -1.2);

load ./model/dpm/table_final.mat
detect_all( basedir, ...
                fullfile(resdir, 'table/'), files, ...
                {model}, {'table'}, -1.2)
            
load ./model/dpm/chair_final.mat
detect_all( basedir, ...
                fullfile(resdir, 'chair/'), files, ...
                {model}, {'chair'}, -1.2)
            
load ./model/dpm/bed_final.mat
detect_all( basedir, ...
                fullfile(resdir, 'bed/'), files, ...
                {model}, {'bed'}, -1.2)
            
load ./model/dpm/diningtable_final.mat
detect_all( basedir, ...
                fullfile(resdir, 'diningtable/'), files, ...
                {model}, {'diningtable'}, -1.2)
            
load ./model/dpm/sidetable_final.mat
detect_all( basedir, ...
                fullfile(resdir, 'sidetable/'), files, ...
                {model}, {'sidetable'},  -1.2)
            
end

function detect_all(basedir, resdir, files, models, names, threshold)

if ~exist(basedir, 'dir')
    return;
end

if ~exist(resdir, 'dir')
    mkdir(resdir);
end

try
    matlabpool open 4
end

parfor j = 1:length(files)
    imfile = fullfile(basedir, files{j});
    idx = find(files{j} == '.', 1, 'last');
    disp(['process ' files{j}]);
    detect_objs(imfile, models, names, threshold, 640, fullfile(resdir, files{j}(1:idx-1)));
end
matlabpool close;

end

function [bbox, top, dets, boxes, resizefactor] = detect_objs(imfile, models, names, threshold, maxwidth, resfile)
if nargin < 3
    threshold = -0.3;
    resfile = [];
elseif nargin < 4
    resfile = [];
end

if(exist([resfile '.mat'], 'file'))
    load(resfile, 'names', 'dets', 'boxes', 'top', 'bbox', 'resizefactor');
    return;
end

path = fileparts(resfile);
if(~exist(path, 'dir'))
    mkdir(path)
end

addpath ./3rdParty/dpm_detector

% we assume color images
im = imread(imfile);
resizefactor = 1;
if(size(im, 2) > maxwidth)
    resizefactor = maxwidth  / size(im, 2);
    im = imresize(im, resizefactor);
end
im = color(im);
% get the feature pyramid
% NOTE : assuming all the same feature pyramid
pyra = featpyramid(im, models{1});

bbox = cell(length(models), 1);
top = cell(length(models), 1);
dets = cell(length(models), 1);
boxes = cell(length(models), 1);

for i = 1:length(models)
    [dets{i}, boxes{i}, info] = gdetect(pyra, models{i}, threshold, [], 0);
    
    top{i} = nms(dets{i}, 0.5);
    % get bounding boxes
    if(isfield(models{i}, 'bboxpred'))
        bbox{i} = bboxpred_get(models{i}.bboxpred, dets{i}, reduceboxes(models{i}, boxes{i}));
    else
        bbox{i} = dets{i};
    end
    bbox{i} = clipboxes(im, bbox{i});
    top{i} = nms(bbox{i}, 0.5);
end

if(~isempty(resfile))
    save(resfile, 'names', 'dets', 'boxes', 'top', 'bbox', 'resizefactor');
end

rmpath ./3rdParty/dpm_detector

end