function features = get_poselet_feature(poselet, indices)
if nargin < 2
    indices = 1:length(poselet.bodies.scores);
end
nbins = 150;

features = zeros(length(indices), 152);
for i = 1:length(indices) % poselet.bodies.bodies)
    idx = indices(i);
    psltdesc = poselet.bodies.src_idx{idx};
    
    desc = poselet.poselets.poselet_id(psltdesc);
    weight = poselet.poselets.scores(psltdesc);

    [~,bin] = histc(desc,1:nbins);
    scorehist = accumarray(bin, weight);
    features(i, 1:150) = [scorehist; zeros(nbins-length(scorehist),1)];
    
    % body - torso height ratio
    ratio = poselet.bodies.rts(4, idx) / poselet.torsos.rts(4, idx);
    if(ratio < 2.5)
        features(i, 151) = 1;
    else
        features(i, 152) = 1;
    end
end

end