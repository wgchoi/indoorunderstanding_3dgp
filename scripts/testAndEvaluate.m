clear
close all;

testname = 'sofa';
set = 'livingroom';
%%
img_dir = fullfile('../Data_Collection', set);
resize_img_dir = fullfile(img_dir, 'resized');
datadir = fullfile('./data/rooms', set);
outdir = fullfile(fullfile('./tempdata/detection', set), testname);

if(~exist(outdir, 'dir'))
    mkdir(outdir);
end
%%
curdir = pwd;

cd ../Detector/
addPaths
detdir = './results/YuMethod/livingroom/';
detout = readAllYuDetections(resize_img_dir, detdir, {testname});

cd(curdir);
%%
addPaths();
addVarshaPaths();

datafiles = dir(fullfile(datadir, '*.mat'));
for i = 1:length(datafiles)
    fname = getfname(datafiles(i).name);
    data = load(fullfile(datadir, datafiles(i).name), 'room', 'objs', 'gtPolyg');
    
    idx = find_detidx(detout, datafiles(i).name);
    
    onedets = rawdets2dets(detout{idx}.dets{1}, 1, eightposes());
    
    dobjs = testGeometryInDetection(data.room, objmodels(), onedets);
    save(fullfile(outdir, fname), 'dobjs');
end