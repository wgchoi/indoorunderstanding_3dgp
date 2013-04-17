% split positive training samples according to viewpoints
function [spos, index_pose] = pose_split(pos, n, subtype)

N = numel(pos);
view = zeros(N, 1);
type = zeros(N, 1);

for i = 1:N
    view(i) = find_interval(pos(i).azimuth, n);
    type(i) = pos(i).subid;
end

spos = cell(n * subtype, 1);
index_pose = [];

allset = false(1, N);
allview = zeros(1, n*subtype);
alltype = zeros(1, n*subtype);

for i = 1:n
    for j = 1:subtype
        idx = (j - 1) * n + i;
        
        allview(idx) = i;
        alltype(idx) = j;
        
        spos{idx} = pos(view == i & type == j);
        aspects(idx) = find_aspectratio(spos{idx});
        allset(view == i & type == j) = true;
    end
end

pos(allset) = [];
view(allset) = [];
type(allset) = [];

for i = 1:length(pos)
    h = pos(i).y2 - pos(i).y1 + 1;
    w = pos(i).x2 - pos(i).x1 + 1;
    
    ar = h / w;
    if(isnan(view(i)) && isnan(type(i)))
        [~, idx] = min(abs(aspects - ar));
        spos{idx}(end+1) = pos(i);
    elseif(isnan(view(i)))
        tidx = find(alltype == type(i));
        [~, idx] = min(abs(aspects(tidx) - ar));
        spos{tidx(idx)}(end+1) = pos(i);
    elseif(isnan(type(i)))
        vidx = find(allview == view(i));
        [~, idx] = min(abs(aspects(vidx) - ar));
        spos{vidx(idx)}(end+1) = pos(i);
    else
        keyboard;
    end
end

for idx = 1:length(spos)
    if numel(spos{idx}) >= 10
        index_pose = [index_pose idx];
    end
end


function aspect = find_aspectratio(pos)
h = [pos(:).y2]' - [pos(:).y1]' + 1;
w = [pos(:).x2]' - [pos(:).x1]' + 1;
xx = -2:.02:2;
filter = exp(-[-100:100].^2/400);
aspects = hist(log(h./w), xx);
aspects = convn(aspects, filter, 'same');
[peak, I] = max(aspects);
aspect = exp(xx(I));


function ind = find_interval(azimuth, num)
if(isnan(azimuth ))
    ind = nan;
    return;
end

if num == 8
    a = 22.5:45:337.5;
elseif num == 24
    a = 7.5:15:352.5;
end

for i = 1:numel(a)
    if azimuth < a(i)
        break;
    end
end
ind = i;
if azimuth > a(end)
    ind = 1;
end