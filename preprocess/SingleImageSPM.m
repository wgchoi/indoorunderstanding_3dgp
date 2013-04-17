function [predict_label prob_estimates] = SingleImageSPM(PATHimage)
% Input
%   1. PATHimage:       path of the test image
%
% Output
%   1. predicted_label: 1 bedroom, 2 diningroom, 3 livingroom
%   2. prob_estimates:  probability estimates
%
% Notes
%   1. Be sure to use the resized images for classification. They are
%      in the following directories:
%
%       a. eccv_indoor/Data_Collection/bedroom/resized/
%       b. eccv_indoor/Data_Collection/livingroom/resized/
%       c. eccv_indoor/Data_Collection/diningroom/resized/
%
%   2. The classifier is trained using the following parameters:
%       a. Dictionary size: 400
%       b. Pyramid levels: 3

% addpath('./3rdParty/SPM/SpatialPyramid/');
% addpath('./3rdParty/SPM/libsvm-3.11/matlab/');

PATHdictionary = 'model/SPM/dictionary_400.mat';
PATHtrainingdata = 'model/SPM/training_data.mat';
PATHsvmmodel = 'model/SPM/libsvm_model.mat';

%% Set parameters
params.maxImageSize = 1000;
params.gridSpacing = 8;
params.patchSize = 16;
params.dictionarySize = 400;
params.numTextonImages = 50;
params.pyramidLevels = 3;
params.oldSift = false;

%% Generate SIFT discriptors
features = sp_gen_sift(PATHimage,params);

%% Load dictionary and build histograms
load(PATHdictionary,'dictionary');
ndata = size(features.data,1);

texton_ind.data = zeros(ndata,1);
texton_ind.x = features.x;
texton_ind.y = features.y;
texton_ind.wid = features.wid;
texton_ind.hgt = features.hgt;

batchSize = 100000;
if ndata <= batchSize
    dist_mat = sp_dist2(features.data, dictionary);
    [min_dist, min_ind] = min(dist_mat, [], 2);
    texton_ind.data = min_ind;
else
    for j = 1:batchSize:ndata
        lo = j;
        hi = min(j+batchSize-1,ndata);
        dist_mat = sp_dist2(features.data(lo:hi,:), dictionary);
        [min_dist, min_ind] = min(dist_mat, [], 2);
        texton_ind.data(lo:hi,:) = min_ind;
    end
end

%% Compile pyramid
binsHigh = 2^(params.pyramidLevels-1);

% get width and height of input image
wid = texton_ind.wid;
hgt = texton_ind.hgt;

% compute histogram at the finest level
pyramid_cell = cell(params.pyramidLevels,1);
pyramid_cell{1} = zeros(binsHigh, binsHigh, params.dictionarySize);

for i=1:binsHigh
    for j=1:binsHigh
        
        % find the coordinates of the current bin
        x_lo = floor(wid/binsHigh * (i-1));
        x_hi = floor(wid/binsHigh * i);
        y_lo = floor(hgt/binsHigh * (j-1));
        y_hi = floor(hgt/binsHigh * j);
        
        texton_patch = texton_ind.data( (texton_ind.x > x_lo) & (texton_ind.x <= x_hi) & ...
            (texton_ind.y > y_lo) & (texton_ind.y <= y_hi));
        
        % make histogram of features in bin
        pyramid_cell{1}(i,j,:) = hist(texton_patch, 1:params.dictionarySize)./length(texton_ind.data);
    end
end

% compute histograms at the coarser levels
num_bins = binsHigh/2;
for l = 2:params.pyramidLevels
    pyramid_cell{l} = zeros(num_bins, num_bins, params.dictionarySize);
    for i=1:num_bins
        for j=1:num_bins
            pyramid_cell{l}(i,j,:) = ...
                pyramid_cell{l-1}(2*i-1,2*j-1,:) + pyramid_cell{l-1}(2*i,2*j-1,:) + ...
                pyramid_cell{l-1}(2*i-1,2*j,:) + pyramid_cell{l-1}(2*i,2*j,:);
        end
    end
    num_bins = num_bins/2;
end

% stack all the histograms with appropriate weights
pyramid = [];
for l = 1:params.pyramidLevels-1
    pyramid = [pyramid pyramid_cell{l}(:)' .* 2^(-l)];
end
pyramid = [pyramid pyramid_cell{params.pyramidLevels}(:)' .* 2^(1-params.pyramidLevels)];

%% Compute histogram intersection kernel
load(PATHtrainingdata);
Ktest = hist_isect(pyramid, DATAtrain);

%% Run classification
load(PATHsvmmodel);
LABELtest = 0;
SIZEtest = 1;
Ktest_svm = [(1:SIZEtest)', Ktest];
[predict_label, ~, prob_estimates] = svmpredict_ywchao(LABELtest, Ktest_svm, model,'-b 1');

end

