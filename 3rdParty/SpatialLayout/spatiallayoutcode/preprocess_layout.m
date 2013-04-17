function preprocess_layout(imgbase, resbase, files, postfix)

% Add local code directories to Matlab path
addpaths

%% prep directories
paths = cell(length(files), 1);
for i = 1:length(files)
    paths{i} = fileparts(files{i}); 
end
paths = unique(paths);

for i = 1:length(paths)
    dataset = paths{i};
    
    orgdir = fullfile(imgbase, dataset);
    imdir = [resbase '/resized/' dataset];
    if ~exist(imdir,'dir')
        mkdir(imdir);
    end
    
    workspcdir= fullfile(resbase, ['/temp/' dataset]);
    if ~exist(workspcdir,'dir')
        mkdir(workspcdir);
    end
    
    resdir = fullfile(resbase, dataset);
    if ~exist(resdir,'dir')
        mkdir(resdir);
    end
end
%% image resize all
for i = 1:length(files)
    imdir = [resbase '/resized/'];
    destfile = fullfile(imdir, files{i});
    if(exist(destfile, 'file'))
        continue;
    end
    img = imread(fullfile(imgbase, files{i}));
    if(size(img, 2) > 640)
        resizefactor = 640 / size(img, 2);
        img = imresize(img, resizefactor);
    end
    imwrite(img, destfile, 'JPEG');
end
%% process all images!
try
   matlabpool open 
end

fcnt = length(files);

boxlayout = cell(fcnt, 1);
surface_labels = cell(fcnt, 1);
resizefactor = cell(fcnt, 1);
fnames = cell(fcnt, 1);
parfor i = 1:length(files)
    [dataset, filename, ext] = fileparts(files{i}); 
    workspcdir = fullfile(resbase, ['/temp/' dataset]);
    [ boxlayout{i}, surface_labels{i}, resizefactor{i}, vpdata{i}] = getspatiallayout([resbase '/resized/' dataset '/'], [filename ext], [workspcdir '/'], 0);
    fnames{i} = fullfile(imgbase, files{i});
end
save(fullfile(resbase, ['res_layout_' postfix '.mat']), 'boxlayout', 'surface_labels', 'resizefactor', 'vpdata', 'fnames');

matlabpool close

end