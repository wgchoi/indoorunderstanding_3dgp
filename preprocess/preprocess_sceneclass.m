function preprocess_sceneclass(basedir, resdir, postfix, files)

addpath(genpath('./3rdParty/SPM/'));
imdir = [resdir '/resized/'];

%% image resize all
for i = 1:length(files)
    destfile = fullfile(imdir, files{i});

    p = fileparts(destfile);
    if(~exist(p, 'dir'))
        mkdir(p);
    end
    
    if(exist(destfile, 'file'))
        continue;
    end
    img = imread(fullfile(basedir, files{i}));
    if(size(img, 2) > 640)
        resizefactor = 640 / size(img, 2);
        img = imresize(img, resizefactor);
    end
    imwrite(img, destfile, 'JPEG');
end
%%
sconfs = zeros(3, length(files));
matlabpool open 
parfor i = 1:length(files)
    [~, prob] = SingleImageSPM(fullfile(imdir, files{i}));
    sconfs(:, i)= prob([1 3 2]); 
end
matlabpool close
save(fullfile(resdir, ['res_scene_' postfix '.mat']), 'sconfs');

end