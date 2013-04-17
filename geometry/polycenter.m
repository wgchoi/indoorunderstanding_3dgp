function [area,cx,cy] = polycenter(x,y,dim)

%POLYCENTER Area and centroid of polygon.
%   [AREA,CX,CY] = POLYCENTER(X,Y) returns the area and the centroid
%   coordinates of the polygon specified by the vertices in the vectors X
%   and Y. If X and Y are matrices of the same size, then POLYCENTER
%   returns the centroid and area of polygons defined by the columns X and
%   Y. If X and Y are arrays, POLYCENTER returns the centroid and area of
%   the polygons in the first non-singleton dimension of X and Y.
%
%   POLYCENTER is an extended version of POLYAREA.
%
%   The polygon edges must not intersect. If they do, POLYCENTER returns
%   the values of the difference between the clockwise encircled parts and
%   the counterclockwise ones. As with POLYAREA, the absolute value is used
%   for the area.
%
%   [AREA,CX,CY] = POLYCENTER(X,Y,DIM) returns the centroid and area of the
%   polygons specified by the vertices in the dimension DIM.
%
%   Example:
%   -------
%       x0 = rand(1); y0 = rand(1);
%       L = linspace(0,2.*pi,6);
%       xv = cos(L)' + x0; yv = sin(L)' + y0;
%       xv = [xv ; xv(1)]; yv = [yv ; yv(1)];
%       [A,cx,cy] = polycenter(xv,yv);
%       plot(xv,yv,cx,cy,'k+')
%       title(['Area = ' num2str(A)]), axis equal
%
%   Damien Garcia, 08/2007, directly adapted from POLYAREA
%
%   See also POLYAREA.

if nargin==1 
  error('MATLAB:polycenter:NotEnoughInputs','Not enough inputs.'); 
end

if ~isequal(size(x),size(y)) 
  error('MATLAB:polycenter:XYSizeMismatch','X and Y must be the same size.'); 
end

if nargin==2
    [x,nshifts] = shiftdim(x);
    y = shiftdim(y);
elseif nargin==3
    perm = [dim:max(length(size(x)),dim) 1:dim-1];
    x = permute(x,perm);
    y = permute(y,perm);
end

warn0 = warning('query','MATLAB:divideByZero');
warning('off','MATLAB:divideByZero')
    
siz = size(x);
if ~isempty(x)
    tmp = x(:,:).*y([2:siz(1) 1],:) - x([2:siz(1) 1],:).*y(:,:);
    area = reshape(sum(tmp),[1 siz(2:end)])/2;
    cx = reshape(sum((x(:,:)+x([2:siz(1) 1],:)).*tmp/6),[1 siz(2:end)])./area;
    cy = reshape(sum((y(:,:)+y([2:siz(1) 1],:)).*tmp/6),[1 siz(2:end)])./area;
    area = abs(area);
else
    area = sum(x); % SUM produces the right value for all empty cases
    cx = NaN(size(area));
    cy = cx;
end

warning(warn0.state,'MATLAB:divideByZero')

if nargin==2
   area = shiftdim(area,-nshifts);
   cx = shiftdim(cx,-nshifts);
   cy = shiftdim(cy,-nshifts);
elseif nargin==3
    area = ipermute(area,perm);
    cx = ipermute(cx,perm);
    cy = ipermute(cy,perm);
end
