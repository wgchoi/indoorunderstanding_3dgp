function [ pyramid_all ] = BuildPyramid( imageFileList, imageBaseDir, dataBaseDir, params, canSkip, saveSift )
%function [ pyramid_all ] = BuildPyramid( imageFileList, imageBaseDir, dataBaseDir, params, canSkip )
%
%Complete all steps necessary to build a spatial pyramid based
% on sift features.
%
% To build the pyramid this function first extracts the sift descriptors
%  for each image. It then calculates the centers of the bins for the
%  dictionary. Each sift descriptor is given a texton label corresponding
%  to the appropriate dictionary bin. Finally the spatial pyramid
%  is generated from these label lists.
%
%
% imageFileList: cell of file paths
% imageBaseDir: the base directory for the image files
% dataBaseDir: the base directory for the data files that are generated
%  by the algorithm. If this dir is the same as imageBaseDir the files
%  will be generated in the same location as the image files
% params.gridSpacing: the space between dense sift samples
% params.patchSize: the size of each patch for the sift descriptor
% params.maxImageSize: the max image size. If the image is larger it will be
%  resampeled.
% params.dictionarySize: size of descriptor dictionary (200 has been found to be a
%  good size)
% params.numTextonImages: number of images to be used to create the histogram bins
% params.pyramidLevels: number of levels of the pyramid to build
% canSkip: if true the calculation will be skipped if the appropriate data 
%  file is found in dataBaseDir. This is very useful if you just want to
%  update some of the data or if you've added new images.
% saveSift: this option pre-computes and saves the raw sift features. These
%  files can get quite large so you might want to turn this off
%
% Example:
% BuildPyramid(file_list, image_dir, data_dir);
%  Builds the spacial pyramid descriptor for all files in the file_list and
%  stores the data generated in data_dir. Dictionary size is set to 200,
%  50 texton images are used to build the historgram bins, 3 pyramid
%  levels are generated, and the image size has a maximum of 1000 pixels in
%  either the x or y direction.

%% parameters for feature extraction (see GenerateSiftDescriptors)

if(~exist('params','var'))
    params.maxImageSize = 1000
    params.gridSpacing = 8
    params.patchSize = 16
    params.dictionarySize = 200
    params.numTextonImages = 50
    params.pyramidLevels = 3
    params.oldSift = false;
end


if(~isfield(params,'maxImageSize'))
    params.maxImageSize = 1000
end
if(~isfield(params,'gridSpacing'))
    params.gridSpacing = 8
end
if(~isfield(params,'patchSize'))
    params.patchSize = 16
end
if(~isfield(params,'dictionarySize'))
    params.dictionarySize = 200
end
if(~isfield(params,'numTextonImages'))
    params.numTextonImages = 50
end
if(~isfield(params,'pyramidLevels'))
    params.pyramidLevels = 3
end
if(~isfield(params,'oldSift'))
    params.oldSift = false
end

if(~exist('canSkip','var'))
    canSkip = 1
end
if(~exist('saveSift','var'))
    saveSift = 1
end

pfig = sp_progress_bar('Building Spatial Pyramid');
%% build the pyramid
if(saveSift)
    GenerateSiftDescriptors( imageFileList,imageBaseDir,dataBaseDir,params,canSkip,pfig);
end
CalculateDictionary(imageFileList,imageBaseDir,dataBaseDir,'_sift.mat',params,canSkip,pfig);
BuildHistograms(imageFileList,imageBaseDir,dataBaseDir,'_sift.mat',params,canSkip,pfig);
pyramid_all = CompilePyramid(imageFileList,dataBaseDir,sprintf('_texton_ind_%d.mat',params.dictionarySize),params,canSkip,pfig);
close(pfig);
end
