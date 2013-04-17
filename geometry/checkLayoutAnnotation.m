function polyout = checkLayoutAnnotation(gtPolyg, imsz)
assert(length(imsz) == 2);

% bottom, center, right, left, top
for i = length(gtPolyg)+1:5
    gtPolyg{i} = [];
end

for i = 1:5
    %%%%% ther are some bug in the annotation
    if(size(gtPolyg{i}, 1) < 2)
        gtPolyg{i} = [];
    end
end

polyout = cell(1, 5);
% we only fix the error in center,right,left walls.
polyout{1} = gtPolyg{1};
if(length(gtPolyg) >= 5)
    polyout{5} = gtPolyg{5};
end

idx = [];
for i = 2:4
    if(~isempty(gtPolyg{i}))
        idx(end + 1) = i;
    end
end

if length(idx) == 3
    mx = zeros(3, 1);
    
    cnt = 1;
    for i = 1:length(idx)
        mx(cnt) = (max(gtPolyg{idx(i)}(1:end-1, 1)) ...
                    + min(gtPolyg{idx(i)}(1:end-1, 1))) / 2;
        cnt = cnt + 1;
    end
    [~, rid] = max(mx); rid = idx(rid);
    [~, lid] = min(mx); lid = idx(lid);
    cid = setdiff(idx, [lid rid]);
    assert(isempty(setdiff(idx, [lid rid cid])));
    
    polyout{2} = gtPolyg{cid};
    polyout{3} = gtPolyg{rid};
    polyout{4} = gtPolyg{lid};
    
elseif length(idx) == 2
    mx = zeros(2, 1);
    cnt = 1;
    for i = 1:length(idx)
        mx(cnt) = (max(gtPolyg{idx(i)}(1:end-1, 1)) ...
                    + min(gtPolyg{idx(i)}(1:end-1, 1))) / 2;
        cnt = cnt + 1;
    end
    [~, rid] = max(mx); rid = idx(rid);
    [~, lid] = min(mx); lid = idx(lid);
    assert(rid ~= lid);
    if(min( gtPolyg{rid}(:, 1) ) < imsz(2) / 2)
        % left, center
        polyout{2} = gtPolyg{rid};
        polyout{4} = gtPolyg{lid};
    else
        % center, right
        polyout{3} = gtPolyg{rid};
        polyout{2} = gtPolyg{lid};
    end
elseif length(idx) == 1
    polyout{2} = gtPolyg{idx};
else
%    assert(0);
end

% assertLayout(gtPolyg);
% assertLayout(polyout);

end

function assertLayout(poly)

mx = zeros(1, 5);
my = zeros(1, 5);

for i = 1:length(poly)
    if(~isempty(poly{i}))
        mx(i) = (max(poly{i}(1:end-1, 1)) ...
                    + min(poly{i}(1:end-1, 1))) / 2;

        my(i) = (max(poly{i}(1:end-1, 2)) ...
                    + min(poly{i}(1:end-1, 2))) / 2;
    end
end

% floor
if(~isempty(poly{1}))
    for i = 2:5
        if(~isempty(poly{i}))
            assert(my(i) < my(1));
        end
    end
end

% ceiling
if(~isempty(poly{5}))
    for i = 1:4
        if(~isempty(poly{i}))
            assert(my(i) > my(5));
        end
    end
end

% left
if(~isempty(poly{4}))
    for i = [2 3]
        if(~isempty(poly{i}))
            assert(mx(i) > mx(4));
        end
    end
end

% right
if(~isempty(poly{3}))
    for i = [2 4]
        if(~isempty(poly{i}))
            assert(mx(i) < mx(3));
        end
    end
end

% center
assert(~isempty(poly{2}));

end