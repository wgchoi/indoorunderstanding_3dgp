function [locs, reporjs, heights, maxh] = get_human_iprojections(K, R, poselet)
nobjs = length(poselet.bodies.scores);
locs = zeros(3, nobjs);
for i = 1:nobjs
    [locs(:, i)] = get_torso_iprojection(K, R, poselet.torsos.rts(:, i));
end
[maxh, reporjs, heights] = camera_height_voting(K, R, poselet.bodies.rts, locs, poselet.pose_prob, poselet.bodies.scores, 0:0.05:3);
end
% i = 81

function vote = robust_voting(val, mean, std, trunc)
vote = trunc ^ 2 - ((val - mean) ./ std) .^ 2;
vote(vote < 0) = 0;
end

function [maxh, maxreproj, maxheights] = camera_height_voting(K, R, brects, locs, pose_prob, scores, hrange)
stand_height = 1.7;
sitting_height = 1.2;

maxh = -1;
maxvote = 0; 

reproj = zeros(4, size(locs, 2));
height = zeros(1, size(locs, 2));

weights = scores;
% weights(weights > 5) = 5;

for h = hrange % 0:0.05:3
    for j = 1:size(locs, 2)
        [reproj(:, j), height(j)] = get_reprojection_and_height(K, R, locs(:, j), brects(:, j), h);
    end    
    
    votes = robust_voting(reproj(4, :), brects(4, :), reproj(4, :) ./ 10, 3);
    
    hvote = normpdf(height, stand_height, 0.1) .* pose_prob(:, 1)' + ...
            normpdf(height, sitting_height, 0.1) .* pose_prob(:, 2)';
        
	hvote(hvote < 0.001) = 0.001; 
    hvote = log(hvote) - log(0.001);
    
    votes = votes + hvote;
%     hdiff = reproj(4, :) - brects(4, :);
%     votes = ( hdiff ./  (reproj(4, :) ./ 10) ) .^ 2;
%     votes(votes > 9) = 9;
%     votes = 9 - votes;
    % votes = votes .* weights;
    v = dot(weights, votes);
%     if(h == 1)
%         votes(1:5)
%         votes(1:5) - 5.*hvote(1:5)
%         hvote(1:5)
%         keyboard;
%     elseif(h == 1.5)
%         votes(1:5)
%         votes(1:5) - 5.*hvote(1:5)
%         hvote(1:5)
%         keyboard;
%     end
    if(maxvote < v)
        maxvote = v;
        maxh = h;
        maxreproj = reproj;
        maxheights = height;
    end
end
assert(maxvote >= 9);
end

function [reproj, height] = get_reprojection_and_height(K, R, loc, brect, camheight)

lfeet = loc;
lfeet(2) = -camheight;

ifeet = K * R * lfeet; ifeet = ifeet ./ ifeet(3);

reproj = brect;
reproj(4) = ifeet(2) - reproj(2) + 1;

tpt2 = [brect(1) + brect(3) / 2; brect(2)];
tray3 = (K * R) \ [tpt2; 1];
%%% normalized
tray3 = -sign(tray3(3)) .* tray3 ./ norm(tray3);
tray3 = tray3 ./ tray3(3) * loc(3);

height = tray3(2) - lfeet(2);

end

function [loc] = get_torso_iprojection(K, R, trect)

cpt2 = [trect(1) + trect(3) / 2; trect(2) + trect(4) / 2];
cray3 = (K * R) \ [cpt2; 1];

az = 0;
cam_a = atan2(-cray3(1), -cray3(3));

dp = -2*pi:pi/4:2*pi;
angle = get_closest(dp, az-cam_a);

if(angle < 0)
    angle = angle + 2 * pi;
end
torso_height = 0.45; % about 18 inches

%%% normalized
cray3 = -sign(cray3(3)) .* cray3 ./ norm(cray3);

ltop = cray3;
ltop(2) = ltop(2) + torso_height / 2;
lbtm = cray3;
lbtm(2) = lbtm(2) - torso_height / 2;

itop = K * R * ltop; itop = itop ./ itop(3);
ibtm = K * R * lbtm; ibtm = ibtm ./ ibtm(3);
refh = ibtm(2) - itop(2);

depth = refh / trect(4);
loc = cray3 .* depth;

end

function [loc, reproj, height] = get_one_iprojection(imfile, K, R, camheight, objmodel, trect, brect, option)

cpt2 = [trect(1) + trect(3) / 2; trect(2) + trect(4) / 2];
cray3 = (K * R) \ [cpt2; 1];

az = 0;
cam_a = atan2(-cray3(1), -cray3(3));

dp = -2*pi:pi/4:2*pi;
angle = get_closest(dp, az-cam_a);

if(angle < 0)
    angle = angle + 2 * pi;
end
torso_height = 0.45; % about 18 inches

%%% normalized
cray3 = -sign(cray3(3)) .* cray3 ./ norm(cray3);

ltop = cray3;
ltop(2) = ltop(2) + torso_height / 2;
lbtm = cray3;
lbtm(2) = lbtm(2) - torso_height / 2;

itop = K * R * ltop; itop = itop ./ itop(3);
ibtm = K * R * lbtm; ibtm = ibtm ./ ibtm(3);
refh = ibtm(2) - itop(2);

depth = refh / trect(4);
loc = cray3 .* depth;

lfeet = loc;
lfeet(2) = -camheight;

ifeet = K * R * lfeet; ifeet = ifeet ./ ifeet(3);

reproj = brect;
reproj(4) = ifeet(2) - reproj(2) + 1;

tpt2 = [brect(1) + brect(3) / 2; brect(2)];
tray3 = (K * R) \ [tpt2; 1];
%%% normalized
tray3 = -sign(tray3(3)) .* tray3 ./ norm(tray3);
tray3 = tray3 ./ tray3(3) * loc(3);

height = tray3(2) - lfeet(2);

assert(loc(3) <= 0);
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% debugging
ltop = loc;
ltop(2) = ltop(2) + torso_height / 2;
lbtm = loc;
lbtm(2) = lbtm(2) - torso_height / 2;

itop = K * R * ltop; itop = itop ./ itop(3);
ibtm = K * R * lbtm; ibtm = ibtm ./ ibtm(3);

% imshow(imfile);
rectangle('position', brect, 'edgecolor', 'k', 'linewidth', 2, 'linestyle', '--');
if(reproj(4) > 0)
    rectangle('position', reproj, 'edgecolor', 'r', 'linewidth', 2, 'linestyle', '-.');
end

rectangle('position', trect, 'edgecolor', 'r', 'linewidth', 4);
hold on
plot([itop(1) ibtm(1)], [itop(2) ibtm(2)], 'g--', 'linewidth', 2)
hold off
% rectangle('position', [itop(1) itop(2) 1 ibtm(2)-itop(2)], 'edgecolor', 'g', 'linewidth', 2);
rectangle('position', [ifeet(1) - 30 ifeet(2) - 2 60 4], 'edgecolor', 'g', 'linewidth', 2);

ict = K * R * loc; ict = ict ./ ict(3);
rectangle('position', [ict(1) - 2 ict(2) - 2 4 4], 'edgecolor', 'b', 'linewidth', 2);
ict = K * R * (loc - [0.15; torso_height / 2; 0]); ict = ict ./ ict(3);
rectangle('position', [ict(1) - 2 ict(2) - 2 4 4], 'edgecolor', 'b', 'linewidth', 2);
ict = K * R * (loc - [-0.15; torso_height / 2; 0]); ict = ict ./ ict(3);
rectangle('position', [ict(1) - 2 ict(2) - 2 4 4], 'edgecolor', 'b', 'linewidth', 2);
ict = K * R * (loc - [0.15; -torso_height / 2; 0]); ict = ict ./ ict(3);
rectangle('position', [ict(1) - 2 ict(2) - 2 4 4], 'edgecolor', 'b', 'linewidth', 2);
ict = K * R * (loc - [-0.15; -torso_height / 2; 0]); ict = ict ./ ict(3);
rectangle('position', [ict(1) - 2 ict(2) - 2 4 4], 'edgecolor', 'b', 'linewidth', 2);

trect
text(1, 1, ['depth : ' num2str(depth, '%.03f')],  'backgroundcolor', 'w');

pause

% dlist = [0.01:0.1:1, logspace(0, 3, 100)];
% % for depth = 0.1:0.1:50
% for depth = dlist
%     loc = -sign(cray3(3)) * cray3 .* (depth / norm(cray3));
%     [cube] = get3DObjectCube(loc, objmodel.width(mid), objmodel.height(mid), objmodel.depth(mid), angle);
%     [~, pbbox] = get2DCubeProjection(K, R, cube);
%     
%     dheight = abs(rect(4) - pbbox(4)) / rect(4);
%     
%     cnt  = cnt  + 1;
%     if(any(cube(3, :) > 0))
%         continue;
%     end
%     
%     if(dheight < 0.5)
%        if(mindiff > dheight)
%            mindiff = dheight;
%            best_depth = depth;
%        elseif(mindiff * 2 < dheight)
%            break;
%        end
%     end
% end
% 
% h = struct( 'oid', -1, 'locs', zeros(3, 27), ...
%             'cubes', zeros(3, 8, 27), ...
%             'polys', zeros(2, 8, 27), ...
%             'bbs', zeros(4, 27), ...
%             'ovs', zeros(1, 27), ...
%             'diff', zeros(1, 27), ...
%             'azimuth', attr(3), ... % notice that this angle is azimuth defined in image plane!!!
%             'angle', angle ); 
%         
% % invalid detection will be filtered out!
% if(mindiff > 0.5)
%     return;
% end
% 
% % valid!
% h.oid = attr(1);
% 
% % cnt
% % if(mindiff > 0.5)
% %     keyboard;
% % end
% assert(mindiff < 0.5);
% 
% if(option == 0)
% 	loc = -sign(cray3(3)) * cray3 .* (best_depth / norm(cray3));
% 	[cube] = get3DObjectCube(loc, objmodel.width(mid), objmodel.height(mid), objmodel.depth(mid), angle);
% 	[ppoly, pbbox] = get2DCubeProjection(K, R, cube);
% 	maxov = boxoverlap(rect2bbox(pbbox), rect2bbox(rect));
% 	% subplot(121);
% 	% imshow(imfile);
% 	% hold on;
% 	% rectangle('position', rect, 'edgecolor', 'k', 'LineStyle', '--', 'linewidth', 3);
% 	% rectangle('position', pbbox, 'edgecolor', 'r', 'LineStyle', '-.', 'linewidth', 4);
% 	% idx= [1 2 4 3 1 5 6 8 7 5];
% 	% plot(ppoly(1, idx), ppoly(2, idx), 'w-', 'linewidth', 2);
% 	% hold off;
% 	% pause
% 	while(1)
% 		% dv = zeros(3, 27);
% 		cnt = 1;
% 		for dx = [-1 0 1]
% 			for dy = [-1 0 1]
% 				for dz = [-1 0 1]
% 					h.locs(:, cnt) = loc + [dx; dy; dz] .* dstep;
% 					h.cubes(:, :, cnt) = get3DObjectCube(h.locs(:, cnt), objmodel.width(mid), objmodel.height(mid), objmodel.depth(mid), angle);
% 					[h.polys(:, :, cnt), h.bbs(:, cnt)] = get2DCubeProjection(K, R, h.cubes(:, :, cnt));
% 					% dv(:, cnt) = [dx; dy; dz];
% 					cnt = cnt + 1;
% 				end
% 			end
% 		end
% 		h.bbs(3:4, :) = h.bbs(3:4, :) + h.bbs(1:2, :) - 1;
% 		h.ovs = boxoverlap(h.bbs', rect2bbox(rect));
% 		
% 		[val, idx] = max(h.ovs);
% 		if(maxov < val)
% 			loc = h.locs(:, idx);
% 			maxov = val;
% 		else
% 			break;
% 		end
% 	end
% elseif(option == 1)
% 	loc = -sign(cray3(3)) * cray3 .* (best_depth / norm(cray3));
% 	[cube] = get3DObjectCube(loc, objmodel.width(mid), objmodel.height(mid), objmodel.depth(mid), angle);
% 	[ppoly, pbbox] = get2DCubeProjection(K, R, cube);
% 	mindiff = sum((rect2btm(pbbox(:)) - rect2btm(rect(:))) .^ 2 );
% 
% 	while(1)
% 		% dv = zeros(3, 27);
% 		cnt = 1;
% 		for dx = [-1 0 1]
% 			for dy = [-1 0 1]
% 				for dz = [-1 0 1]
% 					h.locs(:, cnt) = loc + [dx; dy; dz] .* dstep;
% 					h.cubes(:, :, cnt) = get3DObjectCube(h.locs(:, cnt), objmodel.width(mid), objmodel.height(mid), objmodel.depth(mid), angle);
% 					[h.polys(:, :, cnt), h.bbs(:, cnt)] = get2DCubeProjection(K, R, h.cubes(:, :, cnt));
% 					cnt = cnt + 1;
% 				end
% 			end
% 		end
% 		
% 		h.diff = sum((rect2btm(h.bbs) - repmat(rect2btm(rect(:)), 1, 27)) .^ 2, 1);
% 		h.bbs(3:4, :) = h.bbs(3:4, :) + h.bbs(1:2, :) - 1;
% 
% 		[val, idx] = min(h.diff);
% 		if(mindiff < val)
% 			loc = h.locs(:, idx);
% 			mindiff = val;
% 		else
% 			break;
% 		end
% 	end
% 
% end

end

% 
% function dets = parseDets(poselet)
% % do 
% dets = zeros(length(data.bodies.scores), 8);
% dets(:, end) = data.bodies.scores;
% dets(:, 4:7) = data.bodies.rts';
% dets(:, 6:7) = dets(:, 4:5) + dets(:, 6:7) - 1;
% dets(:, 2) = 1; % standing humans
% dets(:, 1) = 7;
% 
% end
