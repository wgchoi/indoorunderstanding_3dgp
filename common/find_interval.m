function ind = find_interval(azimuth, num)

if azimuth < 0
    azimuth = azimuth + 360;
end

assert(azimuth >= 0 && azimuth <= 360);

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
end