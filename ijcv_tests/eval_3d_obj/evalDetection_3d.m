% function [rec, prec, ap]= evalDetection_3d(annos, xs, confs, cls, draw, overall, usenms)
function [rec, prec, ap]= evalDetection_3d(annos, xs, res, confs, cls, ovthres, nmsthres, draw, overall, usenms)
if(nargin < 8)
	usenms = true;
    overall = false;
elseif(nargin < 9)
	usenms = true;
end
fprintf('%d: pr: evaluating detections\n', cls);
% extract ground truth objects
npos = 0;
for i = 1:length(annos)
    gt(i).BB = [];
    gt(i).CB = [];
    if(overall)
        % for j = 1:length(annos{i}.obj_annos)
        %     gt(i).BB(:, end + 1) = [annos{i}.obj_annos(j).x1; annos{i}.obj_annos(j).y1; annos{i}.obj_annos(j).x2; annos{i}.obj_annos(j).y2; annos{i}.obj_annos(j).azimuth];
        % end
    else
		if(cls == 7)
			% for j = 1:length(annos{i}.hmn_annos)
			% 	  gt(i).BB(:, end + 1) = [annos{i}.hmn_annos(j).x1; annos{i}.hmn_annos(j).y1; annos{i}.hmn_annos(j).x2; annos{i}.hmn_annos(j).y2; annos{i}.hmn_annos(j).azimuth];
			% end
		else
			for j = 1:length(annos{i}.obj_annos)
				if(annos{i}.obj_annos(j).objtype == cls)
                    gt(i).BB(:, end + 1) = [annos{i}.obj_annos(j).x1; annos{i}.obj_annos(j).y1; annos{i}.obj_annos(j).x2; annos{i}.obj_annos(j).y2; annos{i}.obj_annos(j).azimuth];
                    assert(annos{i}.hobjs(j).oid == cls)
                    % gt(i).BB(:, end + 1) = convert2bcube(annos{i}.alpha(j)*annos{i}.hobjs(j).cubes(:,:,14));  % default
                    gt(i).CB{end + 1} = convert2polyt(annos{i}.alpha(j)*annos{i}.hobjs(j).cubes(:,:,14));  % default
				end
			end
		end
    end
    gt(i).diff = false(size(gt(i).BB, 2), 1); 
    gt(i).det = false(size(gt(i).BB, 2), 1);
    npos = npos + size(gt(i).BB, 2);
end

ndet = 0;
ids = zeros(1, 100000);
confidence = zeros(1, 100000);
BB = zeros(4, 100000);
CB = cell(1, 100000);

for i = 1:length(xs)
    if(overall)
        % classes = unique(xs{i}.dets(:, 1));
        % pick = [];
        % for j = 1:length(classes)
        %     clsidx = find(xs{i}.dets(:, 1) == classes(j));
        %     
        %     temp = [xs{i}.dets(clsidx, 4:7), xs{i}.dets(clsidx, 3), confs{i}(clsidx)];
        %     tpick = nms(temp, 0.5);
        %     pick = [pick; clsidx(tpick(:))];
        % end
        % boxes = [xs{i}.dets(:, 4:7), xs{i}.dets(:, 3), confs{i}(:)];
    else
        % clsidx = (xs{i}.dets(:, 1) == cls);
        % boxes = [xs{i}.dets(clsidx, 4:7), xs{i}.dets(clsidx, 3), confs{i}(clsidx)];
        % pick = nms(boxes, 0.5);
        assert(size(xs{i}.dets,1) == length(xs{i}.hobjs));
        assert(sum(abs(xs{i}.dets(:,3) - [xs{i}.hobjs.azimuth]')) < 1e-2);
        clsidx = find(xs{i}.dets(:, 1) == cls);
        polyt = cell(length(clsidx), 1);
        dconf = confs{i}(clsidx);
        for j = 1:length(clsidx)
            % boxes(j,1:4) = convert2bcube(xs{i}.hobjs(clsidx(j)).cubes(:,:,14));
            % boxes(j,5)   = xs{i}.dets(clsidx(j), 3);
            % boxes(j,6)   = confs{i}(clsidx(j));
            polyt{j} = convert2polyt(xs{i}.hobjs(clsidx(j)).cubes(:,:,14));
        end
        boxes = xs{i}.dets(clsidx, 4:7);
        pick = nms_3d(polyt, dconf, nmsthres);
        % debug use
        % figure(1);
        % for j = 1:length(polyt)
        %     draw3Dcube(extreme(polyt{j})', 1, 'g');
        % end
        % axis equal
        % figure(2);
        % for j = 1:length(pick)
        %     draw3Dcube(extreme(polyt{pick(j)})', 2, 'g');
        % end
        % axis equal
    end
    
    if(usenms)
        % boxes = boxes(pick, :);
        polyt = polyt(pick);
        dconf = dconf(pick);
        boxes = boxes(pick,:);
    end
    
    if ~isempty(dconf)
        confidence(ndet+1:ndet+length(dconf)) = dconf;
        BB(:, ndet+1:ndet+length(dconf)) = boxes';
        CB(:, ndet+1:ndet+length(dconf)) = polyt;
        ids(ndet+1:ndet+length(dconf)) = i;
        ndet = ndet + length(dconf);
    end
end

confidence(ndet+1:end) = [];
BB(:, ndet+1:end) = [];
CB(:, ndet+1:end) = [];
ids(ndet+1:end) = [];

% sort detections by decreasing confidence
[sc, si]=sort(-confidence);
ids = ids(si);
BB = BB(:,si);
CB = CB(:,si);

% assign detections to ground truth objects
nd=length(confidence);
tp=zeros(nd,1);
fp=zeros(nd,1);
tic;
for d=1:nd
    % display progress
    if toc>1
        fprintf('%d: pr: compute: %d/%d\n',cls,d,nd);
        drawnow;
        tic;
    end
    
    i = ids(d);
    % assign detection to ground truth object if any
    bb = CB{d};
    ovmax = -inf;
    for j=1:length(gt(i).CB)
        bbgt=gt(i).CB{j};
        it = intersect(bb, bbgt);
        if ~(size(get(it,'H'),1) == 1 && size(get(it,'K'),1) == 1)
            % compute overlap as area of intersection / area of union
            % ua = volume(union(bb, bbgt));
            ua = volume(bb)+volume(bbgt)-volume(it);
            ov = volume(it)/ua;
            if ov>ovmax
                ovmax=ov;
                jmax=j;
            end
        end
    end
    % assign detection as true positive/don't care/false positive
    if ovmax >= ovthres % VOCopts.minoverlap
        if ~gt(i).diff(jmax)
            if ~gt(i).det(jmax)
                tp(d)=1;            % true positive
                gt(i).det(jmax)=true;
                % debug use 
                % show3DGraph_eval(xs{i}, res{i}.spg(2), bb, annos{i}, gt(i).CB{jmax});
            else
                fp(d)=1;            % false positive (multiple detection)
            end
        end
    else
        fp(d)=1;                    % false positive
    end
end

% compute precision/recall
fp = cumsum(fp);
tp = cumsum(tp);
rec = tp/npos;
prec = tp./(fp+tp);

ap = VOCap(rec, prec);
if draw
    % plot precision/recall
    plot(rec, prec, '-');
    grid;
    xlabel 'recall'
    ylabel 'precision'
    title(sprintf('class: %d, AP = %.3f', cls, ap));
	axis([0 1 0 1]);
end

function ap = VOCap(rec,prec)
mrec=[0 ; rec ; 1]; 
mpre=[0 ; prec ; 0]; 
for i=numel(mpre)-1:-1:1
    mpre(i)=max(mpre(i),mpre(i+1));
end
i=find(mrec(2:end)~=mrec(1:end-1))+1;
ap=sum((mrec(i)-mrec(i-1)).*mpre(i));
 
% function bcube = convert2bcube(cube)
% assert(length(unique(cube(:))) <= 6);
% x1 = min(cube(1,:));
% y1 = min(cube(2,:));
% z1 = min(cube(3,:));
% x2 = max(cube(1,:));
% y2 = max(cube(2,:));
% z2 = max(cube(3,:));
% bcube = [x1 y1 z1 x2 y2 z2];

function polyt = convert2polyt(cube)
polyt = polytope(cube');

function pick = nms_3d(polyt, conf, overlap)
% pick = nms(boxes, overlap) 
% Non-maximum suppression.
% Greedily select high-scoring detections and skip detections
% that are significantly covered by a previously selected detection.
if isempty(polyt)
  pick = [];
else
    s = conf;
    vol = zeros(length(polyt),1);
    for i = 1:length(polyt)
        vol(i) = volume(polyt{i});
    end

  [vals, I] = sort(s);
  pick = [];
  while ~isempty(I)
    last = length(I);
    i = I(last);
    pick = [pick; i];
    suppress = [last];
    for pos = 1:last-1
      j = I(pos);
      it = intersect(polyt{i}, polyt{j});
      if ~(size(get(it,'H'),1) == 1 && size(get(it,'K'),1) == 1)
        % compute overlap
        try
            o = volume(it) / vol(j);
        catch
            % mpt bug
            try
                it = polytope(extreme(it));
                o = volume(it) / vol(j);
            end
        end
        if o > overlap
          suppress = [suppress; pos];
        end
      end
    end
    I(suppress) = [];
  end  
end

