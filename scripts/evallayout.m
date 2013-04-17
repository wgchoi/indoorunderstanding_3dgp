clear

rooms = {'bedroom' 'livingroom' 'diningroom'};

temp = [];
err = [];
wtf = [];

for i = 1:length(rooms)
    datadir = fullfile('traindata', rooms{i});
    datafiles = dir(fullfile(datadir, '*.mat'));
    for j = 1:length(datafiles)
        data = load(fullfile(datadir, datafiles(j).name));
        if isempty(data.x)
            wtf(:, end+1) = [i, j]';
            continue;
        end
        err(end+1) = getPixerr(data.anno.gtPolyg, data.x.lpolys(1, :));
        temp(:, end+1) = [i; j];
    end
end