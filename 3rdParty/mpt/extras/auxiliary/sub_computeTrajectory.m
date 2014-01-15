function [X,U,Y,D,cost,trajectory,feasible,dyns,details] = sub_computeTrajectory(ctrl, x0, N, Options)
%sub_COMPUTETRAJECTORY Calculates time evolution of state trajectories subject to control
%
% [X,U,Y,D,cost,trajectory,feasible]=sub_computeTrajectory(ctrl,x0,N,Options)
%
% ---------------------------------------------------------------------------
% DESCRIPTION
% ---------------------------------------------------------------------------
% For the given state x0, the state, input and output evolution trajectories
% are computed.
%
% ---------------------------------------------------------------------------
% INPUT
% ---------------------------------------------------------------------------
% ctrlStruct        - Controller structure as generated by mpt_control
% x0                - initial state
% N                 - for how many steps should the state evolution be computed
%                     If horizon=Inf, computes evolution of the state to origin
% Options.reference - If tracking is requested, provide the reference point
%                     in this variable (e.g. Options.reference = [5;0])
% Options.sysStruct - If provided, we use this system model for simulations
%                     instead of sysStruct which was used to compute the
%                     controller
% Options.sysHandle - Handle of a simulation function. If provided, we call this
%                     function to obtain the state update. E.g.:
%                        Options.sysHandle = @di_sim_fun
%                     where "di_sim_fun.m" mut be a function which takes "xk"
%                     and "uk" as input arguments and produces exactly two
%                     outputs - "xn" (state update x(k+1)) and "yn" (output
%                     y(k)). It's the user's responsibility to make sure that
%                     dimensions of state/inputs/outputs match dimensions of the
%                     control law. Take a look at 'help di_sim_fun' for more
%                     details.
% Options.randdist  - If set to 1, randomly generated additive disturbance
%                       vector will be added to the state equation
% Options.openloop  - If 1, the open-loop solution will be computed, 0 for
%                       closed-loop trajectory (default is Options.openloop=0)
% Options.stopInTset- If set to 1 and user-specified terminal set was
%                     provided when computing the controller, evolution of
%                     states will be stopped as soon as all states lie in the
%                     terminal set for two consecutive steps (i.e. states will
%                     not be driven to the origin).
% Options.samplInTset - if Options.stopInTset is on, this option defines how
%                       many CONSECUTIVE states has to lie in the terminal set
%                       before the evolution terminates. Default is 2
% Options.minnorm   - If closed-loop trajectory is computed, we stop the
%                     evolution if norm of a state decreases below this value
% Options.verbose   - Level of verbosity
% Options.lpsolver  - Solver for LPs (see help mpt_solveLP for details)
% Options.abs_tol   - absolute tolerance
% Options.useXU     - if 1, use a control input based on an XUset istead of the 
%                     usual (optimization) based control action. (default 0)
% 
% Note: If Options is missing or some of the fields are not defined, the default
%       values from mptOptions will be used
%
% ---------------------------------------------------------------------------
% OUTPUT                                                                                                    
% ---------------------------------------------------------------------------
% X, U       - matrices containing evolution of states and control moves
% Y, D       - matrices containing evolution of outputs and disturbances
% cost       - contains cost from the given initial state to the origin
% trajectory - vector of indices specifying in which region of Pn the given state lies
% feasible   - 1: the control law was feasible for all time instances, 0: otherwise
%
% see also MPT_GETINPUT, MPT_COMPUTETRAJECTORY
%

% Copyright is with the following author(s):
%
% (C) 2005 Michal Kvasnica, Automatic Control Laboratory, ETH Zurich,
%          kvasnica@control.ee.ethz.ch

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

global mptOptions
if ~isstruct(mptOptions)
    mpt_error;
end

error(nargchk(2,4,nargin));

if nargin<1
    help sub_computeTrajectory
elseif nargin < 3
    N = Inf;
    Options = [];
elseif nargin < 4
    Options = [];
end

sysStruct = ctrl.sysStruct;
probStruct = ctrl.probStruct;

x0 = x0(:);
nu = ctrl.details.dims.nu;
nx = ctrl.details.dims.nx;
ny = ctrl.details.dims.ny;
nut = nu;
nxt = nx;
nyt = ny;

%=====================================================================
% set default values of Options
if ~isfield(Options, 'openloop')
    Options.openloop = 0;
end
if ~isfield(Options, 'maxCtr'),
    Options.maxCtr = 1000;
end
if ~isinf(N),
    Options.maxCtr = N;
end
if ~isfield(Options,'minnorm') 
    % consider state reached the origin if norm of the state is less then Option.minnorm and abort trajectory update
    Options.minnorm=0.01;
    userMinNorm = 0;
end
if ~isfield(Options,'samplInTset') % 
    %how many CONSECUTIVE states has to lie in the user defined terminal set
    Options.samplInTset=3;    
end
if ~isfield(Options,'stopInTset') % if user-provided terminal set should be used as a stopping critertion for state evolution
    Options.stopInTset=0;    
end
if ~isfield(Options,'reference')
    if probStruct.tracking,
        error('For tracking, please provide the reference point in Options.reference !');
    end
    Options.reference = zeros(size(probStruct.Q,1),1);
end
if ~isfield(Options,'randdist') % if random disturbances should be added to the state vector
    Options.randdist=1;    
end
if ~isfield(Options, 'verbose')
    Options.verbose = mptOptions.verbose;
end
if ~isfield(Options, 'usexinit')
    % if set to true, uses feasible solution from previous step as an initial
    % guess for the MILP/MIQP program to speed it up
    Options.usexinit = 1;
end
if isfield(Options, 'sysStruct'),
    sys_type = 1;
    
    % verify that Options.sysStruct is a valid system structure
    try
        Options.sysStruct = mpt_verifySysStruct(Options.sysStruct);
    catch
        rethrow(lasterror);
    end
    
elseif isfield(Options, 'sysHandle'),
    sys_type = 2;
    if ~isa(Options.sysHandle, 'function_handle'),
        error('Options.sysHandle must be a function handle.');
    end
    
else
    % use sysStruct stored in the controller object
    sys_type = 0;
end

% this flag is need for a different call to getInput for explicit controllers
% (one more output than getInput for on-line controllers)
isEXPctrl = isexplicit(ctrl);

X = [];
U = [];
Y = [];
D = [];
dyns = [];
trajectory = [];
cost = 0;
details = {};
givedetails = (nargout==9);

if givedetails,
    Options.fastbreak = 0;
end

if probStruct.tracking>0 & ~isfield(sysStruct, 'dims'),
    % controller was stored with an older version which didn't store dimensions
    % properly
    dims = struct('nx', nx, 'nu', nu, 'ny', ny);
    sysStruct.dims = dims;
    ctrl = set(ctrl, 'sysStruct', sysStruct);
end
nx = ctrl.details.dims.nx;
nu = ctrl.details.dims.nu;

if length(x0)>nx,
    error('Wrong dimension of X0!');
end
u_prev = zeros(nu, 1); % default u(k-1)

if sys_type==1,
    % check that the provided sysStruct is compatible with this controller
    [simx, simu] = mpt_sysStructInfo(Options.sysStruct);
    if length(x0)~=simx | nu~=simu,
        error('The provided system structure has incompatible number of states and/or inputs.');
    end
end

X = [x0'];
x0_orig = x0;



%================================================================
% open-loop solution
if Options.openloop,
    if sys_type > 0 & Options.verbose > -1,
        fprintf('WARNING: Custom simulation models not supported for open-loop trajectories.\n');
        fprintf('         Switching to default sysStruct\n');
    end
    [x0, dumode] = extendx0(ctrl, x0, u_prev, Options.reference);
    if isEXPctrl,
        if iscell(sysStruct.A) & size(ctrl.Fi{1}, 1)<=nu,
            % we have a PWA system, call mpt_computeTrajectory which calculates
            % open-loop trajectory for PWA system.
            %
            % however if mpt_yalmipcftoc() was used to compute the open-loop
            % solution, it is stored directly in ctrl.Fi and ctrl.Gi terms as in
            % case of linear systems
            [X,U,Y,D,cost,trajectory,feasible,dyns] = mpt_computeTrajectory(struct(ctrl), x0, N, Options);
            return
        end
        [Uol, feasible, cost, trajectory] = mpt_getInput(ctrl, x0, Options);
    else
        [Uol, feasible, cost] = mpt_getInput(ctrl, x0, Options);
    end
    Uol = reshape(Uol, nu, [])';
    
    
    % switch from deltaU formulation if necessary
    deltaU = Uol;
    U = Uol;
    u_prev = u_prev(:)';
    if dumode,
        % only change U if deltaU constraints are present, or tracking with
        % deltaU formulation requested
        U = [];
        for ii=1:size(Uol,1),
            U = [U; Uol(ii,:)+u_prev];
            u_prev = U(ii,:);
        end
    end

    % simulate evolution of the original system (the one which was not augmented
    % for tracking or deltaU formulation)
    [X,U,Y,dyns] = mpt_simSys(ctrl.details.origSysStruct, x0_orig, U);
        
    X = [x0_orig'; X];
    
    % that's it
    
else
    %================================================================
    % closed-loop solution
    Options.openloop = 0;
    
    
    finalboxtype = 0;
    % determine stoping criterion:
    %  1. state regulation towards free reference
    %  2. state regulation towards origin
    %  3. state regulation towards fixed reference
    %  4. output regulation towards free reference
    %  5. output regulation towards zero output
    %  6. output regulation towards fixed reference

    if Options.stopInTset,
        finalboxtype = 2;
        finalbox = probStruct.Tset;
        if ~isfulldim(finalbox),
            error('probStruct.Tset must be a fully dimensional set if Options.stopInTset=1 !');
        end
        
    elseif ~isfield(probStruct, 'Qy') & Options.minnorm > 0,
        %  state regulation
        
        if isfield(ctrl.sysStruct, 'dumode'),
            [nx, nu] = mpt_sysStructInfo(ctrl.sysStruct);
            nx = nx - nu;
        end
        
        if probStruct.tracking>0,
            %  1. state regulation towards free reference
            nx = ctrl.sysStruct.dims.nx;
            if nx~=length(Options.reference)
                error(sprintf('Options.reference must be a %dx1 vector, you provided a %dx1 !', ...
                    nx, length(Options.reference)));
            end
            finalbox = unitbox(nx, Options.minnorm) + Options.reference;
            finalboxtype = 1;
            
        elseif isfield(probStruct, 'xref')
            %  3. state regulation towards fixed reference
            finalbox = unitbox(nx, Options.minnorm) + probStruct.xref(1:nx);
            finalboxtype = 3;
           
        else
            %  2. state regulation towards origin
            finalbox = unitbox(nx, Options.minnorm);
            finalboxtype = 2;
        end

    elseif Options.minnorm > 0
        % output regulation
        if isfield(ctrl.sysStruct, 'dumode'),
            [nx, nu, ny] = mpt_sysStructInfo(ctrl.sysStruct);
            ny = ny - nu;
        end
        
        if probStruct.tracking>0,
            %  4. output regulation towards free reference
            ny = ctrl.sysStruct.dims.ny;
            if ny~=length(Options.reference)
                error(sprintf('Options.reference must be a %dx1 vector, you provided a %dx1 !', ...
                    ny, length(Options.reference)));
            end
            finalbox = unitbox(ny, Options.minnorm) + Options.reference;
            finalboxtype = 4;
            
        elseif isfield(probStruct, 'yref')
            %  6. output regulation towards fixed reference
            finalbox = unitbox(ny, Options.minnorm) + probStruct.yref(1:ny);
            finalboxtype = 6;
            
        else
            %  5. output regulation towards zero output
            finalbox = unitbox(ny, Options.minnorm);
            finalboxtype = 5;
            
        end

    else
        finalboxtype = 0;
    end
    
    % get the maximum value of noise (additive disturbance)
    addnoise = 0;
    if Options.randdist & mpt_isnoise(sysStruct.noise),
        % noise is added only for state regulation, otherwise we cannot
        % guarantee convergence detection
        if Options.verbose>0,
            disp('Assuming noise is hyperrectangle... trajectory is wrong if this is not true.')
        end
        if isa(sysStruct.noise, 'polytope'),
            Vnoise = extreme(sysStruct.noise);
        else
            % NOTE! remember that a V-represented noise has vertices stored
            % column-wise!
            Vnoise = sysStruct.noise';
        end
        noisedim = size(Vnoise, 2);
        deltaNoise = zeros(noisedim, 1);
        middleNoise = zeros(noisedim, 1);
        for idim = 1:noisedim,
            Vdim = Vnoise(:, idim);
            deltaNoise(idim) = (max(Vdim) - min(Vdim))/2;
            middleNoise(idim) = (max(Vdim) + min(Vdim))/2;
        end
        addnoise = 1;
        if (finalboxtype==2 | finalboxtype==3),
            if dimension(finalbox)==noisedim,
                finalbox = finalbox + sysStruct.noise;
                addnoise = 1;
            end
        end
    end
    
    
    if ~isinf(N)
        % we have user-define number of simulation steps, do not stop in finalbox
        finalbox = polytope;
        finalboxtype = 0;
    end

    
    % counter for how many consecutive sampling instances has the state/output
    % remained in a given target set
    samplesInFinalBox = 0;
    
    
    % will be set to 1 if system evolves to the target in less than
    % Options.maxCtr steps
    converged = 0;
    

    for iN = 1:Options.maxCtr
        
        %-----------------------------------------------------------------------
        % exted state vector for tracking
        [x0, dumode] = extendx0(ctrl, x0, u_prev, Options.reference);


        %-----------------------------------------------------------------------
        % record previous input (for MPC for MLD systems, such that deltaU
        % constraints are satisfied in closed-loop
        Options.Uprev = u_prev;
        
        
        %-----------------------------------------------------------------------
        % obtain control input
        [Ucl, feasible, region, costCL, gi_details] = mpt_getInput(ctrl, x0, Options);
        inwhich = gi_details.inwhich;
        fullopt = gi_details.fullopt;
        if Options.usexinit,
            Options.usex0 = fullopt;
        end
        if isEXPctrl
            trajectory = [trajectory region];
            if givedetails,
                details{end+1} = inwhich;
            end
        end

        
        %-----------------------------------------------------------------------
        % return if no feasible control law found
        if ~feasible
            if Options.verbose>-1,
                disp(['COMPUTETRAJECTORY: no feasible control law found for state x0=' mat2str(x0') ' !']);
            end
            cost = -Inf;
            return
        end
        cost = cost + costCL;

        
        %-----------------------------------------------------------------------
        % simulate the system for one time step, starting from x0 and applying
        % control move Ucl
        dyn = 0;
        if isEXPctrl,
            dyn = ctrl.dynamics(region);
        end
        simSysOpt.dynamics = dyn;
    
        if dumode,
            % deltaU formulation was used
            u_true = Ucl(:) + u_prev;
        else
            u_true = Ucl(:);
        end
        
        if sys_type==0,
            [xn, un, yn, mode] = mpt_simSys(ctrl.details.origSysStruct, ...
                x0_orig, u_true, simSysOpt);
            
        elseif sys_type==1,
            % use auxiliary sysStruct
            % do not provide simSysOpt.dynamics, let mpt_simSys decide on it's
            % own
            [xn, un, yn, mode] = mpt_simSys(Options.sysStruct, x0_orig, u_true);
            
        else
            % use auxiliary function for simulations
            [xn, yn] = feval(Options.sysHandle, x0_orig, u_true);
            mode = 0;
            un = u_true;
            
        end        

        
        %-----------------------------------------------------------------------
        % if noise is specified, we take some random value within of noise bounds
        if addnoise,
            noiseVal = randn(nx, 1);
            % bound noiseVal to +/- 1
            noiseVal(find(noiseVal>1)) = 1;
            noiseVal(find(noiseVal<-1)) = -1;
            % compute the noise, use safety scaling of 0.99 to be sure that we
            % do not exceed allowed limits
            noise = middleNoise + 0.99*noiseVal.*deltaNoise;
            xn = (xn(:) + noise)';
            D = [D; noise'];
        end
        
        
        %-----------------------------------------------------------------------
        % store data
        X = [X; xn(:)'];
        U = [U; un(:)'];
        Y = [Y; yn(:)'];
        dyns = [dyns; mode];
        x0 = xn(:);
        y0 = yn(:);
        x0_orig = x0;
        u_prev = un(:);
        
        
        %---------------------------------------------------------------------------
        % determine if system state (output) has reached it's reference
        if finalboxtype>=1 & finalboxtype<=3
            % we have state regulation, determine if state has reached finalbox
            isinfinal = isinside(finalbox, x0);
            
        elseif finalboxtype>=4
            % we have output regulation, determine if output has reached finalbox
            isinfinal = isinside(finalbox, y0);
            
        elseif finalboxtype==0
            isinfinal = 0;
        end
        
        
        %---------------------------------------------------------------------------
        % finalbox reached, increase counter
        if isinfinal,
            % we have reached finalbox, increase counter
            samplesInFinalBox = samplesInFinalBox + 1;
        else
            samplesInFinalBox = 0;
        end
        
        
        %---------------------------------------------------------------------------
        % test if state/output remained in the finalbox for a given number of
        % consecutive time instances, if so, we have converged
        if samplesInFinalBox >= Options.samplInTset
            converged = 1;
            break
        end

        
    end % for iN = 1:Options.maxCtr

    if isinf(N) & ~converged,
        if Options.verbose>-1,
            disp('COMPUTETRAJECTORY: maximum number of iterations reached!');
        end
        cost = -Inf;
    end

    if nargout > 4,
        % compute also closed-loop cost
        try
            cost = sub_computeCost(X, U, Y, sysStruct, probStruct, Options);
        catch
            % cost computation failed, please report such case to
            % mpt@control.ee.ethz.ch
            cost = -Inf;
        end
    end
    
end %end Options.openloop==0


%---------------------------------------------------------------------------
% if no noise was added, fill D with zeros
if isempty(D)
    D = zeros(size(U,1),1);
else
    D = D(1:size(U,1),:);
end

return


%==========================================================================
function cost = sub_computeCost(X, U, Y, sysStruct, probStruct, Options)
% computes closed-loop cost

nx = size(X, 2);
ny = size(Y, 2);
nu = size(U, 2);

if isfield(probStruct, 'Qy'),
    ycost = 1;
    Qy = probStruct.Qy;
    Qy = Qy(1:min(size(Qy, 1), ny), 1:min(size(Qy, 2), ny));
else
    ycost = 0;
end

Q = probStruct.Q;
Q = Q(1:min(size(Q, 1), nx), 1:min(size(Q, 2), nx));
R = probStruct.R;

if isfield(probStruct, 'Rdu'),
    Rdu = probStruct.Rdu;
else
    Rdu = probStruct.R;
end
dumode = 0;
if isfield(sysStruct, 'dumode'),
    dumode = sysStruct.dumode;
end
norm = probStruct.norm;

deltaU = diff(U);
if dumode | probStruct.tracking == 1,
    N = size(deltaU, 1);
else
    N = size(U, 1);
end

cost = 0;

switch probStruct.tracking
    case 0,
        % regulation problem

        if ycost,
            if isfield(probStruct, 'yref'),
                % mpt_prepareDU can extend yref, we need to crop it down to
                % original dimension
                reference = probStruct.yref(1:ny);
            else
                reference = zeros(ny, 1);
            end
        else
            if isfield(probStruct, 'xref'),
                % mpt_prepareDU can extend xref, we need to crop it down to
                % original dimension
                reference = probStruct.xref(1:nx);
            else
                reference = zeros(nx, 1);
            end
            if isfield(probStruct, 'uref'),
                uref = probStruct.uref(1:nu);
            else
                uref = zeros(nu, 1);
            end
        end
        
        if ycost 
            if dumode,
                % || Qy * (y - ref) || + || Rdu * deltaU ||
                
                for iN = 1:N,
                    cost = cost + sub_norm(Qy, Y(iN, :)' - reference, norm) + ...
                        sub_norm(Rdu, deltaU(iN, :)', norm);
                end
                
            else
                % || Qy * (y - ref) || + || R * u ||
                
                for iN = 1:N,
                    cost = cost + sub_norm(Qy, Y(iN, :)' - reference, norm) + ...
                        sub_norm(R, U(iN, :)', norm);
                end
                
            end
            
        else
            if dumode,
                % || Q * (x - ref) || + || Rdu * deltaU ||
                
                for iN = 1:N,
                    cost = cost + sub_norm(Q, X(iN, :)' - reference, norm) + ...
                        sub_norm(Rdu, deltaU(iN, :)', norm);
                end
                
            else
                % || Q * (x - ref) || + || R * (u - uref) ||
                
                for iN = 1:N,
                    cost = cost + sub_norm(Q, X(iN, :)' - reference, norm) + ...
                        sub_norm(R, U(iN, :)' - uref, norm);
                end
                
            end
        end
        
    case 1,
        % tracking with deltaU formulation
        reference = Options.reference;
        if ycost,
            % || Qy * (y - ref) || + || Rdu * deltaU ||
            
            for iN = 1:N,
                cost = cost + sub_norm(Qy, Y(iN, :)' - reference, norm) + ...
                    sub_norm(Rdu, deltaU(iN, :)', norm);
            end
            
        else
            % || Q * (x - ref) || + || Rdu * deltaU ||
        
            for iN = 1:N,
                cost = cost + sub_norm(Q, X(iN, :)' - reference, norm) + ...
                    sub_norm(Rdu, deltaU(iN, :)', norm);
            end
            
        end
        
    case 2,
        % tracking without deltaU formulation
        reference = Options.reference;
        
        if ycost,
            % || Qy * (y - ref) || + || R * u ||
            
            for iN = 1:N,
                cost = cost + sub_norm(Qy, Y(iN, :)' - reference, norm) + ...
                    sub_norm(R, U(iN, :)', norm);
            end
            
        else
            % || Q * (x - ref) || + || R * u ||
            
            for iN = 1:N,
                cost = cost + sub_norm(Q, X(iN, :)' - reference, norm) + ...
                    sub_norm(R, U(iN, :)', norm);
            end
            
        end
        
end



%==========================================================================
function result = sub_norm(Q, x, p)
% computes a weighted p-norm of a vector

x = x(:);
if p==2
    result = x'*Q*x;
else
    result = norm(Q*x, p);
end