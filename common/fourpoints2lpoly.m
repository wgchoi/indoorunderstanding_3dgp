function poly = fourpoints2lpoly(fpts, vp, imsz)
% vp
% 1 : vertical
% 2 : horizontal
% 3 : middle
poly = cell(1, 5);
isvisible = false(1, 5);
% default
isvisible(2) = true;
% top vertical      
if(all(~isnan(fpts(1, :))))
    isvisible(5) = true;
    l1 = [vp(2, :); fpts(1, :)];
else
    l1 = [1, 1; imsz(2), 1];
end
% bottom vertical
if(all(~isnan(fpts(2, :))))
    isvisible(1) = true;
    l2 = [vp(2, :); fpts(2, :)];
else
    l2 = [1, imsz(1); imsz(2), imsz(1)];
end

% left horizontal   
if(all(~isnan(fpts(3, :))))
    isvisible(4) = true;
    l3 = [vp(1, :); fpts(3, :)];
else
    l3 = [1, 1; 1, imsz(1)];
end
% right horizontal
if(all(~isnan(fpts(4, :))))
    isvisible(3) = true;
    l4 = [vp(1, :); fpts(4, :)];
else
    l4 = [imsz(2), 1; imsz(2), imsz(1)];
end

p_lt = lineintersection(l1(1, :), l1(2, :), l3(1, :), l3(2, :));
p_rt = lineintersection(l1(1, :), l1(2, :), l4(1, :), l4(2, :));
p_lb = lineintersection(l2(1, :), l2(2, :), l3(1, :), l3(2, :));
p_rb = lineintersection(l2(1, :), l2(2, :), l4(1, :), l4(2, :));


imX = [1, imsz(2), imsz(2), 1];
imY = [imsz(1), imsz(1), 1, 1];

ps = [p_lb; p_rb; p_rt; p_lt];

[X, Y] = polybool('intersection', ps(:, 1), ps(:, 2), imX, imY); 
poly{2} = [X(:), Y(:)];

if isvisible(1)
    if(isvisible(4))
        p1 = lineintersection(vp(3, :), p_lb, [0, imsz(1)], [imsz(2), imsz(1)]);
    else
        p1 = [1, imsz(1)];
    end
    if(isvisible(3))
        p2 = lineintersection(vp(3, :), p_rb, [0, imsz(1)], [imsz(2), imsz(1)]);
    else
        p2 = [imsz(2), imsz(1)];
    end
    ps = [p1; p2; p_rb; p_lb];
    [X, Y] = polybool('intersection', ps(:, 1), ps(:, 2), imX, imY); 
    poly{1} = [X(:), Y(:)];
end

if isvisible(3)
    if(isvisible(1))
        p1 = lineintersection(vp(3, :), p_rb, [imsz(2), 0], [imsz(2), imsz(1)]);
    else
        p1 = [imsz(2), imsz(1)];
    end
    
    if(isvisible(5))
        p2 = lineintersection(vp(3, :), p_rt, [imsz(2), 0], [imsz(2), imsz(1)]);
    else
        p2 = [imsz(2), 1];
    end
    
    ps = [p1; p2; p_rt; p_rb];
    [X, Y] = polybool('intersection', ps(:, 1), ps(:, 2), imX, imY); 
    poly{3} = [X(:), Y(:)];
end

if isvisible(4)
    if(isvisible(1))
        p1 = lineintersection(vp(3, :), p_lb, [0, 0], [0, imsz(1)]);
    else
        p1 = [1, imsz(1)];
    end
    
    if(isvisible(5))
        p2 = lineintersection(vp(3, :), p_lt, [0, 0], [0, imsz(1)]);
    else
        p2 = [1, 1];
    end
    
    ps = [p2; p1; p_lb; p_lt];
    [X, Y] = polybool('intersection', ps(:, 1), ps(:, 2), imX, imY); 
    poly{4} = [X(:), Y(:)];
end

if isvisible(5)
    if(isvisible(4))
        p1 = lineintersection(vp(3, :), p_lt, [1, 1], [imsz(2), 1]);
    else
        p1 = [1, 1];
    end
    if(isvisible(3))
        p2 = lineintersection(vp(3, :), p_rt, [1, 1], [imsz(2), 1]);
    else
        p2 = [imsz(2), 1];
    end

    ps = [p1; p_lt; p_rt; p2];
    [X, Y] = polybool('intersection', ps(:, 1), ps(:, 2), imX, imY); 
    poly{5} = [X(:), Y(:)];
end

end