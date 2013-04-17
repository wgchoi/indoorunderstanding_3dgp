function fname = getfname(filename)
idx = find(filename == '.', 1, 'last');
fname = filename(1:idx-1);
end