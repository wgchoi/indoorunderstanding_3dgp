clear

testname = 'sofa';
set = 'livingroom';
%%
img_dir = fullfile('../Data_Collection', set);
resize_img_dir = fullfile(img_dir, 'resized');
datadir = fullfile('./data/rooms', set);
outdir = fullfile(fullfile('./tempdata/detection', set), testname);
%%
addPaths();
addVarshaPaths();

datafiles = dir(fullfile(datadir, '*.mat'));
close all;

for i = 1:length(datafiles)
    fname = getfname(datafiles(i).name);
    try
        img = imread(fullfile(img_dir, [fname '.jpg']));
    catch ee
        img = imread(fullfile(img_dir, [fname '.JPEG']));
    end
    data1 = load(fullfile(datadir, datafiles(i).name), 'room', 'objs', 'gtPolyg');
    data2 = load(fullfile(outdir, fname), 'dobjs');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(1); clf;figure(2); clf;
    ShowGTPolyg(img, data1.gtPolyg, 1);
    drawCube(data1.room, data1.gtPolyg, 2);    
    drawObjects(data1.room, data1.objs(1), objmodels(), 2, 1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(11); clf; figure(12); clf;
    ShowGTPolyg(img, data1.gtPolyg, 11);
    drawCube(data1.room, data1.gtPolyg, 12);    
    objs = data2.dobjs;
    include_indices = false(1, length(objs));
    for j = 1:length(objs)
        include_indices(j) = ~(sum(sum(isnan(objs(j).cube))) > 0 || sum(objs(j).cube(3, :) < 0) == 0);
    end
    drawObjects(data1.room, {objs(include_indices)}, objmodels(), 12, 11);
    pause
%     close all
end