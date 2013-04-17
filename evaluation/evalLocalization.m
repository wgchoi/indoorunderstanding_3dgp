function [ddiff]= evalLocalization(annos, xs, confs, cls, draw, overall, usenms)

if(nargin < 6)
	usenms = true;
    overall = false;
elseif(nargin < 7)
	usenms = true;
end
fprintf('%d: pr: evaluating detections\n', cls);

% extract ground truth objects
npos = 0;
for i = 1:length(annos)
    gt(i).BB = [];
    if(overall)
        for j = 1:length(annos{i}.obj_annos)
            gt(i).BB(:, end + 1) = [annos{i}.obj_annos(j).x1; annos{i}.obj_annos(j).y1; annos{i}.obj_annos(j).x2; annos{i}.obj_annos(j).y2; annos{i}.obj_annos(j).azimuth];
        end
    else
		if(cls == 7)
			for j = 1:length(annos{i}.hmn_annos)
				gt(i).BB(:, end + 1) = [annos{i}.hmn_annos(j).x1; annos{i}.hmn_annos(j).y1; annos{i}.hmn_annos(j).x2; annos{i}.hmn_annos(j).y2; annos{i}.hmn_annos(j).azimuth];
			end
		else
			for j = 1:length(annos{i}.obj_annos)
				if(annos{i}.obj_annos(j).objtype == cls)
					gt(i).BB(:, end + 1) = [annos{i}.obj_annos(j).x1; annos{i}.obj_annos(j).y1; annos{i}.obj_annos(j).x2; annos{i}.obj_annos(j).y2; annos{i}.obj_annos(j).azimuth];
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
for i = 1:length(xs)
    if(overall)
        classes = unique(xs{i}.dets(:, 1));
        pick = [];
        for j = 1:length(classes)
            clsidx = find(xs{i}.dets(:, 1) == classes(j));
            
            temp = [xs{i}.dets(clsidx, 4:7), xs{i}.dets(clsidx, 3), confs{i}(clsidx)];
            tpick = nms(temp, 0.5);
            pick = [pick; clsidx(tpick(:))];
        end
        boxes = [xs{i}.dets(:, 4:7), xs{i}.dets(:, 3), confs{i}(:)];
    else
        clsidx = (xs{i}.dets(:, 1) == cls);
        boxes = [xs{i}.dets(clsidx, 4:7), xs{i}.dets(clsidx, 3), confs{i}(clsidx)];
        pick = nms(boxes, 0.5);
    end

	if(usenms)
	    boxes = boxes(pick, :);
	end
    
    confidence(ndet+1:ndet+size(boxes, 1)) = boxes(:, end);
    BB(:, ndet+1:ndet+size(boxes, 1)) = boxes(:, 1:4)';
    ids(ndet+1:ndet+size(boxes, 1)) = i;
    
    ndet = ndet + size(boxes, 1);
end

confidence(ndet+1:end) = [];
BB(:, ndet+1:end) = [];
ids(ndet+1:end) = [];

% sort detections by decreasing confidence
[sc, si]=sort(-confidence);
ids = ids(si);
BB = BB(:,si);

% assign detections to ground truth objects
nd=length(confidence);
tp=zeros(nd,1);
fp=zeros(nd,1);
tic;

ddiff = [];
for d=1:nd
    % display progress
    if toc>1
        fprintf('%d: pr: compute: %d/%d\n',cls,d,nd);
        drawnow;
        tic;
    end
    
    i = ids(d);
    % assign detection to ground truth object if any
    bb = BB(:,d);
    ovmax = -inf;
    for j=1:size(gt(i).BB,2)
        bbgt=gt(i).BB(:,j);
        bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 & ih>0                
            % compute overlap as area of intersection / area of union
            ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
               (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
               iw*ih;
            ov=iw*ih/ua;
            if ov>ovmax
                ovmax=ov;
                jmax=j;
            end
        end
    end
    % assign detection as true positive/don't care/false positive
    if ovmax >= 0.5 % VOCopts.minoverlap
        if ~gt(i).diff(jmax)
            if ~gt(i).det(jmax)
                tp(d)=1;            % true positive
                gt(i).det(jmax)=true;
                
                ddiff(end+1) = (BB(2,d) + BB(4,d) - (gt(i).BB(2,jmax) + gt(i).BB(4,jmax))) / (gt(i).BB(2,jmax) + gt(i).BB(4,jmax));
            else
                fp(d)=1;            % false positive (multiple detection)
            end
        end
    else
        fp(d)=1;                    % false positive
    end
end

