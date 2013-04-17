function preprocess_human_data(imbase, resbase, annobase, dataset)

addPaths
addVarshaPaths
addpath ./experimental/

params = initparam(3, 7);

load(fullfile([resbase '/layout/' dataset], '/res_set_jpg.mat'));

imdir = fullfile(imbase, dataset);
imfiles = dir(fullfile(imdir, '*.jpg'));

detdir = fullfile([resbase '/detections/'], dataset);
detfiles = dir(fullfile([detdir '/sofa'], '*.mat'));

hmndir = fullfile([resbase '/poselet/converted/'], dataset);
% hmnfiles = dir(fullfile(hmndir, '*.mat'));

annodir = fullfile(annobase, dataset);
dirname = fullfile(fullfile(resbase, 'data.v2'), dataset);

mkdir(dirname);
csize = 16;

assert(length(imfiles) == length(detfiles));
% assert(length(imfiles) == length(hmnfiles));

params.posletmodel = load('./model/poselet_model');
addpath ../3rdParty/libsvm-3.12/

for idx = 1:csize:length(imfiles)
    setsize = min(length(imfiles) - idx + 1, csize);
    
    data = struct(  'x', cell(setsize, 1), 'anno', cell(setsize, 1), ...
                'iclusters',  cell(setsize, 1), 'gpg',  cell(setsize, 1));
            
    imfiles2 = imfiles(idx:idx+setsize-1);
    detfiles2 = detfiles(idx:idx+setsize-1);
    boxlayout2 = boxlayout(idx:idx+setsize-1);
    vpdata2 = vpdata(idx:idx+setsize-1);
    models = params.model;
    
%     for i = 1:setsize 
    parfor i = 1:setsize 
        try
            annofile = [imfiles2(i).name(1:find(imfiles2(i).name == '.', 1, 'last')-1) '_labels.mat'];
            [data(i).x, data(i).anno] = readOneImageObservationData(fullfile(imdir, imfiles2(i).name), ...
                                                    {fullfile([detdir '/sofa'], detfiles2(i).name), fullfile([detdir '/table'], detfiles2(i).name), fullfile([detdir '/chair'], detfiles2(i).name), [], fullfile([detdir '/diningtable'], detfiles2(i).name), []}, ...
                                                    boxlayout2{i}, vpdata2{i}, fullfile(annodir, annofile), 0);
            
            hmnfile = [imfiles2(i).name(1:find(imfiles2(i).name == '.', 1, 'last')-1) '.mat'];
            data(i).x = readHuamnObservationData(data(i).x.imfile, fullfile(hmndir, hmnfile), data(i).x); % , params.posletmodel);
            
            data(i).x = precomputeOverlapArea(data(i).x);
            % get human data as well..
            data(i).iclusters = clusterInteractionTemplates(data(i).x, models);
            data(i).gpg = get_GT_human_parsegraph(data(i).x, data(i).iclusters, data(i).anno, models);
        catch em
            em
            em.stack(1)
            em.stack(2)
            em.stack(end)
            disp(['error in ' num2str(idx+i-1) ' !! ']);
        end
    end
    disp('done');
    
    for i = 1:setsize
        temp = data(i);
        save([dirname '/data' num2str(idx+i-1, '%03d')], '-struct', 'temp');
    end
end
