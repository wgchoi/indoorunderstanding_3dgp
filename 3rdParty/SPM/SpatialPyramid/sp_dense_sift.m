function [sift_arr, grid_x, grid_y] = sp_dense_sift(I, grid_spacing, patch_size)
% Original script by Svetlana Lazebnick
% Adapted by Antonio Torralba: modified using convolutions to speed up the computations.
% And brought back into Svetlana's library

if(~exist('grid_spacing','var'))
    grid_spacing = 1;
end
if(~exist('patch_size','var'))
    patch_size = 16;
end

I = double(I);
I = mean(I,3);
I = I /max(I(:));

% parameters
num_angles = 8;
num_bins = 4;
num_samples = num_bins * num_bins;
alpha = 9; %% parameter for attenuation of angles (must be odd)

if nargin < 5
    sigma_edge = 1;
end

angle_step = 2 * pi / num_angles;
angles = 0:angle_step:2*pi;
angles(num_angles+1) = []; % bin centers

[hgt wid] = size(I);

[G_X,G_Y]=gen_dgauss(sigma_edge);

% add boundary:
I = [I(2:-1:1,:,:); I; I(end:-1:end-1,:,:)];
I = [I(:,2:-1:1,:) I I(:,end:-1:end-1,:)];

I = I-mean(I(:));
I_X = filter2(G_X, I, 'same'); % vertical edges
I_Y = filter2(G_Y, I, 'same'); % horizontal edges

I_X = I_X(3:end-2,3:end-2,:);
I_Y = I_Y(3:end-2,3:end-2,:);

I_mag = sqrt(I_X.^2 + I_Y.^2); % gradient magnitude
I_theta = atan2(I_Y,I_X);
I_theta(find(isnan(I_theta))) = 0; % necessary????

% grid 
grid_x = patch_size/2:grid_spacing:wid-patch_size/2+1;
grid_y = patch_size/2:grid_spacing:hgt-patch_size/2+1;

% make orientation images
I_orientation = zeros([hgt, wid, num_angles], 'single');

% for each histogram angle
cosI = cos(I_theta);
sinI = sin(I_theta);
for a=1:num_angles
    % compute each orientation channel
    tmp = (cosI*cos(angles(a))+sinI*sin(angles(a))).^alpha;
    tmp = tmp .* (tmp > 0);

    % weight by magnitude
    I_orientation(:,:,a) = tmp .* I_mag;
end

% Convolution formulation:
weight_kernel = zeros(patch_size,patch_size);
r = patch_size/2;
cx = r - 0.5;
sample_res = patch_size/num_bins;
weight_x = abs((1:patch_size) - cx)/sample_res;
weight_x = (1 - weight_x) .* (weight_x <= 1);

for a = 1:num_angles
    %I_orientation(:,:,a) = conv2(I_orientation(:,:,a), weight_kernel, 'same');
    I_orientation(:,:,a) = conv2(weight_x, weight_x', I_orientation(:,:,a), 'same');
end

% Sample SIFT bins at valid locations (without boundary artifacts)
% find coordinates of sample points (bin centers)
[sample_x, sample_y] = meshgrid(linspace(1,patch_size+1,num_bins+1));
sample_x = sample_x(1:num_bins,1:num_bins); sample_x = sample_x(:)-patch_size/2;
sample_y = sample_y(1:num_bins,1:num_bins); sample_y = sample_y(:)-patch_size/2;

sift_arr = zeros([length(grid_y) length(grid_x) num_angles*num_bins*num_bins], 'single');
b = 0;
for n = 1:num_bins*num_bins
    sift_arr(:,:,b+1:b+num_angles) = I_orientation(grid_y+sample_y(n), grid_x+sample_x(n), :);
    b = b+num_angles;
end
clear I_orientation


% Outputs:
[grid_x,grid_y] = meshgrid(grid_x, grid_y);
[nrows, ncols, cols] = size(sift_arr);

% normalize SIFT descriptors
%slow good normailzation that respects the flat areas
sift_arr = reshape(sift_arr, [nrows*ncols num_angles*num_bins*num_bins]);
sift_arr = sp_normalize_sift(sift_arr);
sift_arr = reshape(sift_arr, [nrows ncols num_angles*num_bins*num_bins]);

%slow bad normailzation that does not respect the flat areas
%ct = .1;
%sift_arr = sift_arr + ct;
%tmp = sqrt(sum(sift_arr.^2, 3));
%sift_arr = sift_arr ./ repmat(tmp, [1 1 size(sift_arr,3)]);


function [GX,GY]=gen_dgauss(sigma)

% laplacian of size sigma
%f_wid = 4 * floor(sigma);
%G = normpdf(-f_wid:f_wid,0,sigma);
%G = G' * G;
G = gen_gauss(sigma);
[GX,GY] = gradient(G); 

GX = GX * 2 ./ sum(sum(abs(GX)));
GY = GY * 2 ./ sum(sum(abs(GY)));


function G=gen_gauss(sigma)

if all(size(sigma)==[1, 1])
    % isotropic gaussian
	f_wid = 4 * ceil(sigma) + 1;
    G = fspecial('gaussian', f_wid, sigma);
%	G = normpdf(-f_wid:f_wid,0,sigma);
%	G = G' * G;
else
    % anisotropic gaussian
    f_wid_x = 2 * ceil(sigma(1)) + 1;
    f_wid_y = 2 * ceil(sigma(2)) + 1;
    G_x = normpdf(-f_wid_x:f_wid_x,0,sigma(1));
    G_y = normpdf(-f_wid_y:f_wid_y,0,sigma(2));
    G = G_y' * G_x;
end
