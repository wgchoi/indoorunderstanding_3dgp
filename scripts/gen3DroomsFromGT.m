clear
close all;

addPaths();
addVarshaPaths();

set = 'livingroom';
img_dir= fullfile('../Data_Collection', set);
gt_dir = fullfile('../Annotation', set);
outdir = fullfile('./data/rooms2', set);

if(~exist(outdir, 'dir'))
    mkdir(outdir);
end
%% i = 8 error!!!
exts = {'jpg'};
for e = 1:length(exts)
	imfiles = dir(fullfile(img_dir, ['*.' exts{e}]));
	for i = 1:length(imfiles)
		fname = getfname(imfiles(i).name);
		img = imread(fullfile(img_dir, imfiles(i).name));
		try
			load(fullfile(gt_dir, [fname '_labels.mat']));
            [objs, poses] = get_oldtype_objects(obj_annos, objmodels());
            polyout = checkLayoutAnnotation(gtPolyg, img);
			[room, objs] = gen3DRoomFromGT(img, polyout, objs, poses);
			save(fullfile(outdir, fname), 'room', 'objs', 'polyout', 'gtPolyg');
            pause(1);
        catch ee
            i
            ee
		end
	end
end
%%
exts = {'jpg'};
for e = 1:length(exts)
	imfiles = dir(fullfile(img_dir, ['*.' exts{e}]));
	for i = 1:length(imfiles)
		fname = getfname(imfiles(i).name);
		img = imread(fullfile(img_dir, imfiles(i).name));
		try
            load(fullfile(outdir, fname), 'room', 'objs', 'gtPolyg');
            polyout = checkLayoutAnnotation(gtPolyg, img);
            drawAll(img, polyout, room, objs, objmodels(), 1, 2);
            pause;
        catch ee
            i
            ee
		end
	end
end