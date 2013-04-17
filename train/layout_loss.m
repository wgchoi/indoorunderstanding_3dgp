function loss = layout_loss(gtpoly, poly)
% Varsha's method 
loss = 0;
if(length(gtpoly) < 5)
    gtpoly(end+1:5) = {[]};
end

for i = [1 5]
    if(~isempty(gtpoly{i}) && ~isempty(poly{i}))
        loss = loss + onefaceloss(gtpoly{i}, poly{i});
    elseif(isempty(gtpoly{i}) && isempty(poly{i}))
        % no error
    else
        loss = loss + 1;
    end
end

fex = zeros(1, 3);
for i = 1:3
    fex(i) = ~isempty(gtpoly{i + 1});
end

if(sum(fex) == 2)
    % ambiguity
    temp1 = sidefacesloss(gtpoly(2:4), poly(2:4));

    % c => l , r => c
    polys = cell(1, 3);
    polys([3 1]) = gtpoly([2 3]);
    temp2 = sidefacesloss(polys, poly(2:4));
   
    % c => r , l => c
    polys = cell(1, 3);
    polys([2 1]) = gtpoly([2 4]);
    temp3 = sidefacesloss(polys, poly(2:4));
    
    loss = loss + min(min(temp1, temp2), temp3);
else
    loss = loss + sidefacesloss(gtpoly(2:4), poly(2:4));
end

end

function loss = sidefacesloss(gtfaces, faces)

loss = 0;
for i = 1:3
    if(~isempty(gtfaces{i}) && ~isempty(faces{i}))
        loss = loss + onefaceloss(gtfaces{i}, faces{i});
    elseif(isempty(gtfaces{i}) && isempty(faces{i}))
        % no error
    else
        loss = loss + 1;
    end
end

end

function loss = onefaceloss(gtface, face)

Ax = gtface(:, 1); Ay = gtface(:, 2);
[Ax, Ay] = poly2cw(Ax, Ay);

Bx = face(:, 1);    By = face(:, 2);
[Bx, By]  = poly2cw(Bx, By);

[x, y] = polybool('intersection', Ax, Ay, Bx, By);
x(isnan(x)) = []; y(isnan(y)) = [];

ia = polyarea(x, y);
ua = polyarea(Ax, Ay) + polyarea(Bx, By) - ia;

assert(~isnan(ia));
assert(~isnan(ua));

loss = ( 1 - ia / ua);

end

% 1. penalize the absence, defined below..
% for i = 1:5
%     loss = loss + sum(isempty(gtpoly{i})~=isempty(poly{i}));
% end
% 2. shift of the centroid - ambiguous
% for i = 1:5
%     [area,cx,cy] = polycenter(x,y,dim)
% end
% 3. 