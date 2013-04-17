clear
addPaths
addVarshaPaths
addpath ../3rdParty/ssvmqp_uci/
addpath experimental/

resdir = 'cvpr13data/test';
cnt = 1; 
files = dir(fullfile(resdir, '*.mat'));
trainfiles = [];
for i = 1:length(files)
    data(cnt) = load(fullfile(resdir, files(i).name));
    if(isempty(data(cnt).x))
        i
    else
        cnt = cnt + 1;
    end
end
%%
noitm = load('./finalresults/room/res_noitm.mat');
itmres = load('./finalresults/room/res_itm.mat');

[~, idx] = sort(itmres.summary.layout.reest - itmres.summary.layout.baseline);
%%
temp = data(352);
temp.x.dets(:) = [];
temp.x.hobjs(:) = [];

%temp.anno.obj_annos(6).azimuth = pi/4;
params = initparam(3,7);
[gtx] = get_ground_truth_observations(temp.x, temp.anno);
temp.x.dets = gtx.dets;
temp.x.hobjs = gtx.hobjs;
temp.iclusters = clusterInteractionTemplates(temp.x, params.model);
temp.gpg = getGTparsegraph(temp.x, temp.iclusters, temp.anno, params.model);

temp.gpg.scenetype = 3;
close all
show2DGraph(temp.gpg, temp.x, temp.iclusters, 1);
show3DGraph(temp.gpg, temp.x, temp.iclusters, 2);
view(0, -179)
axis off
%%
load('finalresults/room/params_itm.mat')

for i = 1:length(paramsout.model.itmptns)
    visualizeITM(do_rectify_itmptn(paramsout.model.itmptns(i)));
    savefig(fullfile('figures/room/', ['gpmodel' num2str(i, '%03d')]), 'pdf');
end
%%
addpath ~/codes/plottingTools/savefig/;
figbase = 'figures/room/';
mkdir(figbase);
mkdir(fullfile(figbase, 'baseline'));
mkdir(fullfile(figbase, 'full'));
mkdir(fullfile(figbase, 'partial'));

fontsize = 25;

count = 0;
for i = idx
    count = count +1;
%     if(count > 100)
%         break;
%     end
    pg = itmres.res{i}.spg(1);
    pg.childs = [];
    pg.layoutidx = 1;
    [~, pg.scenetype] = max(data(i).x.sconf);
    
    info = imfinfo(data(i).x.imfile);
    pg.scenetype = -1;
    show2DGraph(pg, data(i).x, itmres.res{i}.clusters);
    str = [' Layout Accuracy: ' num2str(1-data(i).x.lerr(1), '%.02f') ' '];
    text(10, info.Height - 20, str, 'backgroundcolor', 'w', 'edgecolor', 'k', 'linewidth', 2, 'fontsize', fontsize);
    
    saveas(gcf, fullfile(fullfile(figbase, 'baseline'), ['ranked' num2str(count, '%03d')]), 'fig');
    saveas(gcf, fullfile(fullfile(figbase, 'baseline'), ['a_ranked' num2str(count, '%03d')]), 'png');
    savefig(fullfile(fullfile(figbase, 'baseline'), ['ranked' num2str(count, '%03d')]), 'pdf');

    a=getNMSgraph(itmres.res{i}.spg(2), data(i).x, itmres.res{i}.clusters, itmres.conf2{i});
    show2DGraph(a, data(i).x, itmres.res{i}.clusters);
    str = [' Layout Accuracy: ' num2str(1- data(i).x.lerr(itmres.res{i}.spg(2).layoutidx), '%.02f') ' '];
    text(10, info.Height - 20, str, 'backgroundcolor', 'w', 'edgecolor', 'k', 'linewidth', 2, 'fontsize', fontsize);
    
    saveas(gcf, fullfile(fullfile(figbase, 'full'), ['ranked' num2str(count, '%03d')]), 'fig');
    saveas(gcf, fullfile(fullfile(figbase, 'full'), ['a_ranked' num2str(count, '%03d')]), 'png');
    savefig(fullfile(fullfile(figbase, 'full'), ['ranked' num2str(count, '%03d')]), 'pdf');
    
    show2DGraph(noitm.res{i}.spg(2), data(i).x, noitm.res{i}.clusters, -1, true, noitm.conf2{i});
    str = [' Layout Accuracy: ' num2str(1-data(i).x.lerr(noitm.res{i}.spg(2).layoutidx), '%.02f') ' '];
    text(10, info.Height - 20, str, 'backgroundcolor', 'w', 'edgecolor', 'k', 'linewidth', 2, 'fontsize', fontsize);
    
    saveas(gcf, fullfile(fullfile(figbase, 'partial'), ['ranked' num2str(count, '%03d')]), 'fig');
    saveas(gcf, fullfile(fullfile(figbase, 'partial'), ['a_ranked' num2str(count, '%03d')]), 'png');
    savefig(fullfile(fullfile(figbase, 'partial'), ['ranked' num2str(count, '%03d')]), 'pdf');
    
    pause(1);
end
%%
i = 44; % idx(370);
mkdir(fullfile(figbase, '3D'));
a=getNMSgraph(itmres.res{i}.spg(2), data(i).x, itmres.res{i}.clusters, itmres.conf2{i});
a.scenetype = -1;
show2DGraph( a, data(i).x, itmres.res{i}.clusters, 1);
savefig(fullfile(fullfile(figbase, '3D'), ['image' num2str(i, '%03d')]), 'pdf');
show3DGraph( a, data(i).x, itmres.res{i}.clusters, 2);
view(0, -179)
axis off
savefig(fullfile(fullfile(figbase, '3D'), ['top' num2str(i, '%03d')]), 'pdf');
%%
om = objmodels();
for i = 1:length(itmres.summary.objdet)
    plot(itmres.summary.baseline_objdet(i).rec, itmres.summary.baseline_objdet(i).prec, 'r--', 'linewidth', 2);
    hold on;
    plot(noitm.summary.objdet(i).rec, noitm.summary.objdet(i).prec, 'g-.', 'linewidth', 2);
    plot(itmres.summary.objdet(i).rec, itmres.summary.objdet(i).prec, 'k', 'linewidth', 2);
    plot(itmres.summary2.objdet(i).rec, itmres.summary2.objdet(i).prec, 'b-.', 'linewidth', 2);
    hold off;
    h = title(om(i).name);
    set(h, 'fontsize', 30);
    grid on;
    axis([0 1 0 1]);
    h = gca;
    set(h, 'fontsize', 18);
    
    h = xlabel('recall');
    set(h, 'fontsize', 30);
    h = ylabel('precision');
    set(h, 'fontsize', 30);
    
%     h = legend({['DPM AP = ' num2str(itmres.summary.baseline_objdet(i).ap, '%.02f')], ...
%             ['NO-3DGP AP = ' num2str(noitm.summary.objdet(i).ap, '%.02f')], ...
%             ['3DGP-M1 AP = ' num2str(itmres.summary.objdet(i).ap, '%.02f')], ...
%             ['3DGP-M2 AP = ' num2str(itmres.summary2.objdet(i).ap, '%.02f')]}, ...
%             'Location', 'SouthWest', 'fontsize', 15);
    h = legend({'DPM', ...
            'NO-3DGP     ', ...
            '3DGP-M1     ', ...
            '3DGP-M2     .'}, ...
            'Location', 'SouthWest', 'fontsize', 20);
    % set(h, 'fontsize', 18);
    
    savefig(fullfile(figbase, [om(i).name '_2']), 'pdf')
    % saveas(gcf, fullfile(figbase, [om(i).name '_3']), 'pdf')
    savefig(fullfile(figbase, [om(i).name '_2']), 'png')
    pause(1)
end
%%
fprintf('Sofa & Table & Chair & Bed & Dining Table & Side Table & \n');

for i = 1:length(noitm.summary.baseline_objdet)
    fprintf('%.01f \\%% & ', noitm.summary.baseline_objdet(i).ap * 100);
end
fprintf('\n');

for i = 1:length(noitm.summary.objdet)
    fprintf('%.01f \\%% & ', noitm.summary.objdet(i).ap * 100);
end
fprintf('\n');

for i = 1:length(itmres.summary.objdet)
    fprintf('%.01f \\%% & ', itmres.summary.objdet(i).ap * 100);
end
fprintf('\n');
%%
base_err  = zeros(5, length(data));
nogp_err  = zeros(5, length(data));
gp_err  = zeros(5, length(data));
for i = 1:length(data)
    gpoly = data(i).anno.gtPolyg;
    baseline_poly = data(i).x.lpolys(1, :);
    base_err(:, i) = getWallerr_interun(gpoly,baseline_poly);
    
    nogp_poly = data(i).x.lpolys(noitm.res{i}.spg(2).layoutidx, :);
    nogp_err(:, i) = getWallerr_interun(gpoly,nogp_poly);
    gp_poly = data(i).x.lpolys(itmres.res{i}.spg(2).layoutidx, :);
    gp_err(:, i) = getWallerr_interun(gpoly,gp_poly);
end
%%
base_err(:, isnan(base_err(end, :))) = [];
gp_err(:, isnan(gp_err(end, :))) = [];
nogp_err(:, isnan(nogp_err(end, :))) = [];
%%
fprintf('Pixel Accuracy & Floor & Center & Right & Left & Ceiling & \n');

vals = 1 - mean(base_err, 2)';
fprintf('%.01f \\%% & ', (1-itmres.summary.layout.baseline_mean) * 100);
for i = 1:length(vals)
    fprintf('%.01f \\%% & ', vals(i) * 100);
end
fprintf('\n');


vals = 1 - mean(gp_err, 2)';
fprintf('%.01f \\%% & ', (1-noitm.summary.layout.reest_mean) * 100);
for i = 1:length(vals)
    fprintf('%.01f \\%% & ', vals(i) * 100);
end
fprintf('\n');

vals = 1 - mean(nogp_err, 2)';
fprintf('%.01f \\%% & ', (1-itmres.summary.layout.reest_mean) * 100);
for i = 1:length(vals)
    fprintf('%.01f \\%% & ', vals(i) * 100);
end
fprintf('\n');