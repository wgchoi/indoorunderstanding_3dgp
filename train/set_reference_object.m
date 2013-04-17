function ptn = set_reference_object(ptn)
objtype = [ptn.parts(:).citype];
humanid = find(objtype == 7);
hloc = [ptn.parts(humanid).dx; ptn.parts(humanid).dz];

% preference
% sofa & chair
mindist = inf;
refpart = -1;
oidx = find(objtype == 1 | objtype == 3);
for i = 1:length(oidx)
    oloc = [ptn.parts(oidx(i)).dx; ptn.parts(oidx(i)).dz];
    d = sqrt(sum((hloc - oloc).^2));
    
    if(d < mindist)
        mindist = d;
        refpart  = oidx(i);
    end
end
ptn.refpart = refpart;
return;

% if(mindist < inf)
%     ptn.refpart = refpart;
%     return;
% end
% others
% oidx = setdiff(1:length(ptn.parts), [humanid, oidx]);
% for i = 1:length(oidx)
%     oloc = [ptn.parts(oidx(i)).dx; ptn.parts(oidx(i)).dz];
%     d = sqrt(sum((hloc - oloc).^2));
%     
%     if(d < mindist)
%         mindist = d;
%         refpart  = oidx(i);
%     end
% end
% ptn.refpart = refpart;
end