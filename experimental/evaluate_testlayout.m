function [outputs, ls, le] = evaluate_testlayout(data, params)

ls = zeros(1, length(data));
le = zeros(1, length(data));
model =  params.model;

parfor i = 1:length(data)
    pg = data(i).gpg;
    maxval = -inf;
    
    for j = 1:min(length(data(i).x.lloss), 50)
        pg.layoutidx = j;
        phi = feat_test(pg, data(i).x, data(i).iclusters, model);
        
        if(dot(phi, params.w) > maxval)
            maxval = dot(phi, params.w);
            
            ls(i) = data(i).x.lloss(j);
            le(i) = data(i).x.lerr(j);
            
            outputs(i) = j;
        end
    end
end

end
