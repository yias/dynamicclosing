classdef Hand < handle    
    properties 
        displayOrigin
    end
    
    properties (Dependent)        
        Fingers
        Palm
        Wrist
        Q
    end
    
    properties (SetAccess = private)
        wristBase
    end
    
    properties (Access = private)
        fingers
        fingersBase
        palm
        palmBase
        wrist        
        q
        fdof
        wdof = 2;
        hbox
        lim                
    end
    
    properties (Dependent)
        box
    end
    
    properties (Constant)
        wrld_T_palmYdown = trotz(pi/2) * trotx(pi/2);
        wrld_T_palmYup = trotz(pi/2)*trotx(-pi/2);
    end
    
    methods
        function h= Hand()            
            h.displayOrigin = eye(4);
        end

        function valid = validPoint(h, tIw)    
            if tIw(1,4) < h.hbox(1,1) || tIw(1,4) > h.hbox(1,2) || ...
                tIw(2,4) < h.hbox(2,1) || tIw(2,4) > h.hbox(2,2) || ...
                tIw(3,4) < h.hbox(3,1) || tIw(3,4) > h.hbox(3,2)        
                valid = 0;
            else
                valid = 1;
            end
        end    
        
        function refresh(h,k,v)
            h.validHand();
%             nq = h.q;
%             start = 3;
%             for i=1:length(h.fingers)
%                 nq(start, start:h.fingers(i).n-1) = h.fingers(i).q;
%             end
%             h.q = nq;
            
            axis([h.lim(1,:) h.lim(2,:) h.lim(3,:) caxis]);                        
            if k; h.plotKinematicChain; end
            if v; h.visualize; end;
        end
        
        function defaultWrist(h, pos)
             h.wristBase = pos;
             h.updatePosition(eye(4));
        end
        
        function visualize(h)
            h.validHand();
            
            hold on;
            for i=1:length(h.fingers)
                for j=1:length(h.fingers(i).links)
                    h.fingers(i).links(j).visualize();
                end
            end
            for i=1:length(h.palm.links)
               h.palm.links(i).visualize();
            end
        end
        
        function plotKinematicChain(h)
            h.validHand();
            
            hold on;
            h.wrist.plot(h.q(1:2), 'nobase', 'noshadow', 'noname', 'nojoints', 'nowrist');%'notiles'
            start = 3;
            for i=1:length(h.fingers)
                h.fingers(i).plot(h.q(start:start+h.fingers(i).n-1), 'nobase', 'noshadow', 'noname');
                %h.fingers(i).plot(h.q(start:start+h.fingers(i).n-1), 'nobase', 'noshadow');
                start = start + h.fingers(i).n;
            end
            h.palm.plot([0 0 0 0 0 0], 'nobase', 'noshadow', 'noname');
        end
               
        function updatePosition(h, pos)
            h.validHand();
            h.wrist.base = pos*h.wristBase;
            h.lim = repmat(pos(1:3,4), 1, 2) + h.hbox;
             
            h.update();
        end
                       
        function set.Palm(h, v)
            h.palm = v;
            h.palmBase = v.base;
        end
        function v = get.Palm(h)
            v = h.palm;
        end
        
        function set.Fingers(h, v)
            h.fdof = sum([v.n]);
            h.fingers = v;
            h.q = [h.q zeros(1,h.fdof)];
            h.fingersBase = reshape([v.base], 4,4, size(v,2));
        end
        function v = get.Fingers(h)
            v = h.fingers;
        end
        
        function set.Wrist(h, v)
            if v.n ~= h.wdof
                error('EFW:Hand:badargs','wrist kinematic chain should have 2 joints');
            end
            h.wrist = v;
            h.q = [zeros(1,h.wdof) h.q];            
            h.wristBase = eye(4);
            h.wrist.base = h.wristBase;
        end
        function v = get.Wrist(h)
            v = h.wrist;
        end
        
        function set.Q(h, v)
            h.validHand();
            if length(v) ~= h.wdof+h.fdof
                error('EFW:Hand:badargs','update vector must have same size as sum of all hand kinematic chains');
            end            
            h.q = v;
            h.update();
        end
        function v = get.Q(h)
            v = h.q;
        end    
        
        function set.box(h, v)
            h.hbox = v;            
            h.lim = repmat([0 0 0]', 1, 2) + v;
        end
        function v = get.box(h)
            v = h.hbox;
        end
        
        function jrng = fingerId2jointRange(h, fid)
            start = 3;
            for i = 1:fid-1
                start = start + h.fingers(i).n;
            end
            jrng = start:start + h.fingers(fid).n-1;            
        end
    end
    
    methods (Access = private)
        % All the private functions assume a valid hand, hence public
        % functions must call validHand() before calling any private
        % functions
        function validHand(h)
            if isempty(h.fingers) || isempty(h.wrist)
                error('EFW:Hand:notinitialized', 'must initialize hand with finger and wrist kinematic chains before using');
            end
        end
                
        function update(h)
            % wrist positions the rest of the hand
            xformWrist = h.wrist.fkine(h.q(1:2));
            
            start = 3;
            for i=1:length(h.fingers)                
                %if i > 0, doVis = 1; else doVis = 0; end
                doVis = 0;
                xform = xformWrist*h.fingersBase(:,:,i);
                h.fingers(i).base = xform;
                q = h.q(start:start+h.fingers(i).n-1);
                for j=1:h.fingers(i).n                    
                    h.fingers(i).links(j).update(xform, q(j), doVis);
                    xform = xform*h.fingers(i).links(j).A(q(j));
                end
                start = start + h.fingers(i).n;
            end
            
            xform = xformWrist*h.palmBase;
            h.palm.base = xform;
            for j = 1:h.palm.n
                h.palm.links(j).update(xform, 0);
                xform = xform * h.palm.links(j).A(0);
            end
        end
        
        function getStartIndex(h, name)
            start = 3;
            for i=1:length(h.fingers)
                if strcmp(h.fingers(i).name, name)
                    break;
                end
                start = start+h.fingers(i).n;
            end
        end
    end
       
    methods (Static)       
        function dhp= dhpstruct(d, a, theta, alpha, x)
            dhp.d= d;
            dhp.a= a;
            dhp.theta= theta;
            dhp.alpha= alpha;
            dhp.linkFrameXform= x;
        end                    
        
        function chain= makeSerialLLink(name, base, tool, poses, parms)
            n = size(parms,1);
            ql = zeros(n,2);            
            for i=1:n
                links(i)= LLink(parms(i).dhp.linkFrameXform, parms(i).dim, parms(i).sensors, [0 parms(i).dhp.d parms(i).dhp.a parms(i).dhp.alpha 0 parms(i).dhp.theta]); 
                ql(i,1) = min(parms(i).qlim);
                ql(i,2) = max(parms(i).qlim);
            end
            chain= SerialLink(links, 'name', name, 'base', base, 'tool', tool);
            chain.qlim = ql;
            chain.addprop('poses');
            chain.poses = poses;
        end
    end
end