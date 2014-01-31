function [ space_iu, base_wall, polytope_x ] = get_3d_space_iu_2( anno, Polyg, imsz, vp, K, R )
% base_wall
%   1: ground
%   2: center wall

h = 1;

img_row = imsz(1);
img_col = imsz(2);

vp = ordervp(vp,img_row,img_col);
[campar.K,campar.R] = calibrate_cam(vp,img_row,img_col);
campar.f  = campar.K(1,1);
campar.u0 = campar.K(1,3);
campar.v0 = campar.K(2,3);
[campar.p,campar.y,campar.r] = computeAngleFromR(campar.R);

assert(abs(sum(K(:) - campar.K(:))) < K(1,1)*1e-6);
assert(abs(sum(R(:) - campar.R(:))) < 10);

space_iu  = NaN;
base_wall = NaN;
if ~isempty(Polyg{1})
    % use gnd
    [polytope_x, volume_x] = getPV(campar.f, campar.p, campar.y, campar.r, Polyg, imsz, h, 1);
    int       = intersect(anno.polytope_gnd, polytope_x);
    vol_int   = volume(int);
    space_iu  = vol_int/(anno.volume_gnd + volume_x - vol_int);
    base_wall = 1;
else
    % use center wall
    [polytope_x, volume_x] = getPV(campar.f, campar.p, campar.y, campar.r, Polyg, imsz, h, 2);
    int       = intersect(anno.polytope_cw, polytope_x);
    vol_int   = volume(int);
    space_iu  = vol_int/(anno.volume_cw + volume_x - vol_int);
    % int       = intersect(anno.polytope_gnd, polytope_x);
    % vol_int   = volume(int);
    % space_iu  = vol_int/(anno.volume_gnd + volume_x - vol_int);
    base_wall = 2;
end

end

