
 function [w,cache] = lsvmopt(x,n,id,C,TolRel,cache)
% [w,cache] = lsvmopt(x,n,id,C,TolRel,[cache])
%
% Solves the following qp via a cutting plane algoritm
%                     min .5*w*w + C*sum_i Ei
%  with constraint  w*x_i > n_i - Ei
%  
%  x: d by n 'single' matrix where each column is a feature
%     Function assumes all data points are positive, 
%     so use -x_i for negative examples
%  n: 1 by n 'single' matrix (n_i = 1 in standard SVM)
% id: k by n matrix where each column is a unique identifier
%     typically k = 1   
%     (all features that share the same slack have equivalent columns in "id")
%
% TolRel: Tolerance of QP solver (Tol = .01 typically reasonable)
%  cache: cache of cutting planes returned from previous call to lsvmopt
%         This is optional, but speeds up convergence

VERBOSE = 0;  

if VERBOSE > 0,
  fprintf('In LSVMopt\n');
end

assert(isa(x,'single'));
assert(isa(n,'single'));

% Sort ids and record locations of repeats
[id,J] = sortrows(id');
id   = id';
eqid = [0 all(id(:,2:end) == id(:,1:end-1),1)];

% Initialize lower bound
w = zeros(size(x,1),1);
if nargin < 6 | isempty(cache) | isempty(cache.xc),
  xc = [];
  nc = [];
  a  = [];  
  H  = [];
  lb = 0;
else
  xc = cache.xc;
  nc = cache.nc;
  a  = cache.a;
  w  = xc*a;
  H  = xc'*xc;
  H  = (H+H')/2;
  lb = max(nc-w'*xc);
  lb = max(lb,0);
end

slack = n-w'*x;
err   = zeros(size(x,2),1);
err(J)= lsvm_loss(slack(J),eqid);
loss  = slack*err;
ub    = w'*w*.5 + C*loss;
w_best= w; 
a_best= a;
t     = 1;
sv    = [];
tmax  = 1000;
err_p = zeros(size(err));

% Sanity check; make sure we only turn on at most unique
% assert(sum(err) <= length(unique(id)));

% Repeat while
% 1) upper and lower bounds are too far apart
% 2) new constraints are being added
% 3) we haven't hit max iteration count
if size(lb, 1) ~= size(ub,1) | size(lb,2) ~= size(ub, 2)
    keyboard
end

while 1 - lb/ub > TolRel && any(err_p ~= err) && t < tmax,

  % Compute new constraint
  I  = find(err);
  xi = addcols(x,I);
  ni = addcols(n,I);
  if isempty(xc),
    Hi = [];
  else
    Hi = xi'*xc;
  end

  % Add constraint to cache
  xc = [xc xi];
  nc = [nc ni];
  H  = [H Hi';Hi xi'*xi];
  a  = [a; 0];
  
  % Store active examples
  sv{length(a)} = I;
  
  % Call qp solver to solve dual
  I = ones(size(a),'uint32');
  S = ones(size(a),'uint8');
  [a, v] = qp(H,-nc,C,I,S,a,inf,0,TolRel,-inf,0);
  
  % Update lower bound
  lb = -v;
  
  % Find new constraint
  w = xc*a;
  slack = n-w'*x;
  err_p = err;
  err(J)= lsvm_loss(slack(J),eqid);
  loss  = slack*err;
  obj   = w'*w*.5 + C*loss;
  
  % Update upper bound
  if obj <= ub,
    ub     = obj;
    w_best = w;
    a_best = a;
  end
  
  switch VERBOSE
    case 2
     svs = logical(zeros(size(slack)));
     I = find(a > 0);
     for i = I',
       svs(sv{i}) = 1;
     end
      fprintf('#planes=%d,#sv=%d,lb=%.3g,ub=%.3g,obj=%.3g\n',length(a),sum(svs),lb,ub,obj);
    case 1      
      fprintf('.');
  end
  
  t = t + 1;
end

if t >= tmax
  fprintf('LSVMopt did not converge:lb=%.3g,ub=%.3g\n',lb,ub);
end

% Return back active set and support vectors
a = a_best;
% if(isempty(a))
%     keyboard;
% end
w = w_best;
I = find(a > 0);
cache.xc = xc(:,I);
cache.nc = nc(I);
cache.a  = a(I);
cache.ub = ub;
cache.lb = lb;
cache.iter  = t;

% Collect all points which are included in the active cutting planes
cache.sv = logical(zeros(size(slack)));
if ~isempty(sv),
  for i = I',
    cache.sv(sv{i}) = 1;
  end
end

if VERBOSE > 0,
  fprintf('#planes=%d,#sv=%d,lb=%.3g,ub=%.3g\n',length(I),sum(cache.sv),lb,ub);
end

return;

function err = lsvm_loss(slack,eqid)
% Zero-out scores that aren't the greatest violated constraint for an id

% eqid(i) = 1 if x(i) and x(i-1) are from the same id


% i1 points to the best value in the current block
i1 = 1;
v1 = slack(i1);
for i = 2:length(slack),
  % Are we at a new id?
  if eqid(i) == 0,
    i1 = i;
    v1 = slack(i1);
  elseif slack(i) > v1 % Are we at a new best in this block?
    % Zero out previous best
    slack(i1) = 0;
    % Update pointer to best
    i1 = i;
    v1 = slack(i1);
  else % same block, but not a best value
    % Zero out current contribution
    slack(i) = 0;
  end
end
err = slack > 0;


%{
I = find(slack > 0 & eqid == 1);
if ~isempty(I),
  i1 = I(1)-1;
  v  = slack(1);
  
  for t = 1:length(I),
    i2 = I(t);
    % Are we at a new id?
    if any(eqid(i1+1:i2) == 0),
      v = slack(i2);
      % Else, are we at a new best?
    elseif slack(i2) > v,
      v = slack(i2);
      % Zero out previous best
      slack(i1) = 0;
    else
      % Zero out current constraint
      slack(i2) = 0;
    end
    i1 = i2;
  end
end

err = slack > 0;
%}