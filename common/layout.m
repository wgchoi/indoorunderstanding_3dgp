function l = layout(boxlayout, imsz, R, K)
%%% Layout :    3 vps => R, K
%%%             list of polygons => Fs
%%%             score for each polygons
set = boxlayout.reestimated;

l = struct( 'poly', cell(size(set, 1), 1), ... 
            'F', cell(size(set, 1), 1), ...
            'score', cell(size(set, 1), 1));

for i = 1:size(set, 1)
    idx = set(i, 2);
    
    l(i).poly = boxlayout.polyg(idx, :);
    l(i).score = set(i, 1);
end

if nargin == 5
    for i = 1:size(set, 1)
        l(i).F = getRoomFaces(l(i).poly, imsz(1), imsz(2), K, R);
    end
end

end