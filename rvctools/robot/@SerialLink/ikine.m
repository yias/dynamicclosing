%SerialLink.IKINE Inverse manipulator kinematics
%
% Q = R.ikine(T) is the joint coordinates corresponding to the robot 
% end-effector pose T which is a homogenenous transform.
%
% Q = R.ikine(T, Q0, OPTIONS) specifies the initial estimate of the joint 
% coordinates.
%
% Q = R.ikine(T, Q0, M, OPTIONS) specifies the initial estimate of the joint 
% coordinates and a mask matrix.  For the case where the manipulator 
% has fewer than 6 DOF the solution space has more dimensions than can
% be spanned by the manipulator joint coordinates.  In this case
% the mask matrix M specifies the Cartesian DOF (in the wrist coordinate 
% frame) that will be ignored in reaching a solution.  The mask matrix 
% has six elements that correspond to translation in X, Y and Z, and rotation 
% about X, Y and Z respectively.  The value should be 0 (for ignore) or 1.
% The number of non-zero elements should equal the number of manipulator DOF.
%
% For example when using a 5 DOF manipulator rotation about the wrist z-axis
% might be unimportant in which case  M = [1 1 1 1 1 0].
%
% In all cases if T is 4x4xM it is taken as a homogeneous transform sequence 
% and R.ikine() returns the joint coordinates corresponding to each of the 
% transforms in the sequence.  Q is MxN where N is the number of robot joints.
% The initial estimate of Q for each time step is taken as the solution 
% from the previous time step.
%
% Options::
% 'pinv'         use pseudo-inverse instead of Jacobian transpose
% 'ilimit',L     set the maximum iteration count (default 1000)
% 'tol',T        set the tolerance on error norm (default 1e-6)
% 'alpha',A      set step size gain (default 1)
% 'novarstep'    disable variable step size
% 'warning'      display warnings
% 'verbose'      show number of iterations for each point
% 'verbose=2'    show state at each iteration
% 'plot'         plot iteration state versus time
%
% Notes::
% - Solution is computed iteratively.`
% - Solution is sensitive to choice of initial gain.  The variable
%   step size logic (enabled by default) does its best to find a balance
%   between speed of convergence and divergence.
% - Some experimentation might be required to find the right values of 
%   tol, ilimit and alpha.
% - The pinv option sometimes leads to much faster convergence.
% - The tolerance is computed on the norm of the error between current
%   and desired tool pose.  This norm is computed from distances
%   and angles without any kind of weighting.
% - The inverse kinematic solution is generally not unique, and 
%   depends on the initial guess Q0 (defaults to 0).
% - The default value of Q0 is zero which is a poor choice for most
%   manipulators (eg. puma560, twolink) since it corresponds to a kinematic
%   singularity.
% - Such a solution is completely general, though much less efficient 
%   than specific inverse kinematic solutions derived symbolically, like
%   ikine6s or ikine3.
% - This approach allows a solution to obtained at a singularity, but 
%   the joint angles within the null space are arbitrarily assigned.
% - Joint offsets, if defined, are added to the inverse kinematics to 
%   generate Q.
%
% See also SerialLink.fkine, tr2delta, SerialLink.jacob0, SerialLink.ikine6s.
 

% Copyright (C) 1993-2011, by Peter I. Corke
%
% This file is part of The Robotics Toolbox for Matlab (RTB).
% 
% RTB is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% RTB is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Leser General Public License
% along with RTB.  If not, see <http://www.gnu.org/licenses/>.
%
% http://www.petercorke.com

function [qt,histout] = ikine(robot, tr, varargin)
    %  set default parameters for solution
    opt.ilimit = 1000;
    opt.ttol = 1e-6;
    opt.rtol = 1e-6;
    opt.tol = 1e-6;
    opt.alpha = 1;
    opt.plot = [];
    opt.pinv = false;
    opt.varstep = true;
    opt.warning = 1;
    [opt,args] = tb_optparse(opt, varargin);

    n = robot.n;

    % robot.ikine(tr, q)
    if ~isempty(args)
        q = args{1};
        if isempty(q)
            q = zeros(1, n);
        else
            q = q(:)';
        end
    else
        q = zeros(1, n);
    end

    % robot.ikine(tr, q, m)
    if length(args) > 1
        m = args{2};
        m = m(:);
        if numel(m) ~= 6
            error('Mask matrix should have 6 elements');
        end
%         if numel(find(m)) ~= robot.n 
%             error('Mask matrix must have same number of 1s as robot DOF')
%         end
    else
        if n < 6
            error('For a manipulator with fewer than 6DOF a mask matrix argument must be specified');
        end
        m = ones(6, 1);
    end
    % make this a logical array so we can index with it
    m = logical(m);

    npoints = size(tr,3);    % number of points
    qt = zeros(npoints, n);  % preallocate space for results
    tcount = 0;              % total iteration count

    if ~ishomog(tr)
        error('RTB:ikine:badarg', 'T is not a homog xform');
    end

    Jn = jacobn(robot, q);
    Jn = Jn(m, :);
    if cond(Jn) > 100 && opt.warning
        warning('RTB:ikine:singular', 'Initial joint angles results in near-singular configuration, this may slow convergence');
    end

    history = []; histout = [];
    failed = false;
    %W = diag([1 1 1 0 0 0]);
    for i=1:npoints
        T = tr(:,:,i);

        nm = Inf;
        % initialize state for the ikine loop
        eprev = Inf;
        save.e = [Inf Inf Inf Inf Inf Inf];
        save.q = [];
        count = 0;

        while true
            % update the count and test against iteration limit
            count = count + 1;
            if count > opt.ilimit
                if opt.warning
                    warning('ikine: iteration limit %d exceeded (row %d), final err %f', ...
                        opt.ilimit, i, nm);
                end
                failed = true;
                q = NaN*ones(1,n);
                break
            end

            % compute the error
            C = robot.fkine(q');
            %T = T*Hinv(C);
            %C = eye(4);
            
            e = tr2delta( C, T);
            R0 = t2r(C);
            e(1:3) = R0'*e(1:3);
            e(4:6) = R0'*e(4:6);
            
             %R1 = t2r(T);    
            %RR = R1*R0';;
            
            [ne, nte, nre] = e2err(e, m);
            % optionally adjust the step size
            if opt.varstep
                % test against last best error, only consider the DOF of
                % interest
                
                %if norm(e(m)) < norm(save.e(m))                
                
                %[sne, snte, snre] = e2err(save.e, m);                    
                %if nte < snte && nre < snre
                if norm(e(m)) < norm(save.e(m))                                    
                    % error reduced,
                    % let's save current state of solution and rack up the step size
                    save.q = q;
                    save.e = e;
                    opt.alpha = opt.alpha * (2.0^(1.0/8));
                    if opt.verbose > 1
                        fprintf('raise alpha to %f\n', opt.alpha);
                    end
                else
                    % rats!  error got worse,
                    % restore to last good solution and reduce step size
                    q = save.q;
                    e = save.e;
                    opt.alpha = opt.alpha * 0.9;
                    if opt.verbose > 1
                        fprintf('drop alpha to %f\n', opt.alpha);
                    end
                end
            end

            % compute the Jacobian
            J = jacobn(robot, q);
%             J(1:3,:) = R0'*J(1:3,:);
%             J(4:6,:) = R0'*J(4:6,:);

            mq = ones(1,n);
            for k=1:n
                if q(k) > robot.qlim(k,2) || q(k) < robot.qlim(k,1)
                    mq(k) = 0;
                end
            end
            mq = logical(mq);
            

            % compute change in joint angles to reduce the error, 
            % based on the square sub-Jacobian
            dq = zeros(n,1);
            if opt.pinv
                %J1 = J(m, mq);
                %W1 = W(m,m);
                %Jinv = ((J1'*W1*J1)\eye(sum(mq)))*J1'*W1;
                dq(mq) = opt.alpha * pinv( J(m,mq) ) * e(m);
                %dq(mq) = opt.alpha * Jinv * e(m);
            else
                dq = J(m,:)' * e(m);
                dq = opt.alpha * dq;
            end
            
            % diagnostic stuff
            if opt.verbose > 1
                fprintf('%d:%d: |e| = %f\n', i, count, nm);
                fprintf('       e  = '); disp(e');
                fprintf('       dq = '); disp(dq');
            end
            if ~isempty(opt.plot)
                h.q = q';
                h.dq = dq;
                h.e = e;
                h.ne = nm;
                h.nre = nre;
                h.nte = nte;
                h.alpha = opt.alpha;
                h.mq = mq;
                history = [history; h]; %#ok<*AGROW>
            end

            % update the estimated solution
            %q(mq) = q(mq) + dq(mq')';
            q = q + dq';
            nm = norm(e(m));

            if norm(e) > 1.5*norm(eprev) && opt.warning
                warning('RTB:ikine:diverged', 'solution diverging, try reducing alpha');
            end
            eprev = e;

            %if nm <= opt.tol
            if nte <= opt.ttol && nre <= opt.rtol
                break
            end

        end  % end ikine solution for tr(:,:,i)
        qt(i,:) = q';
        tcount = tcount + count;
        if opt.verbose
            fprintf('%d iterations\n', count);
        end
    end
    
    if opt.verbose && npoints > 1
        fprintf('TOTAL %d iterations\n', tcount);
    end

    % plot evolution of variables
    if ~isempty(opt.plot)
        figure(opt.plot(1));
        plot([history.q]');
        xlabel('iteration');
        ylabel('q');
        grid

        figure(opt.plot(2));
        plot([history.dq]');
        xlabel('iteration');
        ylabel('dq');
        grid

        figure(opt.plot(3));
        plot([history.e]');
        xlabel('iteration');
        ylabel('e');
        grid

        figure(opt.plot(4));
        semilogy([history.ne]);
        xlabel('iteration');
        ylabel('|e|');
        grid

        figure(opt.plot(5));
        plot([history.alpha]);
        xlabel('iteration');
        ylabel('\alpha');
        grid

        if nargout > 1
            histout = history;
        end
    end
end

function [ne, nte, nre] = e2err(e, m)
    ne = norm(e(m));
    nte = norm(e(m(1:3)));
    nre = norm(e(m(4:6)));
end