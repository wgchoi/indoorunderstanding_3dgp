clear
close all;

% error 5,6,7,8,11
img_dir= '../Data_Collection/livingroom/';
gt_dir = '../Annotation/livingroom/';
datadir= '../UIUC_Varsha/SpatialLayout/tempworkspace/data/';
outdir = './examples';

if(~exist(outdir, 'dir'))
    mkdir(outdir);
end

imfiles = dir(fullfile(img_dir, '*.jpg'));
for i = 1:48
    img = imread(fullfile(img_dir, imfiles(i).name));
    load(fullfile(gt_dir, [imfiles(i).name(1:end-4) '_labels.mat']));
    showOneExample(img, gtPolyg, objs, objtypes, fullfile(outdir, imfiles(i).name(1:end-4)));
%     pause
    close all;
end

% % load(fullfile(datadir, [imfiles(ind).name(1:end-4) '_layres.mat']));
% % vp = getVPfromGT(img, gtPolyg)
% % return;
% vp =[];
% if 0
% %     load(fullfile(datadir, [imfiles(ind).name(1:end-4) '_vp.mat']));
% %     vp = reshape(vp, 2, 3)';
% %     showVP(img, vp); 
% %     axis ij; axis equal;
%     rfactor = 1;
%     if(size(img, 2) > 640)
%         rfactor = 640 / size(img, 2);
%         img = imresize(img, rfactor);
%     end
%     vp = getVPfromGT(img, []);
%     vp = vp ./ rfactor;
%     
%     vp = order_vp(vp); % v, h, m
%     img = imresize(img, 1/rfactor);
%     [K, R]=calibrate_cam(vp, size(img, 1), size(img, 2));
%     [r, p, y]= dcm2angle(R, 'XYZ')
% else
%     vp = getVPfromGT(img, gtPolyg);
%     vp = order_vp(vp); % v, h, m
%     
%     [K, R]=calibrate_cam(vp, size(img, 1), size(img, 2));
%     [r, p, y]= dcm2angle(R, 'XYZ')
% end
% 
% ShowGTPolyg(img, gtPolyg, 10);
% [K, R, F] = get3Dcube(img, vp, gtPolyg);
% % K, R, F
% 
% objmodel = objmodels();
% drawCube(F, gtPolyg, K, R, objs, objmodel, 1.4);
