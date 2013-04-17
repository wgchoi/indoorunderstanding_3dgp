function show_itm_examples(ptn, examples, responses)
if (nargin < 3)
    responses = [];
else
    [~, idx] = sort(responses, 'descend');
    examples = examples(idx);
    responses = responses(idx);
end

warning('OFF');
for i = 1:length(examples)
    if(mod(i, 16) == 1 && i ~= 1)
        pause();
        clf();
    end
    subplot(4,4,mod(i-1, 16)+1);
    im=imread(examples(i).imfile);
    if(examples(i).flip)
        im = flipimage(im);
    end
    imshow(im);
    rectangle('position', bbox2rect(examples(i).bbox), 'linewidth', 2, 'edgecolor', 'w');
    
    cols = {'r' 'g' 'b' 'k' 'm' 'r' 'c'};
    cts = [];
    for j = 1:size(examples(i).objboxes, 2)
        if(isempty(ptn))
            colid = j;
        else
            colid = ptn.parts(j).citype;
        end
        rectangle('position', bbox2rect( examples(i).objboxes(:, j) ), 'linewidth', 3, 'edgecolor', cols{colid});
        cts(:, j) = bbox2ct(examples(i).objboxes(:, j));
    end
        
    hold on;
    plot(cts(1,1), cts(2, 1), 'c.', 'MarkerSize', 30);
    plot(cts(1, 1:2), cts(2, 1:2), 'r-', 'linewidth', 3)
    hold off
    
    for j = 1:size(examples(i).objboxes, 2)
        text(examples(i).objboxes(1, j)+5, examples(i).objboxes(2, j)+5, num2str(j), 'fontsize', 20, 'backgroundcolor', 'w');
    end
    
    if(~isempty(responses))
        title(['response: ' num2str(responses(i), '%.02f')]);
    else
        title([num2str(i) 'th angle: ' num2str(examples(i).angle / pi * 180, '%.02f') ' azimuth: ' num2str(examples(i).azimuth / pi * 180, '%.02f')]);
    end
%     pause
end

warning('ON');
end

function im = flipimage(im)
% im = flipimage(im)
% Horizontal-flip image.
% Used for learning symmetric pose.
w = size(im, 2);
im = im(:, w:-1:1, :);
end