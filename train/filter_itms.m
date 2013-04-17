function [ptns, indset, comps] = filter_itms(ptns, indset, comps, params)
assert(params.model.humancentric == 1);
% clf
idx = [];
cnt = 1;
for i = 1:length(ptns)
    if(1)
        dists = inf(length(ptns(i).parts), length(ptns(i).parts));
        for j = 1:length(ptns(i).parts)
            for k = j+1:length(ptns(i).parts)
                dists(j, k) = (ptns(i).parts(j).dx - ptns(i).parts(k).dx) .^ 2 + (ptns(i).parts(j).dz - ptns(i).parts(k).dz) .^ 2;
                dists(j, k) = sqrt(dists(j, k));
                dists(k, j) = dists(j, k);
            end
        end
        keep = all(min(dists, [], 2) < 2);
    else
        hid = 0;
        for j = 1:length(ptns(i).parts)
            if(ptns(i).parts(j).citype == 7)
                hid = j;
                break;
            end
        end
        dists = inf(1, length(ptns(i).parts));
        for j = 1:length(ptns(i).parts)
            if(hid == j) 
                continue;
            end
            dists(j) = (ptns(i).parts(hid).dx - ptns(i).parts(j).dx) .^ 2 + (ptns(i).parts(hid).dz - ptns(i).parts(j).dz) .^ 2;
            dists(j) = sqrt(dists(j));
        end
        keep = any(dists < 1.5);
    end
    
    if(keep)
        idx(end+1) = i;        
        % visualizeITM(ptns(i));
    else
        if(cnt <= 16)
            subplot(4,4,cnt);
            visualizeITM(ptns(i));
            title('too far');
        end        
        cnt = cnt + 1;
    end
end

ptns = ptns(idx);
indset = indset(idx);
comps = comps(idx);

end