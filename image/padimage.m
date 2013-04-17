function [im, offset] = padimage(im, bbox)
if(bbox(3) > size(im, 2))
    dx = bbox(3) - size(im, 2);
    temp = repmat(im(:, end, :), [1, dx, 1]); % zeros(size(im, 1), dx, size(im, 3));
    im = [im, temp];
end

if(bbox(4) > size(im, 1))
    dy = bbox(4) - size(im, 1);
    temp = repmat(im(end, :, :), [dy, 1, 1]); % zeros(size(im, 1), dx, size(im, 3));
    im = [im; temp];
end

offset = zeros(2, 1);
if(bbox(1) < 1)
    dx = 1 - bbox(1);
    temp = repmat(im(:, 1, :), [1, dx, 1]); % zeros(size(im, 1), dx, size(im, 3));
    im = [temp, im];
    offset(1) = dx;
end
if(bbox(2) < 1)
    dy = 1 - bbox(1);
    temp = repmat(im(1, :, :), [dy, 1, 1]); % zeros(size(im, 1), dx, size(im, 3));
    im = [temp; im];
    offset(2) = dy;
end

end