function [] = GenerateSiftDescriptors( imageFileList, imageBaseDir, dataBaseDir, params, canSkip, pfig )
%function [] = GenerateSiftDescriptors( imageFileList, imageBaseDir, dataBaseDir, maxImageSize, gridSpacing, patchSize, canSkip )
%
%Generate the dense grid of sift descriptors for each
% image
%
% imageFileList: cell of file paths
% imageBaseDir: the base directory for the image files
% dataBaseDir: the base directory for the data files that are generated
%  by the algorithm. If this dir is the same as imageBaseDir the files
%  will be generated in the same location as the image files
% maxImageSize: the max image size. If the image is larger it will be
%  resampeled.
% gridSpacing: the spacing for the grid to be used when generating the
%  sift descriptors
% patchSize: the patch size used for generating the sift descriptor
% canSkip: if true the calculation will be skipped if the appropriate data 
%  file is found in dataBaseDir. This is very useful if you just want to
%  update some of the data or if you've added new images.

fprintf('Building Sift Descriptors\n\n');

%% parameters

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
if(exist('pfig','var'))
    tic;
end

for f = 1:length(imageFileList)

    %% load image
    imageFName = imageFileList{f};
    [dirN base] = fileparts(imageFName);
    baseFName = [dirN filesep base];
    outFName = fullfile(dataBaseDir, sprintf('%s_sift.mat', baseFName));
    imageFName = fullfile(imageBaseDir, imageFName);
    
    if(mod(f,100)==0 && exist('pfig','var'))
        sp_progress_bar(pfig,1,4,f,length(imageFileList));
    end
    if(exist(outFName,'file')~=0 && canSkip)
        %fprintf('Skipping %s\n', imageFName);
        continue;
    end
    
    features = sp_gen_sift(imageFName,params);
    sp_progress_bar(pfig,1,4,f,length(imageFileList),'Generating Sift Descriptors:');
    
    sp_make_dir(outFName);
    save(outFName, 'features');
    

end % for

end % function
