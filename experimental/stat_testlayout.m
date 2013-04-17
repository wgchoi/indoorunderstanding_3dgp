function [gain, oracle_gain] = stat_testlayout(data, results)

original = zeros(1, length(data));
res_err = zeros(1, length(data));
oracle = zeros(1, length(data));
oracle_idx = zeros(1, length(data));
gain = zeros(1, length(data));
oracle_gain = zeros(1, length(data));

roomtype = zeros(1, length(data));
numobjs= zeros(7, length(data));

for i = 1:length(data)
    % data(i).x.lerr(length(data(i).x.lconf)+1:end) = [];
    original(i) = data(i).x.lerr(1);
    
    res_err(i) = data(i).x.lerr(results(i));
    [oracle(i), oracle_idx(i)] = min(data(i).x.lerr);

    gain(i) = original(i) - res_err(i);
    oracle_gain(i) = original(i) - oracle(i);
    
    roomtype(i) = data(i).gpg.scenetype;
    
    objidx = getObjIndices(data(i).gpg, data(i).iclusters);
    for obj = 1:length(objidx)
        oid = data(i).iclusters(objidx(obj)).ittype;
        numobjs(oid, i) = numobjs(oid, i) + 1;
    end
end

disp('accuracies =================================================');
disp(['org: ' num2str(mean(original) * 100, '%.03f') '%']);
disp(['oracle: ' num2str(mean(oracle) * 100, '%.03f') '%']);
disp(['results: ' num2str(mean(res_err) * 100, '%.03f') '%']);


[vv, idx] = sort(gain, 'descend');
idx(vv <= 0) = [];
prefix = 'better';
disp([prefix '=================================================']);
disp([ 'total: ' num2str(length(idx)) ', bedroom: ' num2str(sum(roomtype(idx) == 1))  ', livingroom: ' num2str(sum(roomtype(idx) == 2)) ', diningroom: ' num2str(sum(roomtype(idx) == 3))]);
disp([ '# sofa: ' num2str(mean(numobjs(1, idx))) ', # table: ' num2str(mean(numobjs(2, idx))) ', # chair: ' num2str(mean(numobjs(3, idx)))]);
disp([ '# bed: ' num2str(mean(numobjs(4, idx))) ', # dtable: ' num2str(mean(numobjs(5, idx))) ', # stable: ' num2str(mean(numobjs(6, idx)))]);
disp([ 'total gain: ' num2str(sum(gain(idx)) * 100, '%.01f') '% / ' num2str(mean(gain(idx)) * 100, '%.01f') '%']);
disp([ 'error: baseline ' num2str(mean(original(idx)) * 100, '%.01f') '%, re-ranked ' num2str(mean(res_err(idx)) * 100, '%.01f') '%, oracle ' num2str(mean(oracle(idx)) * 100, '%.01f') '%' ]);

[vv, idx] = sort(gain, 'ascend');
idx(vv >= 0) = [];
prefix = 'worse';
disp([prefix '=================================================']);
disp([ 'total: ' num2str(length(idx)) ', bedroom: ' num2str(sum(roomtype(idx) == 1))  ', livingroom: ' num2str(sum(roomtype(idx) == 2)) ', diningroom: ' num2str(sum(roomtype(idx) == 3))]);
disp([ '# sofa: ' num2str(mean(numobjs(1, idx))) ', # table: ' num2str(mean(numobjs(2, idx))) ', # chair: ' num2str(mean(numobjs(3, idx)))]);
disp([ '# bed: ' num2str(mean(numobjs(4, idx))) ', # dtable: ' num2str(mean(numobjs(5, idx))) ', # stable: ' num2str(mean(numobjs(6, idx)))]);
disp([ 'total lost: ' num2str(sum(gain(idx)) * 100, '%.01f') '% / ' num2str(mean(gain(idx)) * 100, '%.01f') '%']);
disp([ 'error: baseline ' num2str(mean(original(idx)) * 100, '%.01f') '%, re-ranked ' num2str(mean(res_err(idx)) * 100, '%.01f') '%, oracle ' num2str(mean(oracle(idx)) * 100, '%.01f') '%' ]);

idx = find(gain == 0);
prefix = 'equal';
disp([prefix '=================================================']);
disp([ 'total: ' num2str(length(idx)) ', bedroom: ' num2str(sum(roomtype(idx) == 1))  ', livingroom: ' num2str(sum(roomtype(idx) == 2)) ', diningroom: ' num2str(sum(roomtype(idx) == 3))]);
disp([ '# sofa: ' num2str(mean(numobjs(1, idx))) ', # table: ' num2str(mean(numobjs(2, idx))) ', # chair: ' num2str(mean(numobjs(3, idx)))]);
disp([ '# bed: ' num2str(mean(numobjs(4, idx))) ', # dtable: ' num2str(mean(numobjs(5, idx))) ', # stable: ' num2str(mean(numobjs(6, idx)))]);
disp([ 'error: baseline ' num2str(mean(original(idx)) * 100, '%.01f') '%, re-ranked ' num2str(mean(res_err(idx)) * 100, '%.01f') '%, oracle ' num2str(mean(oracle(idx)) * 100, '%.01f') '%' ]);

end
