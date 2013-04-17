function preprocess_data(imbase, resbase, annobase, dataset, files, useoldver)
if (nargin < 6)
    useoldver = 0;
end

if(useoldver)
    disp('use old version of object hypotheses');
end

addPaths
addVarshaPaths

params = initparam(3, 7);

load(fullfile(fullfile(resbase, 'layouts'), ['res_layout_' dataset '.mat']));
load(fullfile(fullfile(resbase, 'scene'), ['res_scene_' dataset '.mat']));

initrand();
%%
dirname = fullfile(resbase, dataset);

mkdir(dirname);

detbase = fullfile(resbase, 'detections');

csize = 16;
matlabpool open
for idx = 1:csize:length(files)
    setsize = min(length(files) - idx + 1, csize);
    
    data = struct(  'x', cell(setsize, 1), 'anno', cell(setsize, 1), ...
                'iclusters',  cell(setsize, 1), 'gpg',  cell(setsize, 1));
            
    imfiles2 = files(idx:idx+setsize-1);
    boxlayout2 = boxlayout(idx:idx+setsize-1);
    vpdata2 = vpdata(idx:idx+setsize-1);
    models = params.model;
    
    parfor i = 1:setsize 
        % get 3D model from detection and build ground truth graphs
        try
            [path, name, ext] = fileparts(imfiles2{i});
            imfile = fullfile(imbase, imfiles2{i});
            annofile = [path '/' name '_labels.mat'];
            detfiles = {fullfile([detbase '/sofa/' path], name), ...
                        fullfile([detbase '/table/' path], name), ...
                        fullfile([detbase '/chair/' path], name), ...
                        fullfile([detbase '/bed/' path], name), ...
                        fullfile([detbase '/diningtable/' path], name), ...
                        fullfile([detbase '/sidetable/' path], name)};
            
            [data(i).x, data(i).anno] = readOneImageObservationData(imfile, detfiles, boxlayout2{i}, vpdata2{i}, fullfile(annobase, annofile), useoldver);
            data(i).iclusters = clusterInteractionTemplates(data(i).x, models);
            data(i).gpg = getGTparsegraph(data(i).x, data(i).iclusters, data(i).anno, models);
        catch em
            em
            em.stack(1)
            em.stack(2)
            em.stack(end)
            disp(['error in ' num2str(idx+i-1) ' !! ']);
        end
    end
    fprintf([num2str((idx + csize - 1)/length(files), '%.03f') '% ']);    
    for i = 1:setsize
        temp = data(i);
        temp.x.sconf = sconfs(:, idx + i - 1);
        save([dirname '/data' num2str(idx+i-1, '%03d')], '-struct', 'temp');
    end
end
matlabpool close

end
