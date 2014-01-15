function [ datafiles ] = remove_image_class( datafiles, preprocess_dir )

keep_class = {'bedroom'};

remove_id = [];
for i = 1:length(datafiles)
    data = load(fullfile(preprocess_dir, datafiles(i).name));
    [path,filename,~] = fileparts(data.x.imfile);
    [~,classname,~] = fileparts(path);
    isremove = 1;
    for j = 1:length(keep_class)
        if strcmp(classname,keep_class{j})
            isremove = 0;
            break;
        end
    end
    if isremove
        remove_id = [remove_id i];
    end
    datafiles(i).fname = filename;
    datafiles(i).cname = classname;
end

datafiles(remove_id) = [];

end

