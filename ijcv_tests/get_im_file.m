function [imfile] = get_im_file(data)

if(~exist(data.x.imfile, 'file'))
    imgbase = 'dataset/cvpr13data/images/';
    
    [~, fname] = strtok(data.x.imfile, '/');
    [~, fname] = strtok(fname, '/');
    imfile = fullfile(imgbase, fname);
else
    imfile = data.x.imfile;
end
    
end