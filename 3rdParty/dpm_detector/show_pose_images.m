function show_pose_images(spos)

nx = 4; ny = 8;
w = 100; h = 50;

fullim = uint8(zeros(h * ny, w * nx, 3));

for i = 1:ny
    for j = 1:nx
        idx = (i - 1) * floor(length(spos) / ny) + j;
        
        if(idx > length(spos))
            continue;
        end
        
        window = subarray(imread(spos(idx).im), ...
                            floor(spos(idx).y1), floor(spos(idx).y2), ...
                            floor(spos(idx).x1), floor(spos(idx).x2), 1);
        
        if(isfield(spos(idx), 'mirrored') && spos(idx).mirrored)
            window = flipimage(window);
        end
        fullim(((i-1) * h + 1):(i * h), ((j-1) * w + 1):(j * w), :) = uint8(imresize(window, [h w]));
    end
end
imshow(fullim);
end