function fig = sp_progress_bar(fig,nf,Nf,ni,Ni,str)

if nargin > 1
    clf(fig)
    if(~exist('str','var'))
        str = 'Step: ';
    end
    ha = subplot(2,1,1, 'parent', fig); cla(ha)
    p = patch([0 1 1 0],[0 0 1 1],'w','EraseMode','none', 'parent', ha);
    p = patch([0 1 1 0]*nf/Nf,[0 0 1 1],'g','EdgeColor','k','EraseMode','none', 'parent', ha);
    axis(ha,'off')
    title(sprintf('%s %d of %d',str,nf,Nf), 'parent', ha)
    ha = subplot(2,1,2, 'parent', fig); cla(ha)
    p = patch([0 1 1 0],[0 0 1 1],'w','EraseMode','none', 'parent', ha);
    p = patch([0 1 1 0]*ni/Ni,[0 0 1 1],'r','EdgeColor','k','EraseMode','none', 'parent', ha);
    axis(ha,'off')
    title(sprintf('%d/%d (%.1f/%.1f mins)',ni,Ni,toc/60,(Ni/ni)*(toc/60)), 'parent', ha)
    drawnow
else
    
    % Create counter figure
    screenSize = get(0,'ScreenSize');
    pointsPerPixel = 72/get(0,'ScreenPixelsPerInch');
    width = 360 * pointsPerPixel;
    height = 2* 75 * pointsPerPixel;
    pos = [screenSize(3)/2-width/2 screenSize(4)/2-height/2 width height];
    titleStr = '';
    if(exist('fig','var'))
        titleStr = fig;
    end
    fig = figure('Units', 'points', ...
        'NumberTitle','off', ...
        'Name',titleStr, ...
        'IntegerHandle','off', ...
        'MenuBar', 'none', ...
        'Visible','on',...
        'position', pos,...
        'BackingStore','off',...
        'DoubleBuffer','on');
    %tic;
end
