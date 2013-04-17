function [img] = get_average_itm_image(itm_examples)

img = zeros(400, 400, 3);

for i = 1:length(itm_examples)
    im = imread(itm_examples(i).imfile);
    tempimg = cropimage(im, itm_examples(i).bbox);
    tempimg = imresize(tempimg, [400 400]);
    
    [fx, fy] = gradient(tempimg);
    tempimg = sqrt(fx .^ 2 + fy .^ 2);
    tempimg = tempimg ./ max(max(max(tempimg)));
    img = img + tempimg ./ length(itm_examples); 
end

end

function outimg = cropimage(img, bbox)
bbox = floor(bbox);

outimg = zeros(bbox(4)-bbox(2)+1,bbox(3)-bbox(1)+1, 3);

src_range = [max(1, bbox(1)), min(size(img, 2), bbox(3)); max(1, bbox(2)), min(size(img, 1), bbox(4))];
dst_range = [1 bbox(3)-bbox(1)+1; 1 bbox(4)-bbox(2)+1];
if(src_range(1, 1) > bbox(1))
    dst_range(1, 1) = src_range(1, 1) - bbox(1) + 1;
end
if(src_range(2, 1) > bbox(2))
    dst_range(2, 1) = src_range(2, 1) - bbox(2) + 1;
end

if(src_range(1, 2) < bbox(3))
    dst_range(1, 2) = src_range(1, 2) - bbox(1) + 1;
end
if(src_range(2, 2) < bbox(4))
    dst_range(2, 2) = src_range(2, 2) - bbox(2) + 1;
end

if(src_range(1, 2) - src_range(1, 1) ~=  dst_range(1, 2) - dst_range(1, 1))
    keyboard;
end
if(src_range(2, 2) - src_range(2, 1) ~=  dst_range(2, 2) - dst_range(2, 1))
    keyboard;
end

outimg(dst_range(2,1):dst_range(2,2), dst_range(1,1):dst_range(1,2), :) = img(src_range(2,1):src_range(2,2), src_range(1,1):src_range(1,2), :);
% keyboard;
% yrange = [max(1, bbox(1)), min(size(img, 2), bbox(3))];

end