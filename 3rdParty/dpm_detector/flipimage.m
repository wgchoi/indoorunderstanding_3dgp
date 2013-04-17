function im = flipimage(im)
% im = flipimage(im)
% Horizontal-flip image.
% Used for learning symmetric pose.
w = size(im, 2);
im = im(:, w:-1:1, :);
end