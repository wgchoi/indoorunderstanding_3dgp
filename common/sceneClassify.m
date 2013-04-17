function [x] = sceneClassify(x)

curpath = pwd();
cd('../SPMclassifer_Johnny/');

imfile = x.imfile;
idx = find(imfile =='/', 1, 'last');
imfile = fullfile(fullfile(imfile(1:idx-1), 'resized'), imfile(idx+1:end));

[~, prob] = SingleImageSPM(imfile);
x.sconf = prob([1 3 2]); 
% mapping... 1 bedroom, 2 diningroom, 3 livingroom
%           => 1 bedroom, 2 livingroom, 3 diningroom

cd(curpath);

end