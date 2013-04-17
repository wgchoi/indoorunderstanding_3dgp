function [ walliuerr ]=getWallerr_interun(gtPolyg,Polyg)
%function [ walliuerr ]=getWallerr_interun(gtPolyg,Polyg,img_id)
% Input
%   1) gtPolyg:     ground-truth polygons (1x5)
%   2) Polyg:       estimated polygons (1x5)
% Output
%   1) walliuerr:   wall intersection-union error (5x1)

% Get areas of GT and estimation
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

walliuerr = zeros(5, 1);

% For ground and ceiling
for i = [1 5]
    nInter = oneFaceErr(gtPolyg, Polyg, farea1, farea2, i, i);
    walliuerr(i) = GetIUError(nInter, gtPolyg, Polyg, i, i);
    %walliuerr(i) = GetIUError(nInter, gtPolyg, Polyg, i, i, img_id);
end

% For center, right wall, and left wall
if(sum(farea1(2:4) > 0) == 2)
    
    temp = zeros(3, 3);
    
    % 2 : c, 3 : r, 4 : l
    for i = 2:4
        nInter = oneFaceErr(gtPolyg, Polyg, farea1, farea2, i, i);
        temp(1, i-1) = GetIUError(nInter, gtPolyg, Polyg, i, i);
        %temp(1, i-1) = GetIUError(nInter, gtPolyg, Polyg, i, i, img_id);
    end
    
    % c => r , l => c
    match = [0 3 4 2 0];
    for i = 2:4
        nInter = oneFaceErr(gtPolyg, Polyg, farea1, farea2, i, match(i));
        temp(2, i-1) = GetIUError(nInter, gtPolyg, Polyg, i, match(i));
        %temp(2, i-1) = GetIUError(nInter, gtPolyg, Polyg, i, match(i), img_id);
    end
    
    % c => l , r => c
    match = [0 4 2 3 0];
    for i = 2:4
        nInter = oneFaceErr(gtPolyg, Polyg, farea1, farea2, i, match(i));
        temp(3, i-1) = GetIUError(nInter, gtPolyg, Polyg, i, match(i));
        %temp(3, i-1) = GetIUError(nInter, gtPolyg, Polyg, i, match(i), img_id);
    end
    
    [~, id] = min(sum(temp, 2));
    walliuerr(2:4) = temp(id, :)';
    
else
    
    for i = 2:4
        nInter = oneFaceErr(gtPolyg, Polyg, farea1, farea2, i, i);
        walliuerr(i) = GetIUError(nInter, gtPolyg, Polyg, i, i);
        %walliuerr(i) = GetIUError(nInter, gtPolyg, Polyg, i, i, img_id);
    end
    
end

return;

end

function nInter = oneFaceErr(gtPolyg, Polyg, farea1, farea2, i, j)
% Find intersection area of fields

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
    
    in1 = inpolygon(XX1,YY1,[XX2;XX2(1)],[YY2;YY2(1)]);
    in2 = inpolygon(XX2,YY2,[XX1;XX1(1)],[YY1;YY1(1)]);

    if numel(find(in1==1))==length(in1)
        X0=XX1;Y0=YY1;
    elseif numel(find(in2==1))==length(in2)
        X0=XX2;Y0=YY2;
    else
        [in,on]=inpolygon(XX2,YY2,[XX1;XX1(1)],[YY1;YY1(1)]);
        XX2(find(on)) = XX2(find(on))+1;
        YY2(find(on)) = YY2(find(on))+1;
        [in,on]=inpolygon(XX1,YY1,[XX2;XX2(1)],[YY2;YY2(1)]);
        XX1(find(on)) = XX1(find(on))+1;
        YY1(find(on)) = YY1(find(on))+1;
%             [X0 Y0 ind]=polyints(XX1,YY1,XX2,YY2); %remember to check polybool
        [XX1, YY1] = poly2cw(XX1, YY1);
        [XX2, YY2] = poly2cw(XX2, YY2);
        [X0 Y0] = polybool('intersection',XX1,YY1,XX2,YY2); 
    end
    
    if numel(X0)>0
        nInter=polyarea([X0; X0(1)],[Y0;Y0(1)]);
    else
        nInter=0;
    end
end

end

function IUerror = GetIUError(nInter,gtPolyg,Polyg,i,j)
%function IUerror = GetIUError(nInter,gtPolyg,Polyg,i,j,img_id)

if nInter == -1
    IUerror = 0;
elseif nInter == 0
    IUerror = 1;
else
    XX1=gtPolyg{i}(:,1);
    YY1=gtPolyg{i}(:,2);
    XX2=Polyg{j}(:,1);
    YY2=Polyg{j}(:,2); 
    [XX1, YY1] = poly2cw(XX1, YY1);
    [XX2, YY2] = poly2cw(XX2, YY2);
    [XXu, YYu] = polybool('union',XX1,YY1,XX2,YY2);  % Compute union polygon
    if sum(isnan(XXu)) ~=0  
        % Two reasons causing NaN: 
        %    1) GT is not a polygon (edge intersection)
        %    2) No union
        %fprintf('NaN value occurs at image %d!!\n',img_id);
        XXu = XXu(~isnan(XXu));
        YYu = YYu(~isnan(YYu));
    end
    fareau=polyarea(XXu,YYu);
    IUerror = 1 - nInter/fareau;
end 

end