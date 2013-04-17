function [ dictionary ] = CalculateDictionary( imageFileList, imageBaseDir, dataBaseDir, featureSuffix, params, canSkip, pfig )
%function [ ] = CalculateDictionary( imageFileList, dataBaseDir, featureSuffix, params, canSkip )
%
%Create the texton dictionary
%
% First, all of the sift descriptors are loaded for a random set of images. The
% size of this set is determined by numTextonImages. Then k-means is run
% on all the descriptors to find N centers, where N is specified by
% dictionarySize.
%
% imageFileList: cell of file paths
% dataBaseDir: the base directory for the data files that are generated
%  by the algorithm. If this dir is the same as imageBaseDir the files
%  will be generated in the same location as the image files.
% featureSuffix: this is the suffix appended to the image file name to
%  denote the data file that contains the feature textons and coordinates. 
%  Its default value is '_sift.mat'.
% params.dictionarySize: size of descriptor dictionary (200 has been found to be
%  a good size)
% params.numTextonImages: number of images to be used to create the histogram
%  bins
% canSkip: if true the calculation will be skipped if the appropriate data 
%  file is found in dataBaseDir. This is very useful if you just want to
%  update some of the data or if you've added new images.

fprintf('Building Dictionary\n\n');

%% parameters

reduce_flag = 1;
ndata_max = 100000; %use 4% avalible memory if its greater than the default


if(~exist('params','var'))
    params.maxImageSize = 1000;
    params.gridSpacing = 8;
    params.patchSize = 16;
    params.dictionarySize = 200;
    params.numTextonImages = 50;
    params.pyramidLevels = 3;
end
if(~isfield(params,'maxImageSize'))
    params.maxImageSize = 1000;
end
if(~isfield(params,'gridSpacing'))
    params.gridSpacing = 8;
end
if(~isfield(params,'patchSize'))
    params.patchSize = 16;
end
if(~isfield(params,'dictionarySize'))
    params.dictionarySize = 200;
end
if(~isfield(params,'numTextonImages'))
    params.numTextonImages = 50;
end
if(~isfield(params,'pyramidLevels'))
    params.pyramidLevels = 3;
end
if(~exist('canSkip','var'))
    canSkip = 1;
end

if(params.numTextonImages > length(imageFileList))
    params.numTextonImages = length(imageFileList);
end

outFName = fullfile(dataBaseDir, sprintf('dictionary_%d.mat', params.dictionarySize));

if(exist(outFName,'file')~=0 && canSkip)
    fprintf('Dictionary file %s already exists.\n', outFName);
    return;
end
    

%% load file list and determine indices of training images

inFName = fullfile(dataBaseDir, 'f_order.txt');
if ~isempty(dir(inFName))
    R = load(inFName, '-ascii');
    if(size(R,2)~=length(imageFileList))
        R = randperm(length(imageFileList));
        sp_make_dir(inFName);
        save(inFName, 'R', '-ascii');
    end
else
    R = randperm(length(imageFileList));
    sp_make_dir(inFName);
    save(inFName, 'R', '-ascii');
end

training_indices = R(1:params.numTextonImages);

%% load all SIFT descriptors

sift_all = [];

if(exist('pfig','var'))
    tic;
end

for f = 1:params.numTextonImages    
    
    imageFName = imageFileList{training_indices(f)};
    [dirN base] = fileparts(imageFName);
    baseFName = fullfile(dirN, base);
    inFName = fullfile(dataBaseDir, sprintf('%s%s', baseFName, featureSuffix));
    if(exist(inFName,'file'))
        load(inFName, 'features');
    else
        features = sp_gen_sift(fullfile(imageBaseDir, imageFName),params);
    end
    ndata = size(features.data,1);

    data2add = features.data;
    if(size(data2add,1)>ndata_max/params.numTextonImages )
        p = randperm(size(data2add,1));
        data2add = data2add(p(1:floor(ndata_max/params.numTextonImages)),:);
    end
    sift_all = [sift_all; data2add];
    %fprintf('Loaded %s, %d descriptors, %d so far\n', inFName, ndata, size(sift_all,1));
    if(mod(f,10)==0 && exist('pfig','var'))
        sp_progress_bar(pfig,2,4,f,params.numTextonImages,'Computing Dictionary: ');
    end
end

fprintf('\nTotal descriptors loaded: %d\n', size(sift_all,1));

ndata = size(sift_all,1);    
if (reduce_flag > 0) & (ndata > ndata_max)
    fprintf('Reducing to %d descriptors\n', ndata_max);
    p = randperm(ndata);
    sift_all = sift_all(p(1:ndata_max),:);
end
        
%% perform clustering
options = zeros(1,14);
options(1) = 1; % display
options(2) = 1;
options(3) = 0.1; % precision
options(5) = 1; % initialization
options(14) = 100; % maximum iterations

centers = zeros(params.dictionarySize, size(sift_all,2));

%% run kmeans
fprintf('\nRunning k-means\n');
dictionary = sp_kmeans(centers, sift_all, options);
    
fprintf('Saving texton dictionary\n');
sp_make_dir(outFName);
save(outFName, 'dictionary');

end
