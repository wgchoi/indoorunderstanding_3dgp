function [idx] = getObjIndices(pg, iclusters)

childs = pg.childs;
idx = zeros(1000, 1);
cnt = 1;
for i = 1:length(childs)
    if(iclusters(childs(i)).isterminal)
        idx(cnt) = childs(i);
        cnt = cnt + 1;
    else
        temp = iclusters(childs(i)).chindices;
        idx(cnt:cnt+length(temp)-1) = temp;
        cnt = cnt + length(temp);
    end
end
idx(cnt:end) = [];

% no duplicate assignment allowed!!
assert(length(unique(idx)) == length(idx), 'no duplicate assignment allowed!!');

end