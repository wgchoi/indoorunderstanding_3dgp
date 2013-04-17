function generate_itm_htmls(ptn, itm_examples, modelfile, htmlfile, imgdir)

maximages = 60;

fulldir = fullfile(pwd(), fullfile('htmls/', imgdir));
mkdir(fulldir);

visualizeITM(ptn, objmodels(), 1)
print('-djpeg', fullfile(fulldir, 'a_ptn.jpg'));
close();

addpath ../Detector/dpm_detector/
load(modelfile)
visualizemodel(model);
print('-djpeg', fullfile(fulldir, 'b_dpm.jpg'));
close();
rmpath ../Detector/dpm_detector/

for i = 1:min(maximages, length(itm_examples))
    figure(1); clf();
    imshow(itm_examples(i).imfile);
    rectangle('position', bbox2rect(itm_examples(i).bbox), 'linewidth', 2, 'edgecolor', 'w');
    
    cols = {'r' 'g' 'b' 'k' 'm'};
    cts = [];
    for j = 1:size(itm_examples(i).objboxes, 2)
        rectangle('position', bbox2rect( itm_examples(i).objboxes(:, j) ), 'linewidth', 3, 'edgecolor', cols{j});
        cts(:, j) = bbox2ct(itm_examples(i).objboxes(:, j));
    end
    
    hold on;
    plot(cts(1,1), cts(2, 1), 'c.', 'MarkerSize', 30);
    plot(cts(1, 1:2), cts(2, 1:2), 'r-', 'linewidth', 3)
    hold off
    title(['angle: ' num2str(itm_examples(i).angles / pi * 180, '%.02f') ' azimuth: ' num2str(itm_examples(i).azimuth / pi * 180, '%.02f')]);
    
    drawnow;
    print('-djpeg', fullfile(fulldir, ['c_example' num2str(i, '%03d') '.jpg']));
end

cd htmls;
addpath ~/codes/thumbnailImageHTML;
createThumbnailTable(imgdir, htmlfile, 400, 5, maximages)
rmpath ~/codes/thumbnailImageHTML;
cd ..

end