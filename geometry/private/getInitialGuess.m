function iloc = getInitialGuess(obj, model, mid, K, R, cam_height)

cpt2 = [obj.bbs(1) + obj.bbs(3) / 2; obj.bbs(2) + obj.bbs(4) / 2];
cray3 = (K * R) \ [cpt2; 1];
iloc = cray3 ./ cray3(2) * -(cam_height - model.height(mid) / 2);

end
