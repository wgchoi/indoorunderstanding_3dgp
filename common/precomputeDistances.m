function x = precomputeDistances(x)

if(isfield(x, 'hobjs'))
    x.dists = zeros(length(x.hobjs), length(x.hobjs));
    x.angdiff = zeros(length(x.hobjs), length(x.hobjs));
    
    for i = 1:length(x.hobjs)
        for j = i+1:length(x.hobjs)
            % x.hobjs(i).locs(:, 14)
            d = norm(x.hobjs(i).locs(:, 14) - x.hobjs(j).locs(:, 14));
            
            x.dists(i, j) = d;
            x.dists(j, i) = d;

            ad = anglediff(x.hobjs(i).angle, x.hobjs(j).angle);
            x.angdiff(i, j) = ad;
            x.angdiff(j, i) = ad;
        end
    end
else
    x.dists = zeros(size(x.locs, 1), size(x.locs, 1));
    x.angdiff = zeros(size(x.locs, 1), size(x.locs, 1));
    for i = 1:size(x.locs, 1)
        for j = i+1:size(x.locs, 1)
            d = norm(x.locs(i, 1:3) - x.locs(j, 1:3));
            x.dists(i, j) = d;
            x.dists(j, i) = d;

            ad = anglediff(x.locs(i, 4), x.locs(j, 4));
            x.angdiff(i, j) = ad;
            x.angdiff(j, i) = ad;
        end
    end
end

end