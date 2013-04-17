function [cid, minsize, assoc] = findCommonITMset(idset1, compset1, idset2, compset2)
N = length(compset1(1).chindices);
minsize = min(length(idset1), length(idset2));
if(length(compset1(1).chindices) ~= length(compset2(1).chindices))
    cid = [];
    assoc = zeros(0,0);
    return;
end
%
cid = zeros(1, minsize);
count = 1;
%
assoc = zeros(N, minsize);

freeidx1 = true(1, length(idset1));
freeidx2 = true(1, length(idset2));

for i = 1:length(idset1)
    for j = 1:length(idset2)
        if(freeidx1(i) && freeidx2(j) && idset1(i) == idset2(j))
            temp = intersect(compset1(i).chindices, compset2(j).chindices);
            
            if(length(temp) == N)
                cid(count) = i;
                for k = 1:N
                    assoc(k, count) = find(compset2(j).chindices == compset1(i).chindices(k), 1);
                end
                count = count + 1;
                
                freeidx1(i) = false;
                freeidx2(j) = false;
            end
        end
    end
end
cid(count:end) = [];
assoc(:, count:end) = [];

assert(length(cid) <= minsize);

end