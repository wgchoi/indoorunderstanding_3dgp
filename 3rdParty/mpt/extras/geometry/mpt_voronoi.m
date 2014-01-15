function [Pn]=mpt_voronoi(points,Options)
%MPT_VORONOI Computes the voronoi diagram via mpLP
%
% [Pn]=mpt_voronoi(points,Options)
%
% ---------------------------------------------------------------------------
% DESCRIPTION
% ---------------------------------------------------------------------------
% The voronoi diagram is a partition of the state space; For a given set of
% points pj, each region Pn(j) is defined as 
%           Pn(j)={x \in R^n | d(x,pj)<=d(x,pi), \forall i \neq j}
%  
% ---------------------------------------------------------------------------
% INPUT
% ---------------------------------------------------------------------------
% points         -  Optional input:
%                   Matrix p times nx of points: nx is state space dimension and
%                   p is the number of points
%                   The entry is graphical in 2D if no parameters are passed.
% Options.pbound -  A "bounding polytope". If provided, the voronoi cells will
%                   be bounded by this polytope. If not provided, the cells will
%                   be bounded by a hypercube as big as 1.5x the maximum
%                   coordinate of any of the seed points
% Options.plot   -  If set to 1, plots the voronoi diagram (0 is default)
% Options.sortcells - If set to 1, resulting Voronoi partition will be ordered
%                     in a way such that Pn(i) corresponds to seed point i.
%                     (Default is 1)
%
% ---------------------------------------------------------------------------
% OUTPUT                                                                                                    
% ---------------------------------------------------------------------------
%
% Pn            -   Voronoi partition
%
% see also MPT_DELAUNAY
%

% Copyright is with the following author(s):
%
% (C) 2005 Michal Kvasnica, Automatic Control Laboratory, ETH Zurich,
%     kvasnica@control.ee.ethz.ch
% (C) 2003 Pascal Grieder, Automatic Control Laboratory, ETH Zurich,
%     grieder@control.ee.ethz.ch

% ---------------------------------------------------------------------------
% Legal note:
%          This program is free software; you can redistribute it and/or
%          modify it under the terms of the GNU General Public
%          License as published by the Free Software Foundation; either
%          version 2.1 of the License, or (at your option) any later version.
%
%          This program is distributed in the hope that it will be useful,
%          but WITHOUT ANY WARRANTY; without even the implied warranty of
%          MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%          General Public License for more details.
% 
%          You should have received a copy of the GNU General Public
%          License along with this library; if not, write to the 
%          Free Software Foundation, Inc., 
%          59 Temple Place, Suite 330, 
%          Boston, MA  02111-1307  USA
%
% ---------------------------------------------------------------------------

global mptOptions;

if ~isstruct(mptOptions),
    mpt_error;
end

if nargin < 2,
    Options = [];
end
if ~isfield(Options, 'plot'),
    Options.plot = 0;
end
if ~isfield(Options, 'verbose'),
    % this is to keep mpt_mplp silent
    Options.verbose = -1;
end
if ~isfield(Options, 'sortcells'),
    Options.sortcells = 1;
end

if(nargin==0 | isempty(points))
    points=[];
    figure; axis([-10 10 -10 10]);hold on; grid on
    title('Left-click to select points. Right-click to exit editing mode...');
    button=1;
    while button==1
        [x1,x2,button]   =   ginput(1);   %graphically enter one point
        points=[points; x1 x2];
        plot(x1,x2,'kx','LineWidth',3);
    end
end
if(isa(points,'polytope'))
     points=extreme(points);
end
if(~isfield(Options,'abs_tol'))
    Options.abs_tol = mptOptions.abs_tol;
end


nx=size(points,2);
nopoints=size(points,1);

%peturb points to obtain general position
% points=points+(rand(nopoints,nx)-0.5)*Options.abs_tol;

%build voronoi constraint matrices
G=[];
W=[];
E=[];
npoints = size(points, 1);
for i=1:npoints
    E=[E;-2*points(i,:)];
    G=[G;-1];
    W=[W;points(i,:)*points(i,:)'];
    
end
Matrices.G=G;
Matrices.W=W;
Matrices.E=E;
Matrices.H=[1]';

if isfield(Options, 'pbound'),
    % user has provided a bounding polytope, check if the input is correct
    pbound = Options.pbound;
    if ~isa(pbound, 'polytope'),
        error('''Options.pbound'' must be a polytope object.');
    elseif dimension(pbound) ~= nx,
        error(sprintf('''Options.pbounds'' must be a polytope in %dD.', nx));
    elseif length(pbound)>1,
        error('''Options.pbound'' must be a single polytope.');
    end
else
    % by default we bound the voronoi cells with a hypercube of size 1.5x bigger
    % than the maximum coordinate of seeds
    pbound = unitbox(nx, max(max(points))*1.5);
end
[Matrices.bndA, Matrices.bndb]=double(pbound);

%solve mpLP
[Pn,Fi,Gi,activeConstraints,Phard,details]=mpt_mplp(Matrices,Options);

if Options.sortcells,
    % re-order regions such that Pn(i) corresponds to seed "i"
    Idx = [];
    for i = 1:npoints,
        % find which region corresponds to seed "i"
        [isin, inwhich] = isinside(Pn, points(i, :)');
        if isin,
            % actually it shouls never happen that a seed does not belong to any
            % polytope, but double-check that
            Idx = [Idx inwhich(1)];
        else
            warning(sprintf('MPT_VORONOI: point %d does not belong to any polytope!', i));
        end
    end
    % only re-order polytopes if all regions have an associated seed point
    if length(Idx) == npoints,
        Pn = Pn(Idx);
    else
        warning('MPT_VORONOI: returning unordered partition.');
    end
end

%plot results
if((nx==2 | nx==3) & Options.plot==1)
	plot(Pn)
	hold on
	for i=1:npoints
        if(nx==2)
            plot(points(i,1),points(i,2),'k*','LineWidth',2);
        else
            plot3(points(i,1),points(i,2),points(i,3),'k*','LineWidth',2);
        end
	end
end
