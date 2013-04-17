function [original, oracle] = show_testlayout(data, results, lerr, show_mode, outdir)

if nargin < 4
    show_mode = 1;
    outdir = [];
elseif nargin < 5
    outdir = [];
end

if(~isempty(outdir))
    mkdir(outdir);
end

for i = 1:length(data)
    % data(i).x.lerr(length(data(i).x.lconf)+1:end) = [];
    original(i) = data(i).x.lerr(1);
    [oracle(i), oracle_idx(i)] = min(data(i).x.lerr);
end

for i = 1:length(data)
    gain(i) = data(i).x.lerr(1) - lerr(i);
    oracle_gain(i) = data(i).x.lerr(1) - data(i).x.lerr(oracle_idx(i));
end

if(show_mode == 1)
    [vv, idx] = sort(gain, 'descend');
    idx(vv <= 0) = [];
    prefix = 'better';
elseif(show_mode == 2)
    [vv, idx] = sort(gain, 'ascend');
    idx(vv >= 0) = [];
    prefix = 'worse';
elseif(show_mode == 3)
    % no ordering
    idx = 1:length(gain);
    prefix = 'noordering';
else
    idx = find(gain == 0);
    prefix = 'equal';
end

btm_idx = [1 2 6 5 1];
for ii = 1:length(idx)
    i = idx(ii);
%     if( (lerr(i) < data(i).x.lerr(1) && show_mode == 1) ...
%         || (lerr(i) > data(i).x.lerr(1) && show_mode == 0))
%     end
    imshow(data(i).x.imfile);

    hold on;
    objidx = getObjIndices(data(i).gpg, data(i).iclusters);
    for obj = 1:length(objidx)
        if(isfield(data(i).x, 'hobjs'))
            objpoly = data(i).x.hobjs(objidx(obj)).polys(:, btm_idx, data(i).gpg.subidx(obj));
        else
            objpoly = data(i).x.projs(objidx(obj)).poly(:, btm_idx);
        end        
        plot(objpoly(1, :), objpoly(2, :), 'b.--', 'linewidth', 3);
        
        [ipoly, opoly] = get_inner_outer_polys(objpoly);
        
        plot(ipoly(1, :), ipoly(2, :), 'r.--', 'linewidth', 2);
        plot(opoly(1, :), opoly(2, :), 'k.--', 'linewidth', 2);
    end

    poly = data(i).x.lpolys(1, :);
    draw_poly(poly, 'r', 3, '--');

    poly = data(i).x.lpolys(results(i), :);
    draw_poly(poly, 'g', 4, '-');
    
    % oracle_idx(i)
    poly = data(i).x.lpolys(oracle_idx(i), :);
    draw_poly(poly, 'y', 2, '--');

    text(10, 60, {['image' num2str(i, '%03d')], ...
                    [' gain: ' num2str(gain(i) * 100, '%.02f') '%'], ...
                    [' oracle gain: ' num2str(oracle_gain(i) * 100, '%.02f') '%'], ...
                    [' org conf: ' num2str(data(i).x.lconf(1), '%.02f')], ...
                    [' oracle conf: ' num2str(data(i).x.lconf(oracle_idx(i)), '%.02f')], ...
                    [' result conf: ' num2str(data(i).x.lconf(results(i)), '%.02f')]}, 'backgroundcolor', 'w');

    hold off;
    if isempty(outdir)
        pause
    else
        drawnow;
        print('-djpeg', fullfile(outdir, [prefix '_' num2str(ii) '.jpg']));
    end
end

end


function draw_poly(poly, c, width, type)

for f=1:numel(poly)
    if numel(poly{f})>0
      plot([poly{f}(:,1); poly{f}(1,1)],[poly{f}(:,2); poly{f}(1,2)],type, 'LineWidth',width,...
            'Color', c);
    end
end

end