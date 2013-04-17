function [diff] = compareITM(ptn1, ptn2, om)
if (nargin < 3)
    om = objmodels();
end

diff = recursiveDistance(ptn1.parts, ptn2.parts, om);
if(~isempty(ptn1.parts))
    diff = diff / length(ptn1.parts);
end

end

function [ mindiff ] = recursiveDistance(parts1, parts2, om)

if(length(parts1) ~= length(parts2))
    mindiff = inf;
    return;
end

if(isempty(parts1))
    mindiff = 0;
    return;
end

diff = inf(10, 1);
cnt = 1;

for i = 1:length(parts1)
    for j = 1:length(parts2)
        if(parts1(i).citype == parts2(j).citype)
            idx1 = true(1, length(parts1)); idx1(i) = false;
            idx2 = true(1, length(parts2)); idx2(j) = false;
            
            diff(cnt) = recursiveDistance(parts1(idx1), parts2(idx2), om);
            diff(cnt) = diff(cnt) + partdist(parts1(i), parts2(j), om);
            cnt = cnt + 1;
        end
    end
end

mindiff = min(diff);

end

function d = partdist(part1, part2, om)
d = ( (part1.dx - part2.dx) / 0.15 ) .^ 2 + ((part1.dz - part2.dz) / 0.15 ) .^ 2;
if(om(part1.citype).ori_sensitive)
    d = d + (anglediff(part1.da, part2.da) / 0.5) .^ 2 ;
end
end