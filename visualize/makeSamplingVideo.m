% function mov = makeSamplingVideo(x, iclusters, spg)
function mov = makeSamplingVideo(datafile)
load(datafile);

if nargout > 0
    rec = true;
else
    rec = false;
end
if(rec)
    mov(1:2500) = struct('cdata', uint8(zeros(343, 870, 3)),...
                            'colormap', []);
end                    
temp = zeros(1, length(spg));
for i = 1:length(spg)
    temp(i) = spg(i).lkhood;
end

%% initial sample
show2DGraph(spg(1), x, iclusters);
str = ['Initial sample, lkhood : ' num2str(spg(1).lkhood, '%.03f')];
text(10, 20, str, 'backgroundcolor', 'w', 'edgecolor', 'k', 'linewidth', 2);
figure(2);
[h,C]=hist(temp, 100);
idx = max(sum(C < spg(1).lkhood), 1);
hist(temp, 100);
arrow([spg(1).lkhood+1 h(idx) + max(h) * .1], [spg(1).lkhood h(idx)], 'facecolor', 'r', 'edgecolor', 'r');
grid on;
%%%
if(rec)
    figure(1);
    im1 = getframe;
    im1.cdata = imresize(im1.cdata, [343 435]);
    figure(2)
    im2 = getframe;
    im2.cdata = imresize(im2.cdata, [343 435]);
    for i = 1:60
        mov(i).cdata(:,1:435, :) = im1.cdata;
        mov(i).cdata(:,436:end, :) = im2.cdata;
    end
end
pause(1);
%% max sample
[~, midx] = max(temp);
show2DGraph(spg(midx), x, iclusters);
str = ['Best sample, lkhood : ' num2str(spg(midx).lkhood, '%.03f')];
text(10, 20, str, 'backgroundcolor', 'w', 'edgecolor', 'k', 'linewidth', 2);
figure(2);
[h,C]=hist(temp, 100);
idx = sum(C < spg(midx).lkhood);
hist(temp, 100);
arrow([spg(midx).lkhood+1 h(idx) + max(h) * .1], [spg(midx).lkhood h(idx)], 'facecolor', 'r', 'edgecolor', 'r');
grid on;
%%%
if(rec)
    figure(1);
    im1 = getframe;
    im1.cdata = imresize(im1.cdata, [343 435]);
    figure(2)
    im2 = getframe;
    im2.cdata = imresize(im2.cdata, [343 435]);
    for i = 61:120
        mov(i).cdata(:,1:435, :) = im1.cdata;
        mov(i).cdata(:,436:end, :) = im2.cdata;
    end
end
pause(1);
%%
step = 10;
ibase = 121;
for i = 1:step:length(spg)
    figure(1);
    show2DGraph(spg(i), x, iclusters);
    str = ['Sample ' num2str(i, '%05d') ' lkhood : ' num2str(spg(i).lkhood, '%.03f')];
    text(10, 20, str, 'backgroundcolor', 'w', 'edgecolor', 'k', 'linewidth', 2);
    
    figure(2);
    plot(temp(1:step:i), '-');
    if(i < 50*step)
        axis([1, 20*step, min(temp), max(temp)])
    elseif(i < 500*step)
        axis([1, 200*step, min(temp), max(temp)])
    else
        axis([1, length(spg)/step, min(temp), max(temp)])
    end
    grid on;
    drawnow;
    %%%
    if(rec)
        figure(1);
        im1 = getframe;
        im1.cdata = imresize(im1.cdata, [343 435]);
        figure(2)
        im2 = getframe;
        im2.cdata = imresize(im2.cdata, [343 435]);
        for j = 1:3
            mov(ibase).cdata(:,1:435, :) = im1.cdata;
            mov(ibase).cdata(:,436:end, :) = im2.cdata;
            ibase = ibase + 1;
            if(ibase > 2500)
                mov(ibase) = struct('cdata', uint8(zeros(343, 870, 3)),...
                            'colormap', []);
            end
        end
    end
end

end