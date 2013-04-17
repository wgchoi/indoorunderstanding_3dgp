function x = preprocessClusterOverlap_copy(x, iclusters)

x.cloverlap = sparse(length(iclusters), length(iclusters));
for i = 1:length(iclusters)
    for j = i+1:length(iclusters)
        x.cloverlap(i, j) = ~isempty(intersect(iclusters(i).chindices, iclusters(j).chindices));
        x.cloverlap(j, i) = x.cloverlap(i, j);
    end
end

end