% annos = {};
% xs = {};
% confs = {};
% xs2 = {};
% 
% for i = 1:length(data)
% 	annos{i} = data(i).anno;
% 	xs{i} = data(i).x;
% 	confs{i} = data(i).x.dets(:, end);
% end
%
erridx = [];
poseletbase = '~/codes/human_interaction/cache/poselet/converted/';

posletmodel = load('./model/poselet_model');

addpath ../3rdParty/libsvm-3.12/
for i = 1:length(data)
    [datadir, datafile] = fileparts(data(i).x.imfile);
    [~, datadir] = fileparts(datadir);
    poselet = load(fullfile(fullfile(poseletbase, datadir), datafile));
    
    features = get_poselet_feature(poselet);
    [labels, p] = classify_poselet(posletmodel.model, posletmodel.DATAtrain, features);
    poselet.pose_prob = p;
    
    try
        [locs, reprojs, heights, maxh] = get_human_iprojections(data(i).x.K, data(i).x.R, poselet);
        % [locs, reprojs, heights] = get_human_iprojections(data(i).x.imfile, data(i).x.K, data(i).x.R, data(i).gpg.camheight, objmodels(), poselet, 8);
    catch
        erridx(end+1) = i;
        continue;
    end

	x = data(i).x;
	x.dets(x.dets(:, 1) ~= 7, :) = [];
	for j = 1:size(x.dets, 1)
		x.dets(j, 4:7) = rect2bbox(reprojs(:, j)');
	end
	xs2{i} = x;
	confs2{i} = x.dets(:, end);
end
% 
% annos(erridx) = [];
% xs(erridx) = [];
% confs(erridx) = [];
% xs2(erridx) = [];
% confs2(erridx) = [];
% 
% figure(1);
% [rec, prec, ap]= evalDetection(annos, xs, confs, 7,1, 0, 1);
% drawnow
% figure(2);
% [rec, prec, ap]= evalDetection(annos, xs2, confs2, 7,1, 0, 1);
% drawnow