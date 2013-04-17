function showGeometricContext(imfile, segfile, avgpg)

rl=[255  255 0  0 0 255 0];
gl=[255 0 255  255 0 0 0];
bl=[0  0 255 0 255 255 0];

img = imread(imfile);
imseg = processSuperpixelImage(segfile);
cimages = msPg2confidenceImages(imseg, {avgpg} );

[aa indd]=max(cimages{1}(:,:,1:6),[],3);

mask_r = rl(indd);
mask_g = gl(indd);
mask_b = bl(indd);

mask_color(:,:,1) = mask_r;
mask_color(:,:,2) = mask_g;
mask_color(:,:,3) = mask_b;

hsvmask=rgb2hsv(mask_color);
hsvmask(:,:,3) = aa * 255;

mask_color = hsv2rgb(hsvmask);
tempimg = double(img)*0.5 + mask_color*0.5;
imagesc(uint8(tempimg));

end