function [bbox, ar] = boxinimage(imsz, bbox)
%
x1 = max(1, bbox(:, 1));
y1 = max(1, bbox(:, 2));
x2 = min(imsz(2), bbox(:, 3));
y2 = min(imsz(1), bbox(:, 4));

w = x2-x1+1; h = y2-y1+1; inter = w .* h;
barea = (bbox(:, 3) - bbox(:, 1) + 1) .* (bbox(:, 4) - bbox(:, 2) + 1);

ar = inter ./ barea;
bbox = [x1 y1 x2 y2];