function [flipped_examples] = get_flipped_itm_examples(itm_examples)

flipped_examples = struct('imfile', cell(1, length(itm_examples)), ...
                        'flip', true, ...
                        'bbox', [], 'angle', [], 'azimuth', [], ...
                        'objtypes', [], 'objboxes', [], 'objangs', [], 'objazs', []);
warning('OFF');
for i = 1:length(itm_examples)
    info = imfinfo(itm_examples(i).imfile);
    % info.Width; info.Height;
    
    flipped_examples(i) = itm_examples(i);
    flipped_examples(i).flip = true;
    flipped_examples(i).azimuth = [];
    
    flipped_examples(i).bbox = flip_bbox(flipped_examples(i).bbox, info.Width);
    flipped_examples(i).objboxes = flip_bbox(flipped_examples(i).objboxes, info.Width);
    flipped_examples(i).objazs = 2*pi - flipped_examples(i).objazs;
    flipped_examples(i).objangs = 2*pi - flipped_examples(i).objangs;
end
warning('ON');
end

function out = flip_bbox(bbox, imw)
out(3, :) = imw - bbox(1, :);
out(1, :) = imw - bbox(3, :);
out([2 4], :) = bbox([2 4], :);
end