function [in, idx] = inlist(list, string)
idx = -1;
for i = 1:length(list)
    if(strcmp(list{i}, string))
        in = true;
        idx = i;
        return
    end
end
in = false;

end