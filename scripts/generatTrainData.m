function generatTrainData(roomname)
rootdir = 'finaldata';
params = initparam(3, 6);

load(['../Results/layout/' roomname '/res_set_jpg.mat']);

imdir = fullfile('../Data_Collection', roomname);
imfiles = dir(fullfile(imdir, '*.jpg'));

detdir = fullfile('../Detector/results/DPM_MINE_AUG/', roomname);
detfiles = dir(fullfile([detdir '/sofa'], '*.mat'));

annodir = fullfile('../Annotation', roomname);
%%
dirname = fullfile(rootdir, roomname);
if exist(dirname, 'dir')
    unix(['rm -rf ' dirname]);
end
mkdir(dirname);
csize = 16;
for idx = 1:csize:length(imfiles)
    setsize = min(length(imfiles) - idx + 1, csize);
    
    data = struct(  'x', cell(setsize, 1), 'anno', cell(setsize, 1), ...
                'iclusters',  cell(setsize, 1), 'gpg',  cell(setsize, 1));
            
    imfiles2 = imfiles(idx:idx+setsize-1);
    detfiles2 = detfiles(idx:idx+setsize-1);
    boxlayout2 = boxlayout(idx:idx+setsize-1);
    vpdata2 = vpdata(idx:idx+setsize-1);
    models = params.model;
    
    parfor i = 1:setsize 
        try
            annofile = [imfiles2(i).name(1:find(imfiles2(i).name == '.', 1, 'last')-1) '_labels.mat'];
            
            [data(i).x, data(i).anno] = readOneImageObservationData(fullfile(imdir, imfiles2(i).name), ...
                                                    {fullfile([detdir '/sofa'], detfiles2(i).name), ...
                                                    fullfile([detdir '/table'], detfiles2(i).name), ...
                                                    fullfile([detdir '/chair'], detfiles2(i).name), ...
                                                    fullfile([detdir '/bed'], detfiles2(i).name), ...
                                                    fullfile([detdir '/diningtable'], detfiles2(i).name), ...
                                                    fullfile([detdir '/sidetable'], detfiles2(i).name)}, ...
                                                    boxlayout2{i}, vpdata2{i}, fullfile(annodir, annofile));

            [data(i).iclusters] = clusterInteractionTemplates(data(i).x, models);
            data(i).gpg = getGTparsegraph(data(i).x, data(i).iclusters, data(i).anno, models);
        end
    end
    disp('done');
    
    for i = 1:setsize
        temp = data(i);
        save([dirname '/data' num2str(idx+i-1, '%03d')], '-struct', 'temp');
    end
end
