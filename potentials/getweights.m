% should be paired with features.m
function w = getweights(model)

if(~isfield(model, 'feattype') || strcmp(model.feattype, 'type1'))
    w = getweights1(model);
elseif(strcmp(model.feattype, 'type2'))
    w = getweights2(model);
elseif(strcmp(model.feattype, 'type3'))
    w = getweights3(model);
elseif(strcmp(model.feattype, 'type5'))
    w = getweights5(model);    
elseif(strcmp(model.feattype, 'type6'))
    w = getweights6(model);    
elseif(strcmp(model.feattype, 'itm_v0'))
    w = getweights_itm0(model);    
elseif(strcmp(model.feattype, 'itm_v1'))
    w = getweights_itm1(model);    
elseif(strcmp(model.feattype, 'itm_v2'))
    w = getweights_itm2(model);        
elseif(strcmp(model.feattype, 'itm_v3'))
    w = getweights_itm3(model);        
end

end

function w = getweights_itm3(model)
featlen =   1 + ... % scene classification 
            1 + ... % layout confidence : no bias required, selection problem    
            2 * model.nobjs + ... % object confidence : (weight + bias) per type
            model.nobjs + 1 + ...  % object-wall inclusion + floor area prior
            ( (model.nobjs+1) * model.nscene ) + ... % semantic constext
            sum(model.itmfeatlen) + ... % intearction templates!
            2 + ... % object-object interaction : 2D bboverlap, 2D polyoverlap
            model.nobjs + ...         % projection-deformation cost
            1;              % floor distance


w = zeros(featlen, 1);
ibase = 1;
% scene classification 
w(ibase) = model.w_os;
ibase = ibase + 1;
% layout confidence 
w(ibase) = model.w_or;
ibase = ibase + 1;
% object confidence
w(ibase:ibase+2*model.nobjs-1) = model.w_oo;
ibase = ibase+2*model.nobjs;
% object-wall inclusion 
w(ibase:ibase + (model.nobjs + 1) - 1) = model.w_ior;
ibase = ibase + model.nobjs + 1;
% semantic constext
w(ibase:ibase+model.nscene*(model.nobjs+1)-1) = model.w_iso;
ibase = ibase + model.nscene*(model.nobjs+1);
% intearction templates!
for i = 1:length(model.itmptns)
    w(ibase:ibase+model.itmfeatlen(i)-1) = getITMweights2(model.itmptns(i));
    ibase = ibase + model.itmfeatlen(i);
end
% object-object interaction
w(ibase:ibase+1) = model.w_ioo;
ibase = ibase + 2;
% projection-deformation cost
w(ibase:ibase+model.nobjs-1) = model.w_iod;
ibase = ibase + model.nobjs;
% floor distance
w(ibase) = model.w_iof;
ibase = ibase + 1;

assert(featlen == ibase - 1);

end

function w = getweights_itm2(model)
featlen =   1 + ... % scene classification 
            1 + ... % layout confidence : no bias required, selection problem    
            2 * model.nobjs + ... % object confidence : (weight + bias) per type
            model.nobjs + 1 + ...  % object-wall inclusion + floor area prior
            ( model.nobjs * model.nscene ) + ... % semantic constext
            sum(model.itmfeatlen) + ... % intearction templates!
            2 + ... % object-object interaction : 2D bboverlap, 2D polyoverlap
            model.nobjs + ...         % projection-deformation cost
            1;              % floor distance


w = zeros(featlen, 1);
ibase = 1;
% scene classification 
w(ibase) = model.w_os;
ibase = ibase + 1;
% layout confidence 
w(ibase) = model.w_or;
ibase = ibase + 1;
% object confidence
w(ibase:ibase+2*model.nobjs-1) = model.w_oo;
ibase = ibase+2*model.nobjs;
% object-wall inclusion 
w(ibase:ibase + (model.nobjs + 1) - 1) = model.w_ior;
ibase = ibase + model.nobjs + 1;
% semantic constext
w(ibase:ibase+model.nscene*model.nobjs-1) = model.w_iso;
ibase = ibase + model.nscene*model.nobjs;
% intearction templates!
for i = 1:length(model.itmptns)
    w(ibase:ibase+model.itmfeatlen(i)-1) = getITMweights(model.itmptns(i));
    ibase = ibase + model.itmfeatlen(i);
end
% object-object interaction
w(ibase:ibase+1) = model.w_ioo;
ibase = ibase + 2;
% projection-deformation cost
w(ibase:ibase+model.nobjs-1) = model.w_iod;
ibase = ibase + model.nobjs;
% floor distance
w(ibase) = model.w_iof;
ibase = ibase + 1;

assert(featlen == ibase - 1);

end

function w = getweights_itm1(model)
featlen =   1 + ... % scene classification 
            1 + ... % layout confidence : no bias required, selection problem    
            2 * model.nobjs + ... % object confidence : (weight + bias) per type
            model.nobjs*( length(model.ow_edge) - 1 ) + ... % object-wall inclusion 
            ( model.nobjs * model.nscene ) + ... % semantic constext
            sum(model.itmfeatlen) + ... % intearction templates!
            2 + ... % object-object interaction : 2D bboverlap, 2D polyoverlap
            model.nobjs + ...         % projection-deformation cost
            1;              % floor distance


w = zeros(featlen, 1);
ibase = 1;
% scene classification 
w(ibase) = model.w_os;
ibase = ibase + 1;
% layout confidence 
w(ibase) = model.w_or;
ibase = ibase + 1;
% object confidence
w(ibase:ibase+2*model.nobjs-1) = model.w_oo;
ibase = ibase+2*model.nobjs;
% object-wall inclusion 
w(ibase:ibase+(model.nobjs*(length(model.ow_edge)-1))-1) = model.w_ior;
ibase = ibase + model.nobjs*(length(model.ow_edge)-1);
% semantic constext
w(ibase:ibase+model.nscene*model.nobjs-1) = model.w_iso;
ibase = ibase + model.nscene*model.nobjs;
% intearction templates!
for i = 1:length(model.itmptns)
    w(ibase:ibase+model.itmfeatlen(i)-1) = getITMweights(model.itmptns(i));
    ibase = ibase + model.itmfeatlen(i);
end
% object-object interaction
w(ibase:ibase+1) = model.w_ioo;
ibase = ibase + 2;
% projection-deformation cost
w(ibase:ibase+model.nobjs-1) = model.w_iod;
ibase = ibase + model.nobjs;
% floor distance
w(ibase) = model.w_iof;
ibase = ibase + 1;

assert(featlen == ibase - 1);

end


function w = getweights_itm0(model)
featlen =   1 + ... % scene classification 
            1 + ... % layout confidence : no bias required, selection problem    
            2 * model.nobjs + ... % object confidence : (weight + bias) per type
            ( length(model.ow_edge) - 1 ) + ... % object-wall inclusion 
            ( model.nobjs * model.nscene ) + ... % semantic constext
            sum(model.itmfeatlen) + ... % intearction templates!
            2 + ... % object-object interaction : 2D bboverlap, 2D polyoverlap
            1 + ...         % projection-deformation cost
            1;              % floor distance


w = zeros(featlen, 1);
ibase = 1;
% scene classification 
w(ibase) = model.w_os;
ibase = ibase + 1;
% layout confidence 
w(ibase) = model.w_or;
ibase = ibase + 1;
% object confidence
w(ibase:ibase+2*model.nobjs-1) = model.w_oo;
ibase = ibase+2*model.nobjs;
% object-wall inclusion 
w(ibase:ibase+length(model.ow_edge)-2) = model.w_ior;
ibase = ibase + length(model.ow_edge) - 1;
% semantic constext
w(ibase:ibase+model.nscene*model.nobjs-1) = model.w_iso;
ibase = ibase + model.nscene*model.nobjs;
% intearction templates!
for i = 1:length(model.itmptns)
    w(ibase:ibase+model.itmfeatlen(i)-1) = getITMweights(model.itmptns(i));
    ibase = ibase + model.itmfeatlen(i);
end
% object-object interaction
w(ibase:ibase+1) = model.w_ioo;
ibase = ibase + 2;
% projection-deformation cost
w(ibase) = model.w_iod;
ibase = ibase + 1;
% floor distance
w(ibase) = model.w_iof;
ibase = ibase + 1;

assert(featlen == ibase - 1);

end


function w = getweights6(model)
featlen =   1 + ... % scene classification 
            1 + ... % layout confidence : no bias required, selection problem    
            2 * model.nobjs + ... % object confidence : (weight + bias) per type
            model.nobjs * ( length(model.ow_edge) - 1 ) + ... % object-wall inclusion 
            ( model.nobjs * model.nscene ) + ... % semantic constext
            0 + ... % intearction templates!
            2 + ... % object-object interaction : 2D bboverlap, 2D polyoverlap
            model.nobjs + ...         % projection-deformation cost
            1;              % floor distance


w = zeros(featlen, 1);
ibase = 1;
% scene classification 
w(ibase) = model.w_os;
ibase = ibase + 1;
% layout confidence 
w(ibase) = model.w_or;
ibase = ibase + 1;
% object confidence
w(ibase:ibase+2*model.nobjs-1) = model.w_oo;
ibase = ibase+2*model.nobjs;
% object-wall inclusion 
w(ibase:ibase+(model.nobjs*(length(model.ow_edge)-1))-1) = model.w_ior;
ibase = ibase + model.nobjs*(length(model.ow_edge)-1);
% semantic constext
w(ibase:ibase+model.nscene*model.nobjs-1) = model.w_iso;
ibase = ibase + model.nscene*model.nobjs;
% intearction templates!

% object-object interaction
w(ibase:ibase+1) = model.w_ioo;
ibase = ibase + 2;
% projection-deformation cost
w(ibase:ibase+model.nobjs-1) = model.w_iod;
ibase = ibase + model.nobjs;
% floor distance
w(ibase) = model.w_iof;
ibase = ibase + 1;

assert(featlen == ibase - 1);

end

function w = getweights5(model)
featlen =   1 + ... % scene classification 
            1 + ... % layout confidence : no bias required, selection problem    
            2 * model.nobjs + ... % object confidence : (weight + bias) per type
            ( length(model.ow_edge) - 1 ) + ... % object-wall inclusion 
            ( model.nobjs * model.nscene ) + ... % semantic constext
            0 + ... % intearction templates!
            2 + ... % object-object interaction : 2D bboverlap, 2D polyoverlap
            1 + ...         % projection-deformation cost
            1;              % floor distance


w = zeros(featlen, 1);
ibase = 1;
% scene classification 
w(ibase) = model.w_os;
ibase = ibase + 1;
% layout confidence 
w(ibase) = model.w_or;
ibase = ibase + 1;
% object confidence
w(ibase:ibase+2*model.nobjs-1) = model.w_oo;
ibase = ibase+2*model.nobjs;
% object-wall inclusion 
w(ibase:ibase+length(model.ow_edge)-2) = model.w_ior;
ibase = ibase + length(model.ow_edge) - 1;
% semantic constext
w(ibase:ibase+model.nscene*model.nobjs-1) = model.w_iso;
ibase = ibase + model.nscene*model.nobjs;
% intearction templates!

% object-object interaction
w(ibase:ibase+1) = model.w_ioo;
ibase = ibase + 2;
% projection-deformation cost
w(ibase) = model.w_iod;
ibase = ibase + 1;
% floor distance
w(ibase) = model.w_iof;
ibase = ibase + 1;

assert(featlen == ibase - 1);

end

function w = getweights3(model)
featlen =   1 + ... % layout confidence : no bias required, selection problem    
            2 + ... % object pairs : 2D bboverlap
            (length(model.ow_edge) - 1) + ... % object inclusion : 3D volume intersection
            1 + ...       % projection-deformation cost
            1 + ...       % floor distance
            2 * model.nobjs;      % object confidence : (weight + bias) per type

w = zeros(featlen, 1);
ibase = 1;
w(ibase) = model.w_or;
ibase = ibase + 1;
w(ibase:ibase+1) = model.w_ioo;
ibase = ibase + 2;
w(ibase:ibase+length(model.ow_edge)-2) = model.w_ior;
ibase = ibase + length(model.ow_edge) - 1;
w(ibase) = model.w_iod;
ibase = ibase + 1;
w(ibase) = model.w_iof;
ibase = ibase + 1;
w(ibase:ibase+2*model.nobjs-1) = model.w_oo;
ibase = ibase+2*model.nobjs;

assert(featlen == ibase - 1);

end

function w = getweights2(model)
featlen =   1 + ... % layout confidence : no bias required, selection problem    
            2 + ... % object pairs : 1) 3D intersection 2) 2D bboverlap
            3 * (length(model.ow_edge) - 1) + ... % object inclusion : 3D volume intersection
            model.nobjs + ... % min distance to wall 3D
            model.nobjs + ... % min distance to wall 2D
            model.nobjs + ... % floor distance per object: sofa to floor
            2 * model.nobjs;      % object confidence : (weight + bias) per type

w = zeros(featlen, 1);
ibase = 1;
w(ibase) = model.w_or;
ibase = ibase + 1;

w(ibase:ibase+1) = model.w_ioo;
ibase = ibase + 2;

w(ibase:ibase+3 * (length(model.ow_edge) - 1)-1) = model.w_ior;
ibase = ibase + 3 * (length(model.ow_edge) - 1);

w(ibase:ibase+model.nobjs-1) = model.w_iow3;
ibase = ibase + model.nobjs;

w(ibase:ibase+model.nobjs-1) = model.w_iow2;
ibase = ibase + model.nobjs;

w(ibase:ibase+model.nobjs-1) = model.w_iof;
ibase = ibase + model.nobjs;

w(ibase:ibase+2*model.nobjs-1) = model.w_oo;
ibase = ibase+2*model.nobjs;

assert(featlen == ibase - 1);

end

function w = getweights1(model)
featlen =   1 + ... % layout confidence : no bias required, selection problem    
            2 + ... % object pairs : 1) 3D intersection 2) 2D bboverlap
            5 + ... % object inclusion : 3D volume intersection
            model.nobjs + ... % min distance to wall 3D
            model.nobjs + ... % min distance to wall 2D
            model.nobjs + ... % floor distance per object: sofa to floor
            2 * model.nobjs;      % object confidence : (weight + bias) per type

w = zeros(featlen, 1);
ibase = 1;
w(ibase) = model.w_or;
ibase = ibase + 1;

w(ibase:ibase+1) = model.w_ioo;
ibase = ibase + 2;

w(ibase:ibase+4) = model.w_ior;
ibase = ibase + 5;

w(ibase:ibase+model.nobjs-1) = model.w_iow3;
ibase = ibase + model.nobjs;

w(ibase:ibase+model.nobjs-1) = model.w_iow2;
ibase = ibase + model.nobjs;

w(ibase:ibase+model.nobjs-1) = model.w_iof;
ibase = ibase + model.nobjs;

w(ibase:ibase+2*model.nobjs-1) = model.w_oo;
ibase = ibase+2*model.nobjs;

assert(featlen == ibase - 1);

end
