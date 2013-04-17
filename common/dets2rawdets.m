function  raw = dets2rawdets(dets, poses)

raw = zeros(length(dets), 6);
for i = 1:length(dets)
	raw(i, 1:4) = dets(i).bbox;
	raw(i, 5) = 1;
	raw(i, 6) = dets(i).score(1);
end
% for i = 1:size(raw, 1)
%     ct = bbox2ct(raw(i, 1:4));
%     pose = [ct; ct + poses(raw(i, 5), :)];
%     
%     dets(i) = struct('id', id, 'pose', pose, 'bbox', raw(i, 1:4), 'score', raw(i, 6));
% end

end
