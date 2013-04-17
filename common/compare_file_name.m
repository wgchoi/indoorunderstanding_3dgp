function ret = compare_file_name(fname1, fname2)

idx1 = find(fname1 == '.', 1, 'last');
idx2 = find(fname2 == '.', 1, 'last');
ret = strcmp(fname1(1:idx1-1), fname2(1:idx2-1));

end