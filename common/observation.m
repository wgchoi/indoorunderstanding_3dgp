function x = observation(imsz, vps, boxlayout)
%%% 
x = struct('K', zeros(3), 'R', zeros(3), 'vp', zeros(3, 2), ...
            'l', []); % cell(size(boxlayout.reestimated, 1), 1));
% layout(boxlayout, img, vp, R, K)

%%% need to verify calibration as well!!!
[x.K, x.R]=calibrate_cam(vps, imsz(1), imsz(2));
x.l = layout(boxlayout, imsz, vps, x.R, x.K);
end