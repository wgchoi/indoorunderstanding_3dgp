function [x] = sceneClassify_human(x)
curpath = pwd();
cd('../SPMclassifer_Johnny/');
imfile = x.imfile;
% idx = find(imfile =='/', 1, 'last');
% imfile = fullfile(fullfile(imfile(1:idx-1), 'resized'), imfile(idx+1:end));
[~, prob] = SingleImageSPM_human(imfile);
x.sconf = prob(:); 
%   1. predicted_label: 1 dancing, 2 having_dinner, 3 talking, 
%                       4 washing_dishes, 5 watching_tv
% 1. dancing, 2. having_dinner, 3. talking, 4. washing_dishes 5. watching_tv
cd(curpath);
end
