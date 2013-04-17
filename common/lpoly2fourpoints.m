function fpts = lpoly2fourpoints(poly, imsz)
fpts  = nan(4, 2);
vline = imsz(2) / 2;
hline = imsz(1) / 2;

cwall = poly{2};
if(isempty(cwall))
    return;
end

numpoints = size(cwall, 1);

immargin = 5;


%% upper point intersecting vertical line
dist1 = (1 - cwall(:, 1)) .^2 + (1 - cwall(:, 2)) .^2; % left top of the image
[~, id1] = min(dist1);
dist2 = (imsz(2) - cwall(:, 1)) .^2 + (1 - cwall(:, 2)) .^2; % right top of the image
[~, id2] = min(dist2);

if (cwall(id1, 2) > immargin && cwall(id2, 2) > immargin)
    fpts(1, 1) = vline;
    % fpts(1, 2) = y1 + (y2-y1)/(x2-x1) * (vline - x1);
    fpts(1, 2) = cwall(id1, 2) + (cwall(id2, 2) - cwall(id1, 2))/(cwall(id2, 1) - cwall(id1, 1)) * (vline - cwall(id1, 1));
elseif (cwall(id1, 2) > immargin)
    %
    if(id1 == 1)
        if(dist2(2) < dist2(numpoints))
            id2 = 2;
        else
            id2 = numpoints;
        end
    elseif(id1 == numpoints)
        if(dist2(1) < dist2(id1 - 1))
            id2 = 1;
        else
            id2 = id1 - 1;
        end
    else
        if(dist2(id1 - 1) < dist2(id1 + 1))
            id2 = id1 - 1;
        else
            id2 = id1 + 1;
        end
    end
    
    fpts(1, 1) = vline;
    % fpts(1, 2) = y1 + (y2-y1)/(x2-x1) * (vline - x1);
    fpts(1, 2) = cwall(id1, 2) + (cwall(id2, 2) - cwall(id1, 2))/(cwall(id2, 1) - cwall(id1, 1)) * (vline - cwall(id1, 1));
elseif (cwall(id2, 2) > immargin)
    %
    if(id2 == 1)
        if(dist1(2) < dist1(numpoints))
            id1 = 2;
        else
            id1 = numpoints;
        end
    elseif(id2 == numpoints)
        if(dist1(1) < dist1(id2 - 1))
            id1 = 1;
        else
            id1 = id2 - 1;
        end
    else
        if(dist1(id2 - 1) < dist1(id2 + 1))
            id1 = id2 - 1;
        else
            id1 = id2 + 1;
        end
    end
    
    fpts(1, 1) = vline;
    % fpts(1, 2) = y1 + (y2-y1)/(x2-x1) * (vline - x1);
    fpts(1, 2) = cwall(id1, 2) + (cwall(id2, 2) - cwall(id1, 2))/(cwall(id2, 1) - cwall(id1, 1)) * (vline - cwall(id1, 1));
else
    % no upper intersection
end
%% lower point intersecting vertical line
dist1 = (1 - cwall(:, 1)) .^2 + (imsz(1) - cwall(:, 2)) .^2; % left bottom of the image
[~, id1] = min(dist1);
dist2 = (imsz(2) - cwall(:, 1)) .^2 + (imsz(1) - cwall(:, 2)) .^2; % right bottom of the image
[~, id2] = min(dist2);

if (cwall(id1, 2) < imsz(1) - immargin && cwall(id2, 2) < imsz(1) - immargin)
    fpts(2, 1) = vline;
    % fpts(1, 2) = y1 + (y2-y1)/(x2-x1) * (vline - x1);
    fpts(2, 2) = cwall(id1, 2) + (cwall(id2, 2) - cwall(id1, 2))/(cwall(id2, 1) - cwall(id1, 1)) * (vline - cwall(id1, 1));
elseif (cwall(id1, 2) < imsz(1) - immargin)
    %
    if(id1 == 1)
        if(dist2(2) < dist2(numpoints))
            id2 = 2;
        else
            id2 = numpoints;
        end
    elseif(id1 == numpoints)
        if(dist2(1) < dist2(id1 - 1))
            id2 = 1;
        else
            id2 = id1 - 1;
        end
    else
        if(dist2(id1 - 1) < dist2(id1 + 1))
            id2 = id1 - 1;
        else
            id2 = id1 + 1;
        end
    end
    
    fpts(2, 1) = vline;
    % fpts(1, 2) = y1 + (y2-y1)/(x2-x1) * (vline - x1);
    fpts(2, 2) = cwall(id1, 2) + (cwall(id2, 2) - cwall(id1, 2))/(cwall(id2, 1) - cwall(id1, 1)) * (vline - cwall(id1, 1));
elseif (cwall(id2, 2) < imsz(1) - immargin)
    %
    if(id2 == 1)
        if(dist1(2) < dist1(numpoints))
            id1 = 2;
        else
            id1 = numpoints;
        end
    elseif(id2 == numpoints)
        if(dist1(1) < dist1(id2 - 1))
            id1 = 1;
        else
            id1 = id2 - 1;
        end
    else
        if(dist1(id2 - 1) < dist1(id2 + 1))
            id1 = id2 - 1;
        else
            id1 = id2 + 1;
        end
    end
    
    fpts(2, 1) = vline;
    % fpts(1, 2) = y1 + (y2-y1)/(x2-x1) * (vline - x1);
    fpts(2, 2) = cwall(id1, 2) + (cwall(id2, 2) - cwall(id1, 2))/(cwall(id2, 1) - cwall(id1, 1)) * (vline - cwall(id1, 1));
else
    % no upper intersection
end

%% left point intersecting horizontal line
dist1 = (1 - cwall(:, 1)) .^2 + (1 - cwall(:, 2)) .^2; % left top of the image
[~, id1] = min(dist1);
dist2 = (1 - cwall(:, 1)) .^2 + (imsz(1) - cwall(:, 2)) .^2; % left bottom of the image
[~, id2] = min(dist2);

if (cwall(id1, 1) > immargin && cwall(id2, 1) > immargin)
    fpts(3, 2) = hline;
    % fpts(3, 1) = x1 + (x2-x1)/(y2-y1) * (vline - y1);
    fpts(3, 1) = cwall(id1, 1) + (cwall(id2, 1) - cwall(id1, 1))/(cwall(id2, 2) - cwall(id1, 2)) * (hline - cwall(id1, 2));
elseif (cwall(id1, 1) > immargin)
    %
    if(id1 == 1)
        if(dist2(2) < dist2(numpoints))
            id2 = 2;
        else
            id2 = numpoints;
        end
    elseif(id1 == numpoints)
        if(dist2(1) < dist2(id1 - 1))
            id2 = 1;
        else
            id2 = id1 - 1;
        end
    else
        if(dist2(id1 - 1) < dist2(id1 + 1))
            id2 = id1 - 1;
        else
            id2 = id1 + 1;
        end
    end
    fpts(3, 2) = hline;
    % fpts(3, 1) = x1 + (x2-x1)/(y2-y1) * (vline - y1);
    fpts(3, 1) = cwall(id1, 1) + (cwall(id2, 1) - cwall(id1, 1))/(cwall(id2, 2) - cwall(id1, 2)) * (hline - cwall(id1, 2));
elseif (cwall(id2, 1) > immargin)
    %
    if(id2 == 1)
        if(dist1(2) < dist1(numpoints))
            id1 = 2;
        else
            id1 = numpoints;
        end
    elseif(id2 == numpoints)
        if(dist1(1) < dist1(id2 - 1))
            id1 = 1;
        else
            id1 = id2 - 1;
        end
    else
        if(dist1(id2 - 1) < dist1(id2 + 1))
            id1 = id2 - 1;
        else
            id1 = id2 + 1;
        end
    end
    fpts(3, 2) = hline;
    % fpts(3, 1) = x1 + (x2-x1)/(y2-y1) * (vline - y1);
    fpts(3, 1) = cwall(id1, 1) + (cwall(id2, 1) - cwall(id1, 1))/(cwall(id2, 2) - cwall(id1, 2)) * (hline - cwall(id1, 2));
else
end
%% right point intersecting horizontal line
dist1 = (imsz(2) - cwall(:, 1)) .^2 + (1 - cwall(:, 2)) .^ 2; % right top of the image
[~, id1] = min(dist1);
dist2 = (imsz(2) - cwall(:, 1)) .^2 + (imsz(1) - cwall(:, 2)) .^ 2; % right bottom of the image
[~, id2] = min(dist2);

if (cwall(id1, 1) < imsz(2) - immargin && cwall(id2, 1) < imsz(2) - immargin)
    fpts(4, 2) = hline;
    % fpts(4, 1) = x1 + (x2-x1)/(y2-y1) * (vline - y1);
    fpts(4, 1) = cwall(id1, 1) + (cwall(id2, 1) - cwall(id1, 1))/(cwall(id2, 2) - cwall(id1, 2)) * (hline - cwall(id1, 2));
elseif (cwall(id1, 1) < imsz(2) - immargin)
    %
    if(id1 == 1)
        if(dist2(2) < dist2(numpoints))
            id2 = 2;
        else
            id2 = numpoints;
        end
    elseif(id1 == numpoints)
        if(dist2(1) < dist2(id1 - 1))
            id2 = 1;
        else
            id2 = id1 - 1;
        end
    else
        if(dist2(id1 - 1) < dist2(id1 + 1))
            id2 = id1 - 1;
        else
            id2 = id1 + 1;
        end
    end
    fpts(4, 2) = hline;
    % fpts(3, 1) = x1 + (x2-x1)/(y2-y1) * (vline - y1);
    fpts(4, 1) = cwall(id1, 1) + (cwall(id2, 1) - cwall(id1, 1))/(cwall(id2, 2) - cwall(id1, 2)) * (hline - cwall(id1, 2));
elseif (cwall(id2, 1) < imsz(2) - immargin)
    %
    if(id2 == 1)
        if(dist1(2) < dist1(numpoints))
            id1 = 2;
        else
            id1 = numpoints;
        end
    elseif(id2 == numpoints)
        if(dist1(1) < dist1(id2 - 1))
            id1 = 1;
        else
            id1 = id2 - 1;
        end
    else
        if(dist1(id2 - 1) < dist1(id2 + 1))
            id1 = id2 - 1;
        else
            id1 = id2 + 1;
        end
    end
    fpts(4, 2) = hline;
    % fpts(3, 1) = x1 + (x2-x1)/(y2-y1) * (vline - y1);
    fpts(4, 1) = cwall(id1, 1) + (cwall(id2, 1) - cwall(id1, 1))/(cwall(id2, 2) - cwall(id1, 2)) * (hline - cwall(id1, 2));
else
end

end