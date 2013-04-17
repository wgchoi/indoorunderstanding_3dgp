function [pixerr]=getPixerr(gtPolyg,Polyg)
% farea1=farea;
farea1=zeros(1,5);
farea2=zeros(1,5);
for i=1:numel(gtPolyg)
    if size(gtPolyg{i},1)>0
        farea1(i)=polyarea([gtPolyg{i}(:,1);gtPolyg{i}(1,1)],[gtPolyg{i}(:,2);gtPolyg{i}(1,2)]);
    end
    if size(Polyg{i},1)>0
        farea2(i)=polyarea([Polyg{i}(:,1);Polyg{i}(1,1)],[Polyg{i}(:,2);Polyg{i}(1,2)]);
    end
end

err = zeros(1, 5);
% Find intersection area of fields
for i = [1 5]
    nInter = oneFaceErr(gtPolyg, Polyg, farea1, farea2, i, i);
    if(nInter < 0), continue; end
    % Fdiff(cnt)=1-nInter/(farea1(i)+farea2(i)-nInter);
    err(i) = farea1(i)-nInter;
end
if(sum(farea1(2:4) > 0) == 2)
    temp = zeros(3, 3);
    % 2 : c, 3 : r, 4 : l
    for i = 2:4
        nInter = oneFaceErr(gtPolyg, Polyg, farea1, farea2, i, i);
        if(nInter < 0), continue; end
        temp(1, i-1) = farea1(i)-nInter;
    end
    
    % c => r , l => c
    match = [0 3 4 2 0];
    for i = 2:4
        nInter = oneFaceErr(gtPolyg, Polyg, farea1, farea2, i, match(i));
        if(nInter < 0), continue; end
        temp(2, i-1) = farea1(i)-nInter;
    end
    
    % c => l , r => c
    match = [0 4 2 3 0];
    for i = 2:4
        nInter = oneFaceErr(gtPolyg, Polyg, farea1, farea2, i, match(i));
        if(nInter < 0), continue; end
        temp(3, i-1) = farea1(i)-nInter;
    end
    [~, id] = min(sum(temp, 2));
    err(2:4) = temp(id, :);
else
    for i = 2:4
        nInter = oneFaceErr(gtPolyg, Polyg, farea1, farea2, i, i);
        if(nInter < 0), continue; end
        err(i) = farea1(i)-nInter;
    end
end

% pixerr1=mean(Fdiff);
pixerr=sum(err)/sum(farea1);

return;

function nInter = oneFaceErr(gtPolyg, Polyg, farea1, farea2, i, j)

nInter = -1;
if (farea1(i) == 0 && farea2(j) == 0)
    %if both the fields are invisible dont count
elseif (farea1(i) > 0 && farea2(j) == 0)
    nInter = 0;
elseif (farea1(i) == 0 && farea2(j) > 0)
    nInter = 0;
else % (farea1(i) > 0 && farea2(i) > 0)
    XX1=gtPolyg{i}(:,1);
    YY1=gtPolyg{i}(:,2);
    
    XX2=Polyg{j}(:,1);
    YY2=Polyg{j}(:,2); %get the polygon
    
    [XX1, YY1] = poly2cw(XX1, YY1);
    [XX2, YY2] = poly2cw(XX2, YY2);
    
    [X0 Y0] = polybool('intersection',XX1,YY1,XX2,YY2); 
    idx = isnan(X0) | isnan(Y0);

    X0(idx) = [];
    Y0(idx) = [];
%     in1 = inpolygon(XX1,YY1,[XX2;XX2(1)],[YY2;YY2(1)]);
%     in2 = inpolygon(XX2,YY2,[XX1;XX1(1)],[YY1;YY1(1)]);
% 
%     if numel(find(in1==1))==length(in1)
%         X0=XX1;Y0=YY1;
%     elseif numel(find(in2==1))==length(in2)
%         X0=XX2;Y0=YY2;
%     else
%         [~, on]=inpolygon(XX2,YY2,[XX1;XX1(1)],[YY1;YY1(1)]);
%         XX2(find(on)) = XX2(find(on))+1;
%         YY2(find(on)) = YY2(find(on))+1;
%         [~, on]=inpolygon(XX1,YY1,[XX2;XX2(1)],[YY2;YY2(1)]);
%         XX1(find(on)) = XX1(find(on))+1;
%         YY1(find(on)) = YY1(find(on))+1;
% %             [X0 Y0 ind]=polyints(XX1,YY1,XX2,YY2); %remember to check polybool
%         [XX1, YY1] = poly2cw(XX1, YY1);
%         [XX2, YY2] = poly2cw(XX2, YY2);
%         [X0 Y0] = polybool('intersection',XX1,YY1,XX2,YY2); 
%         idx = isnan(X0) | isnan(Y0);
%         
%         X0(idx) = [];
%         Y0(idx) = [];
%     end
    
    if numel(X0)>0
        nInter=polyarea([X0; X0(1)],[Y0;Y0(1)]);
    else
        nInter=0;
    end
end
