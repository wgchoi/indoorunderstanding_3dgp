function APPwriteVrmlModel(imdir, imseg, vlabels, hy, vrmldir)            
% APPwriteVrmlModel(imdir, imseg, labels, vrmldir)      
% Computes a simple 3D model from geometry labels and writes to vrml file.
%
% Input: 
%   imdir: the directory of the source image
%   imseg: the sp structure for the image
%   labels: the geometric labels for the image
%   vmrldir: the directory for the vrml output
%
% Copyright(C) Derek Hoiem, Carnegie Mellon University, 2005
% Permission granted to non-commercial enterprises for
% modification/redistribution under GNU GPL.  
% Current Version: 1.0  09/30/2005

for i = 1:length(imseg)

	fn = imseg(i).imname;
	%disp(fn)
	image = im2double(imread([imdir '/' fn]));    
    
    if isempty(hy)
        lines = APPgetLargeConnectedEdges(rgb2gray(image), min([size(image, 1) size(image, 2)]*0.02), imseg(i));
        hy = 1-APPestimateHorizon(lines);        
    end    
	
	bn = strtok(fn, '.');            
	imseg(i).segimage = imseg(i).segimage(26:end-25, 26:end-25);
    image = image(26:end-25, 26:end-25, :);

    hlabels = [];
	[gplanes, vplanes, gmap,vmap] = APPlabels2planes(vlabels, hlabels, hy, imseg(i).segimage, image);

    
    use_fancy_transparency = 0;
    if use_fancy_transparency
        vmap = conv2(double(vmap), fspecial('gaussian', 7, 2), 'same');
        vim = image;
        vim(:, :, 4) = vmap; % add alpha channel
    else
        vim = image;
        for b = 1:size(image, 3)
            vim(:, :, b) = image(:, :, b).*vmap;
        end
    end

    gim = image;    
    for b = 1:size(image, 3)
        gim(:, :, b) = gim(:, :, b) .* gmap;
    end    

	[points3D, tpoints2D, faces] = APPplanes2faces(gplanes, vplanes, [size(image, 1) size(image, 2)], hy);   
	faces2vrml(vrmldir, bn, points3D, tpoints2D, faces, gim, vim); %, gcolor, scolor);  
    
end