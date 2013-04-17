function [pascal_examples] = find_itm_from_pascal(itm_examples, ptn)
names = {'sofa' 'diningtable' 'chair' 'bed' 'diningtable' 'sidetable' 'person'};
addpath detector;

globals;
VOC2006 = false;
pascal_init;

cls = names{ptn.parts(1).citype};

pascal_examples = struct(  'imfile', {}, ...
                        'flip', false, ...
                        'bbox', [], 'angle', [], 'azimuth', [], ...
                        'objtypes', [], 'objboxes', [], 'objangs', [], 'objazs', []);


try
    [ids, gt] = textread(sprintf(VOCopts.imgsetpath, [cls '_trainval']), '%s %d');
catch
    return;
end

ptnobjs = zeros(1, length(names));
for i = 1:length(ptn.parts)
    ptnobjs(ptn.parts(i).citype) = ptnobjs(ptn.parts(i).citype) + 1;
end


maxrefset = 20;
minmatch = 2;

nstep = floor(length(itm_examples) / maxrefset);
ref_examples = itm_examples(1:nstep:end);

nparts=ptn.numparts;

fprintf('discover pascal dataset:')                    
for i = 1:length(ids);
    if(gt(i) <= 0)
        continue;
    end
    if(mod(i, 50) == 0)
        fprintf('.');
    end
    rec = PASreadrecord(sprintf(VOCopts.annopath, ids{i}));
    
    numobjs = zeros(1, length(names));
    objidx = zeros(1, length(rec.objects));
    for j = 1:length(rec.objects)
        for k = 1:length(names)
            if(strcmp(rec.objects(j).class, names{k}))
                numobjs(k) = numobjs(k) + 1;
                objidx(j) = k;
            end
        end
    end
    
    if(all(numobjs >= ptnobjs))
        %%% find indices of each part type
        indices = cell(ptn.numparts, 1);
        for j = 1:ptn.numparts
            indices{j} = find(objidx == ptn.parts(j).citype);
        end
        %%% find all possible sets of combinations.
        sets = recFindSets(indices);
        
        newexs = struct(  'imfile', cell(1, size(sets, 2)), ...
                        'flip', false, ...
                        'bbox', [], 'angle', [], 'azimuth', [], ...
                        'objtypes', [], 'objboxes', [], 'objangs', [], 'objazs', []);

        removeidx = [];
        for j = 1:size(sets, 2)
            newexs(j).imfile = [VOCopts.datadir rec.imgname];
            newexs(j).flip = false;
            allx = [];
            ally = [];
            
            oidx = sets(:, j);
            
            for k = 1:length(oidx)
                newexs(j).objtypes(k) = ptn.parts(k).citype;
                
                bbox = rec.objects(oidx(k)).bbox;
                
                newexs(j).objboxes(:, k) = bbox';
                newexs(j).objangs(k) = 0; % unknown
                
                if(~isempty(rec.objects(oidx(k)).view) && ~strcmp(rec.objects(oidx(k)).view, ''))
                    if(strcmp(rec.objects(oidx(k)).view, 'Frontal'))
                        azimuth = 0;
                    elseif(strcmp(rec.objects(oidx(k)).view, 'Left'))
                        azimuth = 90;
                    elseif(strcmp(rec.objects(oidx(k)).view, 'Right'))
                        azimuth = 270;
                    elseif(strcmp(rec.objects(oidx(k)).view, 'Rear'))
                        azimuth = 180;
                    else
                        azimuth = nan;
                    end
                else
                    azimuth = nan;
                    removeidx(end+1) = j;
                end
                newexs(j).objazs(k) = azimuth / 180 * pi;

                allx = [allx, bbox([1 3])];
                ally = [ally, bbox([2 4])];
            end
            newexs(j).bbox = [min(allx); min(ally); max(allx); max(ally)];
        end
        
        newexs(removeidx) = [];
        
        if(isempty(newexs))
            continue;
        end
        
        [newexs]=remove_duplicate_itm_examples(newexs);
        
        matchexamples = [];
        for j = 1:length(newexs)
            matchcount = 0;
            for k = 1:length(ref_examples)
                if(get_itm_example_dist(newexs(j), ref_examples(k)) < 1.5 * nparts)
                    matchcount = matchcount + 1;
                    if(matchcount  >= minmatch)
                        matchexamples(end+1) = j;
                        break;
                    end
                end
            end
        end
        
        pascal_examples(end+1:end+length(matchexamples)) = newexs(matchexamples);
%         if(length(matchexamples) > 0)
%             keyboard;
%         end
    end
end

disp(['discovered ' num2str(length(pascal_examples)) ' examples from pascal']);
rmpath detector;

end

% copied from findITMCandidates
function [ sets ] = recFindSets(indices)
if(isempty(indices))
    sets = zeros(0, 1);
    return;
end

subsets = recFindSets(indices(2:end));
sets = zeros(length(indices), length(indices{1}) * size(subsets, 2));

cnt = 0;
for i = 1:length(indices{1})
    temp = subsets;
    newidx = indices{1}(i);
    if(~isempty(temp))
        % compatibility filtering
        temp(:, any(temp == newidx, 1)) = [];
    end
    
    idx = (1:size(temp, 2)) + cnt;
    sets(:, idx) = [newidx * ones(1, size(temp, 2)); temp];
    cnt = cnt + size(temp, 2);
end
sets(:, cnt+1:end) = [];

end
