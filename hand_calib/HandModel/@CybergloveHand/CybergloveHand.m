classdef CybergloveHand < Hand
    properties
        sensors
        data
        hG
        calibration
        linkidx
        options
        sensorList
    end
    
    methods 
        function h= CybergloveHand(originAtJointPos, varargin)
            h = h@Hand();
            
            opt.thumb_mod = 'rpij';
            opt.hand_geom = CybergloveHand.handGeom('default');
            opt.hand_box = [-15 15; -5 25; -5 25];
            %opt.hand_box = [-10 10; 0 20; -5 15];
            %opt.hand_box = [-5 10; -5 10; -3 12];
            opt.verbose = 1;
            opt.default_wrist = Hand.wrld_T_palmYdown;
            opt.sensor_visualization = 'pressurebar';
            opt.background = 0;
            [opt, ~] = tb_optparse(opt, varargin);
            h.options = opt;
            
            if opt.verbose
                disp(['CybergloveHand: using HandGeom: ' opt.hand_geom.name ' ThumbKinModel: ' opt.thumb_mod]);
            end

            h.hG = opt.hand_geom;
            [pts, dim, palm] = CybergloveHand.fingerGeom(h.hG);
            
            h.sensors = cell(6,6,3);
            h.linkidx = zeros(5,3);
            
            % make the fingers
            switch opt.thumb_mod
                case 'rpij'                    
                    [base, tool, poses, parms, h.linkidx(1,:)] = CybergloveHand.dhParmsThumbWithRollPIJafterFlex(pts(:,:,1), dim(:,:,1));
                case 'rmcj'
                    [base, tool, poses, parms, h.linkidx(1,:)] = CybergloveHand.dhParmsThumbWithRollMCJ(pts(:,:,1), dim(:,:,1));
                case 'rmcj_o'
                    [base, tool, poses, parms, h.linkidx(1,:)] = CybergloveHand.dhParmsThumbWithOrthoAxesAtMCJ(pts(:,:,1), dim(:,:,1));            
            end
            f(1) = Hand.makeSerialLLink('thumb', base, tool, poses, parms);
            
            qlim = deg2rad([ 
                3       -8
                0      -90
                0       -100
                0       -90
            ]);
            [base, parms, h.linkidx(2,:)] = CybergloveHand.dhParmsFinger(pts(:,:,2), dim(:,:,2), originAtJointPos, qlim);
            f(2) = Hand.makeSerialLLink('index', base, eye(4), [], parms);
            
            qlim = deg2rad([ 
                -5      5
                0      -90
                0       -100
                0       -90
            ]);            
            [base, parms, h.linkidx(3,:)] = CybergloveHand.dhParmsFinger(pts(:,:,3), dim(:,:,3), originAtJointPos, qlim);
            f(3) = Hand.makeSerialLLink('middle', base, eye(4), [], parms);

            qlim = deg2rad([
                 -5      10
                0       -90
                0       -100
                0       -90               
            ]);
            [base, parms, h.linkidx(4,:)] = CybergloveHand.dhParmsFinger(pts(:,:,4), dim(:,:,4), originAtJointPos, qlim);
            f(4) = Hand.makeSerialLLink('ring', base, eye(4), [], parms);

            qlim = deg2rad([
                0       25
                0      -90
                0       -100
                0       -90
            ]);            
            [base, parms, h.linkidx(5,:)] = CybergloveHand.dhParmsFinger(pts(:,:,5), dim(:,:,5), originAtJointPos, qlim);
            f(5) = Hand.makeSerialLLink('pinky', base, eye(4), [], parms);                        
            h.Fingers = f;
                 
            [base, parms] = CybergloveHand.dhParmsPalm(palm.pts, palm.dim);
            h.Palm = Hand.makeSerialLLink('palm', base, eye(4), [], parms);            
            
            h.iterateSensors(@setSensorVisualization, SensorPatch.getVisualization(opt.sensor_visualization));

            % make the wrist
            %base = troty(pi)*troty(pi/2)*trotz(pi/2);            
            tool = trotz(-pi/2);
            dhp = CybergloveHand.dhpstruct(0, 0, 0, -pi/2, eye(4));
            wlinks(1)= Link([0 dhp.d dhp.a dhp.alpha 0 dhp.theta]);
            %dhp= CybergloveHand.dhpstruct(0, 3, 0, 0, eye(4));
            dhp= CybergloveHand.dhpstruct(0, 0, 0, 0, eye(4));
            wlinks(2)= Link([0, dhp.d dhp.a dhp.alpha 0 dhp.theta]);
            h.Wrist = SerialLink(wlinks, 'name', 'wrist', 'tool', tool);                                    
            
            % Note, this has to come before we record the sensors. This is not ideal but right
            % now some computation happens which depends on the correct
            % setting of the wrist. 
            h.Q(1) = 0;
            h.box = opt.hand_box;                        
            %base = troty(pi/2)*trotz(pi/2);
            h.defaultWrist(opt.default_wrist);
            
            h.runLinks(@recordSensors);
            function nr = recordSensors(pid, lid, l)
                nr = 0;
                h.sensors{pid, lid, 1} = l.sensors.front; 
                if ~isempty(l.sensors.front), initSensor(l.sensors.front, [pid lid 1]); end;
                h.sensors{pid, lid, 2} = l.sensors.left;
                if ~isempty(l.sensors.left), initSensor(l.sensors.left, [pid lid 2]); end;
                h.sensors{pid, lid, 3} = l.sensors.right;                
                if ~isempty(l.sensors.right), initSensor(l.sensors.right, [pid lid 3]); end;
                function initSensor(s, hLoc)
                    s.hand = h;
                    s.hLoc = hLoc;
                    s.relevant = 1;
                end
            end 
            h.sensorList = h.makeSensorList();
            
            if opt.background
                h.drawInBackground()
            end
            
            %h.data = cell(5,3,2,3, ndatasamples);
            if exist('didx', 'var')
                clear didx;
            end            
        end    
        
        function yn = checkIntersectLinks(h, pt, vec, d)
            nr = h.runLinks(@checkIntersect);
            yn = nr > 0;
            function nr = checkIntersect(~, ~, l)
                nr = l.intersect(pt, vec, d);
            end
        end            
                 
        function updateSensorImportance(h, tI)
            h.runSensors(@updateImportance)
            function updateImportance(s, varargin)
                s.importance = tI(s.hLoc(1), s.hLoc(2), s.hLoc(3));
            end
        end
        
        function drawInBackground(h)
            h.runLinks(@doBackground);
            function nr = doBackground(~, ~, l)
                nr = 0;
                l.vis.background = 1;
            end            
        end
        
        function nr = dataRecord(h, p)
            if isempty(h.data)
                h.data(24).p = [];
                h.data(24).n = [];
                h.data(24).v = [];
                h.data(24).th = [];
                h.data(24).id = [];
                h.data(24).g = [];
            end            
            
            nr = h.runLinks(@record);
            function nr = recordi(pid, lid, l)
                pnts = [];
                nr = 0;
                if ~isempty(l.sensors.front)
                    points = l.sensors.front.pts;
                    pnts.v = sum(l.sensors.front.raw);
                    pnts.p = points.p;                        
                    pnts.n = points.n; 
                    
                    if(pnts.v>5)
                        h.data{pid, lid, 1, 1, i} = points.p;
                        h.data{pid, lid, 1, 2, i} = points.n;
                        h.data{pid, lid, 1, 3, i} = l.sensors.front.raw;                       
                        nr = 1;
                    end                                   
                end
                
                if ~isempty(l.sensors.left)
                    points = l.sensors.left.pts;
                    h.data{pid, lid, 2, 1, i} = points.p;
                    h.data{pid, lid, 2, 2, i} = points.n;
                    h.data{pid, lid, 2, 3, i} = l.sensors.left.raw;
                end
                
                %if pid > 1 && pid <5
                 %if pid == 2 && lid == 3
                if pid >1 && pnts.v>5
                    %[pid lid pnts.v]
                    plot3(pnts.p(1), pnts.p(2), pnts.p(3),'*', 'MarkerSize', 2);
                    n = pnts.p + pnts.n*1;
                    l = [pnts.p ; n];
                    plot3(l(:,1), l(:,2), l(:,3),'LineStyle', '-', 'LineWidth', 1, 'Color', 'r' );
                end
            end
            
            function nr = record(pid, lid, l)
                nr = 0;
                if p.pid == pid && p.lid == lid 
                    if p.patch == 1
                        pnts = l.sensors.front.pts;
                        pnts.v = sum(l.sensors.front.raw) / sum(l.sensors.front.raw > 0);
                    elseif p.patch == 2
                        pnts = l.sensors.left.pts;
                        pnts.v = sum(l.sensors.left.raw) / sum(l.sensors.left.raw > 0);
                    end
                    
                    pnts.th = h.Q(p.thumb);
                    pnts.id = [p.pid p.lid p.patch];                    
                    pnts.g = p.glove;
                                     
                    if(pnts.v > 10)
                        h.data(p.i) = pnts;
                        nr = 1;
                    end                                   
                end
            end
        end
        
        function iterateSensors(h, f, varargin)
            h.runLinks(@linkSensors);
            function nr = linkSensors(~, ~, l)
                nr = 0;
                if ~isempty(l.sensors.front)
                    f(l.sensors.front, varargin{:});
                end
                if ~isempty(l.sensors.left)
                    f(l.sensors.left, varargin{:});
                end
                if ~isempty(l.sensors.right)
                    f(l.sensors.right, varargin{:});
                end
            end
        end
    end
    
    methods (Access = private)
        function nr = runLinks(h, f)
            nr = 0;
            for i = 1:5
                links = h.Fingers(i).links;
                for j=1:3
                    nr = nr + f(i, j, links(h.linkidx(i,j)));
                end
            end            
            
            links = h.Palm.links;
            for j=1:6
                nr = nr + f(6, j, links(j));
            end
        end                
    end
    
    methods (Static)        
        supp = makePatchSupportSignalInfo();
        crosp = makePatchCrossSignalInfo();
        opp = makeOppositionPrior();
        hpp = makeCoarseHandPartPrior();
        
        % hand reference frame is a RHS centered at the wrist. 
        % pts is the location of the MCJ joint of finger kinematic chain in the hand reference frame
        % dim is the [thicknessStart, thicknessEnd, widthStart, widthEnd, height] of the links of each finger
        function [pts, dim]= fingerGeomOld()
            pts = zeros(4,3,5);
            dim = zeros(3,5,5);

            %thumb
            pts(:, :, 1) = [    
                -2.5    3.4     -1      %MCJ
                -6.6    5.8     -0.5    %PIJ
                -9      7.4     -0.5    %DIJ
                -11.3   9       -0.5    %FTP
            ];        
            s = diag([0.92 0.92 1]);
            pts(:,:,1) = pts(:,:,1)*s;
            
            t = [ 
                1.8   1.4
                1.4   1.2
                1.2   0.9
            ];
            dim(:,:,1) = getDim(pts(:,:,1), t);
            
            %index
            pts(:, :, 2) = [
                -2.6    10.4    0       %MCJ
                -3.1    14.8    0       %PIJ
                -3.35   17.4    0       %DIJ
                -3.6    19.8    0       %FTP
            ];    
            t = [ 
                1.3   1.2
                1.2   1.0
                1.0   0.8
            ];
            dim(:,:,2) = getDim(pts(:,:,2), t);

            %middle
            pts(:, :, 3) = [
                0       10.6    0       %MCJ
                0.4     15.2    0       %PIJ
                0.65    18.2    0       %DIJ
                0.9     21      0       %FTP
            ];
            t = [ 
                1.2   1.1
                1.1   0.9
                0.9   0.8
            ];
            dim(:,:,3) = getDim(pts(:,:,3), t);
        

            %ring
            pts(:, :, 4) = [
                2.2     9.8     0       %MCJ
                3       13.8    0       %PIJ
                3.6     16.8    0       %DIJ
                4.2     19.4    0       %FTP
            ];
            t = [ 
                1.0   1.0
                1.0   0.9
                0.9   0.8
            ];
            dim(:,:,4) = getDim(pts(:,:,4), t);
        

            %pinky
            pts(:, :, 5) = [
                4.2     8.6     0       %MCJ
                5.6     11.4    0       %PIJ
                6.55    13.4    0       %DIJ
                7.6     15.5    0       %FTP    
            ];      
            t = [ 
                1.0   1.0
                1.0   0.9
                0.9   0.7
            ];
            dim(:,:,5) = getDim(pts(:,:,5), t);
        
        
            function d= getDim(p, thicknesses)
                diffM = [-1 1 0 0; 0 -1 1 0; 0 0 -1 1];
                linkVectors = diffM*p;
                
                heights = diag(sqrt(linkVectors*linkVectors'));
                d = [thicknesses thicknesses heights];                
            end
        end
        
        function hG = handGeom(name)
            % HandGeom( palm,  mid,  width, thumb)
            switch name
                case 'suphi'
                    hG = HandGeom(  'suphi', ...
                                    struct('range', [-1.5 1.5], 'default', 9,       'val', -1), ...
                                    struct('range', [-0.5 0.5], 'default', 10.8,    'val', -1), ...
                                    struct('range', [-1 1],     'default', 7.5,     'val', -1), ...
                                    struct('range', [-1.5 1.5], 'default', 10,      'val', -1) );
                case 'hang'
                    hG = HandGeom(  'hang', ...
                                    struct('range', [-1.5 1.5], 'default', 10.5,    'val', 10.5), ...
                                    struct('range', [-0.5 0.5], 'default', 10.5,    'val', 10.5), ...
                                    struct('range', [-1 1],     'default', 7.5,     'val', 6.5), ...
                                    struct('range', [-1.5 1.5], 'default', 10.5,    'val', 11) );
                case 'ajay'
                    hG = HandGeom(  'ajay', ...
                                    struct('range', [-1.5 1.5], 'default', 9.5,       'val', -1), ...
                                    struct('range', [-0.5 0.5], 'default', 10.5,    'val', -1), ...
                                    struct('range', [-1 1],     'default', 7,     'val', -1), ...
                                    struct('range', [-1.5 1.5], 'default', 10.9,     'val', -1) );
                case 'sahar'
                    hG = HandGeom(  'sahar', ...
                                    struct('range', [-1.5 1.5], 'default', 8,       'val', -1), ...
                                    struct('range', [-0.5 0.5], 'default', 9.5,     'val', -1), ...
                                    struct('range', [-1 1],     'default', 5.7,     'val', -1), ...
                                    struct('range', [-1.5 1.5], 'default', 10.3,    'val', -1) );
                case 'ravin'
                    hG = HandGeom(  'ravin', ...
                                    struct('range', [-1.5 1.5], 'default', 10,       'val', 10.125), ...
                                    struct('range', [-0.5 0.5], 'default', 10.5,    'val', 10.3), ...
                                    struct('range', [-1 1],     'default', 8,     'val', 8), ...
                                    struct('range', [-1.5 1.5], 'default', 11,     'val', 11) );
                case 'ravin_no_tactile'
                    hG = HandGeom(  'ravin_no_tactile', ...
                                    struct('range', [-1.5 1.5], 'default', 10,       'val', 10.125), ...
                                    struct('range', [-0.5 0.5], 'default', 10.5,    'val', 10.3), ...
                                    struct('range', [-1 1],     'default', 8,     'val', 8), ...
                                    struct('range', [-1.5 1.5], 'default', 11,     'val', 11) );

                case 'iason'
                    hG = HandGeom(  'iason', ...
                                    struct('range', [-1.5 1.5], 'default', 8.8,       'val', 9.5), ...
                                    struct('range', [-0.5 0.5], 'default', 10.5,    'val', 10.2), ...
                                    struct('range', [-1 1],     'default', 6.8,     'val', 7), ...
                                    struct('range', [-1.5 1.5], 'default', 12,     'val', 12) );                        
                                
                case 'seungsu'
                    hG = HandGeom(  'seungsu', ...
                                    struct('range', [-1.5 1.5], 'default', 9.3,       'val', -1), ...
                                    struct('range', [-0.5 0.5], 'default', 10.5,    'val', -1), ...
                                    struct('range', [-1 1],     'default', 7,     'val', -1), ... 
                                    struct('range', [-1.5 1.5], 'default', 11.5,     'val', -1) );                        

                case 'sina'
                    hG = HandGeom(  'sina', ...
                                    struct('range', [-1.5 1.5], 'default', 12,       'val', -1), ...
                                    struct('range', [-0.5 0.5], 'default', 12.5,    'val', -1), ...
                                    struct('range', [-1 1],     'default', 8,     'val', -1), ...
                                    struct('range', [-1.5 1.5], 'default', 13.2,     'val', -1) );    
                case 'sina_no_tactile'
                    hG = HandGeom(  'sina', ...
                                    struct('range', [-1.5 1.5], 'default', 12,       'val', 10), ...
                                    struct('range', [-0.5 0.5], 'default', 12.5,    'val', 11), ...
                                    struct('range', [-1 1],     'default', 8,     'val', 8), ...
                                    struct('range', [-1.5 1.5], 'default', 13.2,     'val', 14) );    
                                
                case 'joel'
                    hG = HandGeom(  'joel', ...
                                    struct('range', [-1.5 1.5], 'default', 9,       'val', -1), ...
                                    struct('range', [-0.5 0.5], 'default', 11,    'val', -1), ...
                                    struct('range', [-1 1],     'default', 7.2,     'val', -1), ...
                                    struct('range', [-1.5 1.5], 'default', 12.5,     'val', -1) ); 
                case 'lucia'
                    hG = HandGeom(  'sahar', ...
                                    struct('range', [-1.5 1.5], 'default', 8,       'val', 8), ...
                                    struct('range', [-0.5 0.5], 'default', 9.5,     'val', 8.5), ...
                                    struct('range', [-1 1],     'default', 5.7,     'val', 6.5), ...
                                    struct('range', [-1.5 1.5], 'default', 10.3,    'val', 11) );
                case 'klas'
                    hG = HandGeom(  'iason', ...
                                    struct('range', [-1.5 1.5], 'default', 8.8,       'val', 9), ...
                                    struct('range', [-0.5 0.5], 'default', 10.5,    'val', 10.5), ...
                                    struct('range', [-1 1],     'default', 6.8,     'val', 7), ...
                                    struct('range', [-1.5 1.5], 'default', 12,     'val', 12.5) );    
                case 'nicolas'
                    hG = HandGeom(  'nicolas', ...
                                    struct('range', [-1.5 1.5], 'default', 8.8,       'val', 9.5), ...
                                    struct('range', [-0.5 0.5], 'default', 10.5,    'val', 11), ...
                                    struct('range', [-1 1],     'default', 6.8,     'val', 7.5), ...
                                    struct('range', [-1.5 1.5], 'default', 12,     'val', 13.5) );    
                case 'hang_no_tactile'
                    hG = HandGeom(  'hung_no_tactile', ...
                                    struct('range', [-1.5 1.5], 'default', 10.5,    'val', 10.5), ...
                                    struct('range', [-0.5 0.5], 'default', 10.5,    'val', 10.5), ...
                                    struct('range', [-1 1],     'default', 7.5,     'val', 6.5), ...
                                    struct('range', [-1.5 1.5], 'default', 10.5,    'val', 11) ); 
                case 'joao'
                    hG = HandGeom(  'hung_no_tactile', ...
                                    struct('range', [-1.5 1.5], 'default', 10.5,    'val', 8.5), ...
                                    struct('range', [-0.5 0.5], 'default', 10.5,    'val', 10.2), ...
                                    struct('range', [-1 1],     'default', 7.5,     'val', 7.5), ...
                                    struct('range', [-1.5 1.5], 'default', 10.5,    'val', 10) ); 

                case 'joel_no_tactile'
                    hG = HandGeom(  'hung_no_tactile', ...
                                    struct('range', [-1.5 1.5], 'default', 10.5,    'val', 9), ...
                                    struct('range', [-0.5 0.5], 'default', 10.5,    'val', 10.5), ...
                                    struct('range', [-1 1],     'default', 7.5,     'val', 7), ...
                                    struct('range', [-1.5 1.5], 'default', 10.5,    'val', 11.5) ); 
                                
                case 'default'
                    [pts, ~, diff] = CybergloveHand.defaultJointAttributes();
                    % rescale according to the desired hand geometery
                    palm = pts(1,2,3); % wrist to middle finger base
                    mid = norm(pts(4,:,3) - pts(1,:,3)); % length of middle finger
                    width = norm(pts(1,:,5) - pts(1,:,2)); % index base to pinky base (hand width)  
                    %defGeom.length_th = norm(pts(4,:,1) - pts(1,:,1)); 
                    thumb = sum(diag(sqrt(diff(:,:,1)*diff(:,:,1)'))); % length of thumb                    
                    hG = HandGeom(  'default', ...
                                    struct('range', [-1.5 1.5], 'default', palm,   'val', -1), ...
                                    struct('range', [-0.5 0.5], 'default', mid,    'val', -1), ...
                                    struct('range', [-1 1],     'default', width,  'val', -1), ...
                                    struct('range', [-1.5 1.5], 'default', thumb,  'val', -1) );
                otherwise
                    error('No Hand Geom recorded for %s', name);
            end
        end
        
        function [pts, t, diff, palm] = defaultJointAttributes()
            pts = zeros(4,3,5);
            
            %thumb
            pts(:, :, 1) = [    
                -2.5    3.4     -1      %MCJ
                -6.6    5.8     -0.5    %PIJ
                -9      7.4     -0.5    %DIJ
                -11.3   9       -0.5    %FTP
            ];
            t(:,:,1) = [ 
                1.8   1.4
                1.4   1.2
                1.2   0.9
            ];
            diff(:,:,1) = [-1 1 0 0; 0 -1 1 0; 0 0 -1 1]*pts(:,:,1);
            
            %index
            pts(:, :, 2) = [
                -2.6    10.4    0       %MCJ
                -3.1    14.8    0       %PIJ
                -3.35   17.4    0       %DIJ
                -3.6    19.8    0       %FTP
            ];
            t(:,:,2) = [ 
                1.3   1.2
                1.2   1.0
                1.0   0.8
            ];
            diff(:,:,2) = [-1 1 0 0; 0 -1 1 0; 0 0 -1 1]*pts(:,:,2);            
            
            %middle
            pts(:, :, 3) = [
                0       10.6    0       %MCJ
                0.4     15.2    0       %PIJ
                0.65    18.2    0       %DIJ
                0.9     21      0       %FTP
            ];
            t(:,:,3) = [ 
                1.2   1.1
                1.1   0.9
                0.9   0.8
            ];
            diff(:,:,3) = [-1 1 0 0; 0 -1 1 0; 0 0 -1 1]*pts(:,:,3);                    
            
            %ring
            pts(:, :, 4) = [
                2.2     9.8     0       %MCJ
                3       13.8    0       %PIJ
                3.6     16.8    0       %DIJ
                4.2     19.4    0       %FTP
            ];
            t(:,:,4) = [ 
                1.0   1.0
                1.0   0.9
                0.9   0.8
            ];
            diff(:,:,4) = [-1 1 0 0; 0 -1 1 0; 0 0 -1 1]*pts(:,:,4);                    
            
            %pinky
            pts(:, :, 5) = [
                4.2     8.6     0       %MCJ
                5.6     11.4    0       %PIJ
                6.55    13.4    0       %DIJ
                7.6     15.5    0       %FTP    
            ];      
            t(:,:,5) = [ 
                1.0   1.0
                1.0   0.9
                0.9   0.7
            ];
            diff(:,:,5) = [-1 1 0 0; 0 -1 1 0; 0 0 -1 1]*pts(:,:,5);                                
            
            %palm
            palm = [
                2.2     3.4     0       4       2       1   %palm1
                3.2     5.4     0       2       2.5     1   %palm2
                3.75    8.6     0       2       2       1   %palm31
                1.75    8.6     0       2       2       1   %palm32
                -0.25   8.6     0       2       2       1   %palm33
                -2.25   8.6     0       2       2       1   %palm34
            ];
        end
        
        function [pts, dim, p]= fingerGeom(handGeom) 
            defGeom = CybergloveHand.handGeom('default');
            
            % scale factors with respect to default geometry
            s1 = handGeom.lPalm / defGeom.lPalm; % wrist to middle finger base
            s2 = handGeom.lMid / defGeom.lMid; % length of middle finger
            s3 = handGeom.lWidth / defGeom.lWidth; % index base to pinky base (hand width)
            s4 = handGeom.lThumb / defGeom.lThumb; % length of thumb
            
            [pts, t, diff, palm] = CybergloveHand.defaultJointAttributes();
            % fingers
            pts(1, 2, :) = pts(1,2,:) * s1;
            pts(1, 1, :) = pts(1,1,:) * s3;
            for i = 2:5
                pts(:,1:2,i) = reconstruct(pts(1,1:2,i), diff(:,1:2,i), s2);
            end            
            pts(:,1:2,1) = reconstruct(pts(1,1:2,1), diff(:,1:2,1), s4);            
            function p = reconstruct(base, diff, shrinkFactor)
                p = zeros(size(diff,1)+1, 2);
                p(1,:) = base;
                for j = 2:size(p,1)
                    theta = atan2(diff(j-1,2), diff(j-1,1));
                    l = norm(diff(j-1,1:2))* shrinkFactor;
                    p(j,1) = l*cos(theta);
                    p(j,2) = l*sin(theta);
                    p(j, :) = p(j, :) + p(j-1, :);
                end                
            end                        
            
            dim = zeros(3,5,5);            
            for i = 1:5
                dim(:,:,i) = getDim(pts(:,:,i), t(:,:,i));
            end
            function d= getDim(p, thicknesses)
                diffM = [-1 1 0 0; 0 -1 1 0; 0 0 -1 1];
                linkVectors = diffM*p;
                
                heights = diag(sqrt(linkVectors*linkVectors'));
                d = [thicknesses thicknesses heights];
            end
            
            % palm
            palm(:,1) = palm(:,1) * s3;
            palm(:,2) = palm(:,2) * s1;
            palm(:,4) = palm(:,4) * s3;
            palm(:,5) = palm(:,5) * s1;
            p.pts = palm(:,1:3);
            p.dim = [palm(:,6) palm(:,6) palm(:,4) palm(:,4) palm(:,5)];
        end
        
        % DH parameters of the thumb with roll 
        function [base, tool, poses, parms, linkidx]= dhParmsThumbWithRollPIJafterFlex(pts, dim)
            x= 1; y= 2; z=3; mcj= 1;            
            parms(5,1) = struct('dhp',[], 'dim', [], 'sensors', [], 'qlim', []);

            % thumb base       
            % x-axis is the axis of rotation. Hence move z to x
            base = troty(pi/2)*trotz(pi/2);

            % calculate thumb base transform
            thmbx = [-0.1 7 1];
            thmbx = thmbx./norm(thmbx, 2);
            thmby = cross([0 0 1], thmbx);
            thmby = thmby./norm(thmby, 2);
            thmbz = cross(thmbx, thmby);
            thmbz = thmbz./norm(thmbz, 2);
            rot = r2t([thmbx' thmby' thmbz']);    
            base = rot * base;

            % move to the mcj position
            base = transl(pts(mcj, x), pts(mcj, y), pts(mcj, z)) * base;

            % add dimensions and sensors to the links
            linkidx = [2 4 5];
            
            parms(1).dim = zeros(1,size(dim,2));
            parms(2).dim = dim(1,:);
            parms(3).dim = zeros(1,size(dim,2));
            parms(4).dim = dim(2,:);
            parms(5).dim = dim(3,:);
            
            parms(1).sensors = [];
            parms(2).sensors = CybergloveHand.ThumbProxPatch();
            parms(3).sensors = [];
            parms(4).sensors = CybergloveHand.ProxMidPatch();
            parms(5).sensors = CybergloveHand.DistalPatch();
            
            % add dh parameters
            % MCJF
            parms(1).dhp = CybergloveHand.dhpstruct(0, 0, 0, -pi/2, eye(4));   
            parms(1).qlim = deg2rad([40       -100]);
            
            % for MCJF, DIJ, PIJ calculate the xform for dh parameter extraction
            % Note that now x is z and y is x and z is y.
            xform = base\eye(4);
            ptsh = [pts'; ones(1, size(pts,1))];
            ptsh = xform*ptsh;
            ptx = ptsh(1:3, :)';

            % Link is modeled upright, (refer diagram in my notes), but is face down in the kinematic model            
            linkModel2LMFrontFaceDown = trotx(-pi/2);
            
            % Link is modeled in standard RHS, whereas the link tip system
            % has z (joint axis) along the x-axis direction.                
            linkModelFFD2JointSystemOrigin = troty(-pi/2)*trotx(-pi/2);  
            
            % Standard xformations common to all links:
            % - add the skew from straight ahead.            
            % - bring it back to Frame n-1 origin
            % - shift it down by half of link thickness            
            JointSystemOrigin2LinkPose = @(a, skew) transl(-a,-dim(2,1)/2,0)*troty(skew);           
            
            % for thumb with roll, origin always comes out at joint
            % position. No funny tricks required to make it so.
            dhpOriginAtJointPos();
                        
            function dhpOriginAtJointPos()             
                % MCJA
                diff = ptx(2, :) - ptx(1, :);
                d = diff(2);
                mcjl = norm([diff(3) diff(1)], 2);
                a = mcjl; 
                theta = -(pi/2 - atan2(diff(1), diff(3)));
                alpha = pi/2;
                skewMCJ = -(pi/2 - atan2(diff(1), diff(3)));
                
                jso2lp = transl(-mcjl,-dim(2,1)/2,0)*trotx(-atan(diff(2)/mcjl));
                lmffd2jso = trotx(-pi/2)*trotz(-pi/2);
                xform = jso2lp*lmffd2jso*linkModel2LMFrontFaceDown; 
                parms(2).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
                parms(2).qlim = deg2rad([30      -47]);
                                
                % PIJF
                diff = ptx(3, :) - ptx(2, :);
                d = 0;
                a = 0; pijl = norm(diff, 2);
                theta = pi/2;
                alpha = pi/2;                
                skewPIJ = -(pi/2 - atan2(diff(1), diff(3)) + skewMCJ);
                dispPIJ = norm(diff, 2)*sin(-skewPIJ);
                jso2lp = transl(-dim(2,1)/2,pijl,0)*trotx(skewPIJ);
                lmffd2jso = trotx(pi)*troty(pi/2);
                xform = jso2lp*lmffd2jso*linkModel2LMFrontFaceDown;
                parms(3).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, eye(4));
                parms(3).qlim = deg2rad([0     -90]);
                
                % PIJR
                d = pijl;
                a = 0;
                theta = 0;
                alpha = -pi/2;                
                parms(4).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
                parms(4).qlim = deg2rad([20       -90]);
                
                % DIJ                
                diff = ptx(4, :) - ptx(3, :);
                d = 0;
                a = norm(diff, 2);
                theta = -pi/2;
                alpha = 0;
                skewDIJ = -(pi/2 - atan2(diff(1), diff(3)) + skewMCJ);
                jso2lp = transl(0,0,dispPIJ)*JointSystemOrigin2LinkPose(a, skewDIJ);
                xform = jso2lp*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(5).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);       
                parms(5).qlim = deg2rad([25      -90]);                
            end            
            
            tool = eye(4);
            poses = [
                deg2rad([20 20  0 -60 0])
                deg2rad([-40 20  0 -75 0])
                deg2rad([-90 20  0 -90 0])

                deg2rad([20 -3 0 -30 0])
                deg2rad([-40 -3 -10 -30 0])
                deg2rad([-90 -3 -10 -30  0])

                deg2rad([20 -40 0 0 0])
                deg2rad([-40 -40 0 0 0])
                deg2rad([-90 -40 -10 0  0])
            ];            
        end 
        
        % DH parameters of the thumb with roll 
        function [base, tool, poses, parms, linkidx]= dhParmsThumbWithRollMCJ(pts, dim)
            x= 1; y= 2; z=3; mcj= 1;            
            parms(5,1) = struct('dhp',[], 'dim', [], 'sensors', [], 'qlim', []);            

            % thumb base       
            % x-axis is the axis of rotation. Hence move z to x
            base = troty(pi/2)*trotz(pi/2);

            % calculate thumb base transform
            thmbx = [-0.1 7 1];
            thmbx = thmbx./norm(thmbx, 2);
            thmby = cross([0 0 1], thmbx);
            thmby = thmby./norm(thmby, 2);
            thmbz = cross(thmbx, thmby);
            thmbz = thmbz./norm(thmbz, 2);
            rot = r2t([thmbx' thmby' thmbz']);    
            base = rot * base;

            % move to the mcj position
            base = transl(pts(mcj, x), pts(mcj, y), pts(mcj, z)) * base;

            % add dimensions and sensors to the links
            linkidx = [3 4 5];
            
            parms(1).dim = zeros(1,size(dim,2));
            parms(2).dim = zeros(1,size(dim,2));
            parms(3).dim = dim(1,:);
            parms(4).dim = dim(2,:);
            parms(5).dim = dim(3,:);
            
            parms(1).sensors = [];
            parms(2).sensors = [];
            parms(3).sensors = CybergloveHand.ThumbProxPatch();
            parms(4).sensors = CybergloveHand.ProxMidPatch();
            parms(5).sensors = CybergloveHand.DistalPatch();
            
            % add dh parameters
            % MCJF
            parms(1).dhp = CybergloveHand.dhpstruct(0, 0, 0, -pi/2, eye(4));  
            parms(1).qlim = deg2rad([20 -100]);
            
            % for MCJF, DIJ, PIJ calculate the xform for dh parameter extraction
            % Note that now x is z and y is x and z is y.
            xform = base\eye(4);
            ptsh = [pts'; ones(1, size(pts,1))];
            ptsh = xform*ptsh;
            ptx = ptsh(1:3, :)';

            % Link is modeled upright, (refer diagram in my notes), but is face down in the kinematic model            
            linkModel2LMFrontFaceDown = trotx(-pi/2);
            
            % Link is modeled in standard RHS, whereas the link tip system
            % has z (joint axis) along the x-axis direction.                
            linkModelFFD2JointSystemOrigin = troty(-pi/2)*trotx(-pi/2);  
            
            % Standard xformations common to all links:
            % - add the skew from straight ahead.            
            % - bring it back to Frame n-1 origin
            % - shift it down by half of link thickness            
            JointSystemOrigin2LinkPose = @(a, skew) transl(-a,-dim(2,1)/2,0)*troty(skew);           
            
            % for thumb with roll, origin always comes out at joint
            % position. No funny tricks required to make it so.
            dhpOriginAtJointPos();
                        
            function dhpOriginAtJointPos()                
                % MCJA
                diff = ptx(2, :) - ptx(1, :);
                d = 0;
                a = 0; mcjl = norm([diff(3) diff(1)], 2);
                theta = atan2(diff(1), diff(3));
                alpha = pi/2;
                skewMCJ = -(pi/2 - atan2(diff(1), diff(3)));
                % for proximal link to be affected by roll, this transform
                % gets applied in the next frame.
                jso2lp = transl(-dim(2,1)/2-d,mcjl,0)*trotz(atan(d/mcjl));
                lmffd2jso = trotz(pi)*troty(-pi/2);  
                
                % for proximal link not to be affected by roll, apply this
                % transform in current frame
                %jso2lp = transl(0,-dim(2,1)/2,0)*trotx(-atan(diff(2)/mcjl));
                %lmffd2jso = trotz(pi)*trotx(pi/2);
                xform = jso2lp*lmffd2jso*linkModel2LMFrontFaceDown;                 
                parms(2).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, eye(4));
                parms(2).qlim = deg2rad([20 -47]);
                
                % MCJR
                d = mcjl;
                a = diff(2);
                theta = pi/2;
                alpha = -pi/2;
                %xform = eye(4);
                parms(3).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
                parms(3).qlim = deg2rad([20 -90]);
                
                % PIJF
                diff = ptx(3, :) - ptx(2, :);                
                d = 0;
                a = norm(diff, 2);
                theta = -pi/2;
                alpha = 0;                
                skewPIJ = -(pi/2 - atan2(diff(1), diff(3)) + skewMCJ);
                dispPIJ = norm(diff, 2)*sin(-skewPIJ);
                jso2lp = JointSystemOrigin2LinkPose(a, skewPIJ);
                xform = jso2lp*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(4).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);                
                parms(4).qlim = deg2rad([0 -90]);
                
                % DIJ                
                diff = ptx(4, :) - ptx(3, :);
                d = 0;
                a = norm(diff, 2);
                skewDIJ = -(pi/2 - atan2(diff(1), diff(3)) + skewMCJ);
                jso2lp = transl(0,0,dispPIJ)*JointSystemOrigin2LinkPose(a, skewDIJ);
                xform = jso2lp*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(5).dhp = CybergloveHand.dhpstruct(d, a, 0, 0, xform);        
                parms(5).qlim = deg2rad([25 -90]);                                
            end
        
            tool = eye(4);            
            poses = [
                deg2rad([20 20 -60 0 0])
                deg2rad([-40 20 -75 0 0])
                deg2rad([-90 20 -90 0 0])



                deg2rad([20 -3 -30 0 0])
                deg2rad([-40 -3 -30 -10 0])
                deg2rad([-90 -3 -30 -10 0])


                deg2rad([20 -40 0 0 0])
                deg2rad([-40 -40 0 0 0])
                deg2rad([-90 -40 0 -10 0])
            ];
        end
        
        % DH parameters of the thumb with roll 
        function [base, tool, poses, parms, linkidx]= dhParmsThumbWithOrthoAxesAtMCJ(pts, dim)
            x= 1; y= 2; z=3; mcj= 1;            
            parms(5,1) = struct('dhp',[], 'dim', [], 'sensors', [], 'qlim', []);            

            % thumb base       
            % x-axis is the axis of rotation. Hence move z to x
            base = troty(pi/2)*trotz(pi/2);

            % calculate thumb base transform
            thmbx = [-0.1 7 1];
            thmbx = thmbx./norm(thmbx, 2);
            thmby = cross([0 0 1], thmbx);
            thmby = thmby./norm(thmby, 2);
            thmbz = cross(thmbx, thmby);
            thmbz = thmbz./norm(thmbz, 2);
            rot = r2t([thmbx' thmby' thmbz']);    
            base = rot * base;

            % move to the mcj position
            base = transl(pts(mcj, x), pts(mcj, y), pts(mcj, z)) * base;

            % add dimensions and sensors to the links
            linkidx = [3 4 5];
            
            parms(1).dim = zeros(1,size(dim,2));
            parms(2).dim = zeros(1,size(dim,2));
            parms(3).dim = dim(1,:);
            parms(4).dim = dim(2,:);
            parms(5).dim = dim(3,:);
            
            parms(1).sensors = [];
            parms(2).sensors = [];
            parms(3).sensors = CybergloveHand.ThumbProxPatch();
            parms(4).sensors = CybergloveHand.ProxMidPatch();
            parms(5).sensors = CybergloveHand.DistalPatch();
                                                
            
            % add dh parameters
            % MCJF
            parms(1).dhp = CybergloveHand.dhpstruct(0, 0, 0, -pi/2, eye(4));   
            parms(1).qlim = deg2rad([20       -100]);
            
            % for MCJF, DIJ, PIJ calculate the xform for dh parameter extraction
            % Note that now x is z and y is x and z is y.
            xform = base\eye(4);
            ptsh = [pts'; ones(1, size(pts,1))];
            ptsh = xform*ptsh;
            ptx = ptsh(1:3, :)';

            % Link is modeled upright, (refer diagram in my notes), but is face down in the kinematic model            
            linkModel2LMFrontFaceDown = trotx(-pi/2);
            
            % Link is modeled in standard RHS, whereas the link tip system
            % has z (joint axis) along the x-axis direction.                
            linkModelFFD2JointSystemOrigin = troty(-pi/2)*trotx(-pi/2);  
            
            % Standard xformations common to all links:
            % - add the skew from straight ahead.            
            % - bring it back to Frame n-1 origin
            % - shift it down by half of link thickness            
            JointSystemOrigin2LinkPose = @(a, skew) transl(-a,-dim(2,1)/2,0)*troty(skew);           
            
            % for thumb with roll, origin always comes out at joint
            % position. No funny tricks required to make it so.
            dhpOriginAtJointPos();
                        
            function dhpOriginAtJointPos()             
                % MCJA
                d = 0;
                a = 0;
                theta = pi/2;
                alpha = pi/2;
                parms(2).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, eye(4));
                parms(2).qlim = deg2rad([20      -47]);
                                
                % MCJR
                diff = ptx(2, :) - ptx(1, :);                
                prjDiff = norm([diff(3) diff(1)]);
                skew = atan2(diff(1), diff(3));
                d = prjDiff/cos(pi/2 - skew);
                a = diff(2);
                theta = pi/2;
                alpha = -(pi - skew);
                skewMCJ = -(pi/2 - skew);
                dispMCJ = prjDiff*tan(pi/2-skew);
                elevMCJ = atan(diff(2)/prjDiff);
                jso2lp = transl(-dim(1,1)/2-a, prjDiff, dispMCJ)*trotz(elevMCJ);
                lmffd2jso = trotz(pi)*troty(-pi/2);
                xform = jso2lp*lmffd2jso*linkModel2LMFrontFaceDown;
                parms(3).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
                parms(3).qlim = deg2rad([-180     180]);

                % PIJF                
                diff = ptx(3, :) - ptx(2, :);
                pijl = norm(diff);                                
                skewPIJ = -(pi/2 - atan2(diff(1), diff(3)) + skewMCJ);
                dispPIJ = pijl*sin(-skewPIJ) + dispMCJ;
                d = 0;                
                a = pijl;
                theta = -(pi/2+elevMCJ);
                alpha = 0;                
                jso2lp = transl(-pijl,-dim(1,1)/2,dispMCJ)*troty(skewPIJ);
                lmffd2jso = trotz(-pi/2)*troty(-pi/2);
                xform = jso2lp*lmffd2jso*linkModel2LMFrontFaceDown;
                parms(4).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
                parms(4).qlim = deg2rad([0       -90]);
                
                % DIJF                
                diff = ptx(4, :) - ptx(3, :);
                dijl = norm(diff);
                d = 0;
                a = dijl;
                theta = 0;
                alpha = 0;
                skewDIJ = -(pi/2 - atan2(diff(1), diff(3)) + skewMCJ + skewPIJ);
                dispDIJ = dijl*sin(-skewDIJ) + dispPIJ;
                jso2lp = transl(-dijl,-dim(1,1)/2,dispPIJ)*troty(skewDIJ);                
                lmffd2jso = trotz(-pi/2)*troty(-pi/2);
                xform = jso2lp*lmffd2jso*linkModel2LMFrontFaceDown;
                parms(5).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
                parms(5).qlim = deg2rad([25      -90]);
                
                tool = transl(0,0,dispDIJ)*troty(skewDIJ);
            end            
        end           
                 
        
        % DH parameters of the thumb with roll 
        function [base, tool, poses, parms, linkidx]= dhParmsThumbWithOrthoAxesAtMCJ_old(pts, dim)
            x= 1; y= 2; z=3; mcj= 1;            
            parms(5,1) = struct('dhp',[], 'dim', [], 'sensors', [], 'qlim', []);            

            % thumb base       
            % x-axis is the axis of rotation. Hence move z to x
            base = troty(pi/2)*trotz(pi/2);

            % calculate thumb base transform
            thmbx = [-0.1 7 1];
            thmbx = thmbx./norm(thmbx, 2);
            thmby = cross([0 0 1], thmbx);
            thmby = thmby./norm(thmby, 2);
            thmbz = cross(thmbx, thmby);
            thmbz = thmbz./norm(thmbz, 2);
            rot = r2t([thmbx' thmby' thmbz']);    
            base = rot * base;

            % move to the mcj position
            base = transl(pts(mcj, x), pts(mcj, y), pts(mcj, z)) * base;

            % add dimensions and sensors to the links
            linkidx = [3 4 5];
            
            parms(1).dim = zeros(1,size(dim,2));
            parms(2).dim = zeros(1,size(dim,2));
            parms(3).dim = dim(1,:);
            parms(4).dim = dim(2,:);
            parms(5).dim = dim(3,:);
            
            parms(1).sensors = [];
            parms(2).sensors = [];
            parms(3).sensors = CybergloveHand.ThumbProxPatch();
            parms(4).sensors = CybergloveHand.ProxMidPatch();
            parms(5).sensors = CybergloveHand.DistalPatch();
            
            % add dh parameters
            % MCJF
            parms(1).dhp = CybergloveHand.dhpstruct(0, 0, 0, -pi/2, eye(4));   
            parms(1).qlim = [-pi pi];
            
            % for MCJF, DIJ, PIJ calculate the xform for dh parameter extraction
            % Note that now x is z and y is x and z is y.
            xform = base\eye(4);
            ptsh = [pts'; ones(1, size(pts,1))];
            ptsh = xform*ptsh;
            ptx = ptsh(1:3, :)';

            % Link is modeled upright, (refer diagram in my notes), but is face down in the kinematic model            
            linkModel2LMFrontFaceDown = trotx(-pi/2);
            
            % Link is modeled in standard RHS, whereas the link tip system
            % has z (joint axis) along the x-axis direction.                
            linkModelFFD2JointSystemOrigin = troty(-pi/2)*trotx(-pi/2);  
            
            % Standard xformations common to all links:
            % - add the skew from straight ahead.            
            % - bring it back to Frame n-1 origin
            % - shift it down by half of link thickness            
            JointSystemOrigin2LinkPose = @(a, skew) transl(-a,-dim(2,1)/2,0)*troty(skew);           
            
            % for thumb with roll, origin always comes out at joint
            % position. No funny tricks required to make it so.
            hold on;
            dhpOriginAtJointPos();
                        
            function dhpOriginAtJointPos()             
                % MCJA
                d = 0;
                a = 0;
                theta = pi/2;
                alpha = pi/2;
                parms(2).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, eye(4));                      
                parms(2).qlim = [-pi pi];
                
                % MCJR                
                diff21 = ptx(2, :) - ptx(1, :);
                projMCJ = norm(diff21([3 1]));
                skewMCJ = -(pi/2 -  atan2(diff21(1), diff21(3)));
                
                d = projMCJ/cos(-skewMCJ);
                a = diff21(2);
                theta = pi/2;
                alpha = -(-skewMCJ + pi/2);                
                                
                dispMCJ = projMCJ*tan(-skewMCJ);
                elevMCJ = atan(diff21(2)/projMCJ);
                jso2lp = transl(-dim(1,1)/2-a, projMCJ, dispMCJ)*trotz(elevMCJ);
                lmffd2jso = trotz(pi)*troty(-pi/2);
                xform = jso2lp*lmffd2jso*linkModel2LMFrontFaceDown;
                parms(3).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
                parms(3).qlim = [-pi pi];
                
                % PIJF                
                diff32 = ptx(3, :) - ptx(2, :);                
                diff31 = ptx(3, :) - ptx(1, :);                
                
                skew32PIJ = -(pi/2 - atan2(diff32(1), diff32(3)) + skewMCJ);
                skew31PIJ = -(pi/2 - atan2(diff31(1), diff31(3)) + skewMCJ);
                projPIJ = norm(diff31([1 3]));
                
                skewPIJ = skew32PIJ;
                
                d = 0;
                a = (projPIJ*cos(-skew31PIJ)/cos(-skewMCJ)) - (projMCJ/cos(-skewMCJ));
                theta = -(pi/2+elevMCJ);
                alpha = 0;                
                
                tx = projPIJ*cos(-skew31PIJ)-projMCJ;
                tz = projPIJ*cos(-skew31PIJ)*tan(-skewMCJ) + projPIJ*sin(-skew31PIJ);
                jso2lp = transl(-tx,-dim(1,1)/2,tz)*troty(skew32PIJ);
                lmffd2jso = trotz(-pi/2)*troty(-pi/2);
                xform = jso2lp*lmffd2jso*linkModel2LMFrontFaceDown;
                parms(4).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
                parms(4).qlim = [-pi pi];
                
                % DIJF                
                diff43 = ptx(4, :) - ptx(3, :);
                diff41 = ptx(4, :) - ptx(1, :);
                skew41DIJ = -(pi/2 - atan2(diff41(1), diff41(3)) + skewMCJ);
                skew43DIJ = -(pi/2 - atan2(diff43(1), diff43(3)) + skewMCJ + skewPIJ);
                projDIJ = norm(diff41([1 3]));
                
                d = 0;
                a = (projDIJ*cos(-skew41DIJ)/cos(-skewMCJ)) - (projPIJ*cos(-skew31PIJ)/cos(-skewMCJ));
                theta = 0;
                alpha = 0;                
                
                tx = projDIJ*cos(-skew41DIJ) - projPIJ*cos(-skew31PIJ);
                tz = projDIJ*cos(-skew41DIJ)*tan(-skewMCJ) + projDIJ*sin(-skew41DIJ);
                jso2lp = transl(-tx,-dim(1,1)/2,tz)*troty(skew43DIJ);
                lmffd2jso = trotz(-pi/2)*troty(-pi/2);
                xform = jso2lp*lmffd2jso*linkModel2LMFrontFaceDown;
                parms(5).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
                parms(5).qlim = [-pi pi];
            end        
            
            tool = eye(4);
            poses = [
                deg2rad([20 20 -60 0 0])
                deg2rad([-40 20 -75 0 0])
                deg2rad([-90 20 -90 0 0])



                deg2rad([20 -3 -30 0 0])
                deg2rad([-40 -3 -30 -10 0])
                deg2rad([-90 -3 -30 -10 0])


                deg2rad([20 -40 0 0 0])
                deg2rad([-40 -40 0 0 0])
                deg2rad([-90 -40 0 -10 0])
            ];
            
        end         
        
        % DH parameters of the thumb
        function [base, parms, linkidx]= dhParmsThumb(pts, dim, originAtJointPos)
            x= 1; y= 2; z=3; mcj= 1;            
            parms(4,1) = struct('dhp',[], 'dim', [], 'sensors', []);            

            % thumb base       
            % x-axis is the axis of rotation. Hence move z to x
            base = troty(pi/2)*trotz(pi/2);

            % calculate thumb base transform
            thmbx = [-0.1 7 1];
            thmbx = thmbx./norm(thmbx, 2);
            thmby = cross([0 0 1], thmbx);
            thmby = thmby./norm(thmby, 2);
            thmbz = cross(thmbx, thmby);
            thmbz = thmbz./norm(thmbz, 2);
            rot = r2t([thmbx' thmby' thmbz']);    
            base = rot * base;

            % move to the mcj position
            base = transl(pts(mcj, x), pts(mcj, y), pts(mcj, z)) * base;

            % add dimensions and sensors to the links
            linkidx = [2 3 4];
            
            parms(1).dim = zeros(1,size(dim,2));
            parms(2).dim = dim(1,:);
            parms(3).dim = dim(2,:);
            parms(4).dim = dim(3,:);
            
            parms(1).sensors = [];
            parms(2).sensors = CybergloveHand.ThumbProxPatch();
            parms(3).sensors = CybergloveHand.ProxMidPatch();
            parms(4).sensors = CybergloveHand.DistalPatch();
            
            % add dh parameters
            % MCJA
            parms(1).dhp = CybergloveHand.dhpstruct(0, 0, 0, -pi/2, eye(4));   
            
            % for MCJF, DIJ, PIJ calculate the xform for dh parameter extraction
            % Note that now x is z and y is x and z is y.
            xform = base\eye(4);
            ptsh = [pts'; ones(1, size(pts,1))];
            ptsh = xform*ptsh;
            ptx = ptsh(1:3, :)';

            % Link is modeled upright, (refer diagram in my notes), but is face down in the kinematic model            
            linkModel2LMFrontFaceDown = trotx(-pi/2);
            
            % Link is modeled in standard RHS, whereas the link tip system
            % has z (joint axis) along the x-axis direction.                
            linkModelFFD2JointSystemOrigin = troty(-pi/2)*trotx(-pi/2);  
            
            % Standard xformations common to all links:
            % - add the skew from straight ahead.            
            % - bring it back to Frame n-1 origin
            % - shift it down by half of link thickness            
            JointSystemOrigin2LinkPose = @(a, diff, skew) transl(-a,-dim(2,1)/2,0)*troty(skew);           
            
            if originAtJointPos
                dhpOriginAtJointPos();
            else
                dhpOriginNotAtJointPos();
            end
                        
            function dhpOriginAtJointPos()                
                % MCJF
                diff = ptx(2, :) - ptx(1, :);
                d = diff(2);
                a = norm([diff(3) diff(1)], 2);
                thetaMCJ = -(pi/2 - atan2(diff(1), diff(3)));
                alpha = pi/2;
                skewMCJ = -(pi/2 - atan2(diff(1), diff(3)));
                jso2lp = transl(0,-d,0)*JointSystemOrigin2LinkPose(a, diff, 0)*trotz(atan(d/a));
                xform = jso2lp*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(2).dhp = CybergloveHand.dhpstruct(d, a, thetaMCJ, alpha, xform);
                
                % PIJ
                diff = ptx(3, :) - ptx(2, :);                
                d = 0;
                a = norm(diff, 2);
                skewPIJ = -(pi/2 - atan2(diff(1), diff(3)) + skewMCJ);
                dispPIJ = norm(diff, 2)*sin(-skewPIJ);                
                jso2lp = transl(0,0,-d)*JointSystemOrigin2LinkPose(a, diff, skewPIJ);
                xform = jso2lp*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(3).dhp = CybergloveHand.dhpstruct(d, a, 0, 0, xform);
                
                % DIJ                
                diff = ptx(4, :) - ptx(3, :);
                d = 0;
                a = norm(diff, 2);
                skewDIJ = -(pi/2 - atan2(diff(1), diff(3)) + skewMCJ);
                jso2lp = transl(0,0,-d+dispPIJ)*JointSystemOrigin2LinkPose(a, diff, skewDIJ);
                xform = jso2lp*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(4).dhp = CybergloveHand.dhpstruct(d, a, 0, 0, xform);                
            end
            
            function dhpOriginNotAtJointPos()
                % MCJF
                diff = ptx(2, :) - ptx(1, :);
                d = diff(2);
                a = diff(1);
                theta = 0;
                alpha = pi/2;
                skew = -(pi/2 - atan2(diff(1), diff(3)));
                jso2lp = transl(0,-d,0)*JointSystemOrigin2LinkPose(a, diff, skew)*trotz(atan(d/a));
                xform = jso2lp*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(2).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
                
                % PIJ
                diff = ptx(3, :) - ptx(2, :);
                d = 0;
                a = diff(1);
                skew = -(pi/2 - atan2(diff(1), diff(3)));
                jso2lp = transl(0,0,-d+ptx(2,3))*JointSystemOrigin2LinkPose(a, diff, skew);
                xform = jso2lp*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(3).dhp = CybergloveHand.dhpstruct(d, a, 0, 0, xform);
                
                % DIJ                
                diff = ptx(4, :) - ptx(3, :);
                d = 0;
                a = diff(1);
                skew = -(pi/2 - atan2(diff(1), diff(3)));
                jso2lp = transl(0,0,-d+ptx(3,3))*JointSystemOrigin2LinkPose(a, diff, skew);
                xform = jso2lp*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(4).dhp = CybergloveHand.dhpstruct(d, a, 0, 0, xform);               
            end
        end

        % DH parameters of the thumb with roll
        function [base, parms, linkidx]= dhParmsThumbWithRollPIJbeforeFlex(pts, dim, ~)
            x= 1; y= 2; z=3; mcj= 1;            
            parms(5,1) = struct('dhp',[], 'dim', [], 'sensors', []);            

            % thumb base       
            % x-axis is the axis of rotation. Hence move z to x
            base = troty(pi/2)*trotz(pi/2);

            % calculate thumb base transform
            thmbx = [-0.1 7 1];
            thmbx = thmbx./norm(thmbx, 2);
            thmby = cross([0 0 1], thmbx);
            thmby = thmby./norm(thmby, 2);
            thmbz = cross(thmbx, thmby);
            thmbz = thmbz./norm(thmbz, 2);
            rot = r2t([thmbx' thmby' thmbz']);    
            base = rot * base;

            % move to the mcj position
            base = transl(pts(mcj, x), pts(mcj, y), pts(mcj, z)) * base;

            % add dimensions and sensors to the links
            linkidx = [2 4 5];
            
            parms(1).dim = zeros(1,size(dim,2));
            parms(2).dim = dim(1,:);
            parms(3).dim = zeros(1,size(dim,2));
            parms(4).dim = dim(2,:);
            parms(5).dim = dim(3,:);
            
            parms(1).sensors = [];
            parms(2).sensors = CybergloveHand.ThumbProxPatch();
            parms(3).sensors = [];
            parms(4).sensors = CybergloveHand.ProxMidPatch();
            parms(5).sensors = CybergloveHand.DistalPatch();
            
            % add dh parameters
            % MCJF
            parms(1).dhp = CybergloveHand.dhpstruct(0, 0, 0, -pi/2, eye(4));   
            
            % for MCJF, DIJ, PIJ calculate the xform for dh parameter extraction
            % Note that now x is z and y is x and z is y.
            xform = base\eye(4);
            ptsh = [pts'; ones(1, size(pts,1))];
            ptsh = xform*ptsh;
            ptx = ptsh(1:3, :)';

            % Link is modeled upright, (refer diagram in my notes), but is face down in the kinematic model            
            linkModel2LMFrontFaceDown = trotx(-pi/2);
            
            % Link is modeled in standard RHS, whereas the link tip system
            % has z (joint axis) along the x-axis direction.                
            linkModelFFD2JointSystemOrigin = troty(-pi/2)*trotx(-pi/2);  
            
            % Standard xformations common to all links:
            % - add the skew from straight ahead.            
            % - bring it back to Frame n-1 origin
            % - shift it down by half of link thickness            
            JointSystemOrigin2LinkPose = @(a, skew) transl(-a,-dim(2,1)/2,0)*troty(skew);           
            
            % for thumb with roll, origin always comes out at joint
            % position. No funny tricks required to make it so.
            dhpOriginAtJointPos();
                        
            function dhpOriginAtJointPos()                
                % MCJA
                diff = ptx(2, :) - ptx(1, :);
                d = diff(2);
                a = 0; mcjl = norm([diff(3) diff(1)], 2);
                theta = atan2(diff(1), diff(3));                
                alpha = pi/2;
                skewMCJ = -(pi/2 - atan2(diff(1), diff(3)));
                % for proximal link to be affected by roll, this transform
                % gets applied in the next frame.
                % jso2lp = transl(-dim(2,1)/2-d,mcjl,0)*trotz(atan(d/mcjl));
                % lmffd2jso = trotz(pi)*troty(-pi/2);  
                
                % for proximal link not to be affected by roll, apply this
                % transform in current frame
                jso2lp = transl(0,-dim(2,1)/2-d,0)*trotx(-atan(d/mcjl));
                lmffd2jso = trotz(pi)*trotx(pi/2);
                xform = jso2lp*lmffd2jso*linkModel2LMFrontFaceDown; 
                parms(2).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
                
                % PIJR
                d = mcjl;
                a = 0;
                theta = pi/2;
                alpha = -pi/2;
                xform = eye(4);
                parms(3).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
                
                % PIJF
                diff = ptx(3, :) - ptx(2, :);                
                d = 0;
                a = norm(diff, 2);
                theta = -pi/2;
                alpha = 0;                
                skewPIJ = -(pi/2 - atan2(diff(1), diff(3)) + skewMCJ);
                dispPIJ = norm(diff, 2)*sin(-skewPIJ);
                jso2lp = JointSystemOrigin2LinkPose(a, skewPIJ);
                xform = jso2lp*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(4).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);                
                
                % DIJ                
                diff = ptx(4, :) - ptx(3, :);
                d = 0;
                a = norm(diff, 2);
                skewDIJ = -(pi/2 - atan2(diff(1), diff(3)) + skewMCJ);
                jso2lp = transl(0,0,dispPIJ)*JointSystemOrigin2LinkPose(a, skewDIJ);
                xform = jso2lp*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(5).dhp = CybergloveHand.dhpstruct(d, a, 0, 0, xform);                
            end
            
        end            
        
        % DH parameters of the fingers
        function [base, parms, linkidx]= dhParmsFinger(pts, dim, originAtJointPos, qlim)
            x= 1; y= 2; z=3; mcj= 1; pij= 2;            
            parms(4,1) = struct('dhp',[], 'dim', [], 'sensors', [], 'qlim', []);            
            
            % finger base       
            % x-axis is the axis of rotation. Hence move z to x
            base = troty(pi/2)*trotz(pi/2);

            % consider effect of mcj-pij link skew
            diff = pts(pij,:) - pts(mcj,:);
            skew = atan2(diff(y), diff(x))-pi/2;
            base = trotz(skew) * base;

            % move to the mcj position.
            base = transl(pts(mcj, x), pts(mcj, y), pts(mcj, z)) * base;

            % add dimensions and sensors to the links
            linkidx = [2 3 4];
            
            parms(1).dim = zeros(1,size(dim,2));
            parms(2).dim = dim(1,:);
            parms(3).dim = dim(2,:);
            parms(4).dim = dim(3,:);
            
            parms(1).sensors = [];
            parms(2).sensors = CybergloveHand.ProxMidPatch();
            parms(3).sensors = CybergloveHand.ProxMidPatch();
            parms(4).sensors = CybergloveHand.DistalPatch();
            
            % add dh parameters
            % MCJA
            parms(1).dhp = CybergloveHand.dhpstruct(0, 0, 0, -pi/2, eye(4));   
            parms(1).dim = zeros(1, size(dim,2));
            parms(1).qlim = qlim(1,:);

            % for MCJF, DIJ, PIJ calculate the xform for dh parameter extraction
            xform = base\eye(4);
            ptsh = [pts'; ones(1, size(pts,1))];
            ptsh = xform*ptsh;
            ptx = ptsh(1:3, :)';
            
            % Link is modeled upright, (refer diagram in my notes), but is face down in the kinematic model            
            linkModel2LMFrontFaceDown = trotx(-pi/2);
            
            % Link is modeled in standard RHS, whereas the link tip system
            % has z (joint axis) along the x-axis direction.                
            linkModelFFD2JointSystemOrigin = troty(-pi/2)*trotx(-pi/2);  
            
            % Standard xformations common to all links:
            % - add the skew from straight ahead : (roty(atan2(diff(1), diff(3))-pi/2)          
            % - bring it back to Frame n-1 origin :  trans(-a,0,-d)
            % - shift it down by half of link thickness : trans(0, -dim(2,1)/2, 0)          
            JointSystemOrigin2LinkPose = @(a, d, diff) transl(-a,-dim(2,1)/2,-d)*troty(atan2(diff(1), diff(3))-pi/2);
            
            if originAtJointPos
                dhpOriginAtJointPos();
            else
                dhpOriginNotAtJointPos();
            end            
            
            function dhpOriginAtJointPos()
                % MCJF
                diff = ptx(2, :) - ptx(1, :);                
                a = diff(1);
                d = diff(3);
                xform = JointSystemOrigin2LinkPose(a, d, diff)*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(2).dhp = CybergloveHand.dhpstruct(d, a, 0, pi/2, xform);  
                parms(2).qlim = qlim(2,:);
                
                % PIJ
                diff = ptx(3, :) - ptx(2, :);                
                a = diff(1);
                d = diff(3);
                xform = JointSystemOrigin2LinkPose(a, d, diff)*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(3).dhp = CybergloveHand.dhpstruct(d, a, 0, 0, xform);           
                parms(3).qlim = qlim(3,:);
                
                % DIJ              
                diff = ptx(4, :) - ptx(3, :);                
                a = diff(1);
                d = diff(3);
                xform = JointSystemOrigin2LinkPose(a, d, diff)*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(4).dhp = CybergloveHand.dhpstruct(d, a, 0, 0, xform);        
                parms(4).qlim = qlim(4,:);
            end
            
            function dhpOriginNotAtJointPos()
                % MCJF
                diff = ptx(2, :) - ptx(1, :);                
                a = diff(1);
                d = 0;
                xform = JointSystemOrigin2LinkPose(a, d, diff)*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(2).dhp = CybergloveHand.dhpstruct(d, a, 0, pi/2, xform);                
                
                % PIJ
                diff = ptx(3, :) - ptx(2, :);                
                a = diff(1);
                d = 0;
                xform = JointSystemOrigin2LinkPose(a, d, diff)*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(3).dhp = CybergloveHand.dhpstruct(d, a, 0, 0, xform);                
                
                % DIJ              
                diff = ptx(4, :) - ptx(3, :);                
                a = diff(1);
                d = 0;
                xform = JointSystemOrigin2LinkPose(a, d, diff)*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
                parms(4).dhp = CybergloveHand.dhpstruct(d, a, 0, 0, xform);                                
            end
        end        
  
        function [base, parms]= dhParmsPalm(pts, dim)
            parms(6,1) = struct('dhp',[], 'dim', [], 'sensors', [], 'qlim', []);
            
            % finger base       
            base = transl(pts(1,1), pts(1,2), pts(1,3))*trotz(pi/2)*trotx(pi/2);

            % Link is modeled upright, (refer diagram in my notes), but is face down in the kinematic model
            linkModel2LMFrontFaceDown = trotx(-pi/2);
            
            % Link is modeled in standard RHS, whereas the link tip system
            % has z (joint axis) along the x-axis direction.                
            linkModelFFD2JointSystemOrigin = troty(-pi/2)*trotx(-pi/2);  
            
            % Move it from the link tip to the joint position
            % - bring it back to Frame n-1 origin :  trans(-a,0,-d)
            % - shift it down by half of link thickness : trans(0, -dim(2,1)/2, 0)
            JointSystemOrigin2LinkPose = @(a, d, t) transl(-a,-t/2,-d);            

            parms(1).dim = dim(1,:);
            parms(1).sensors = CybergloveHand.Palm1Patch();
            theta = 0; alpha = 0; a = pts(2,2) - pts(1,2); d = pts(2,1) - pts(1,1);
            xform = JointSystemOrigin2LinkPose(a, d, parms(1).dim(1))*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
            parms(1).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
            parms(1).qlim = [0 0];
                        
            parms(2).dim = dim(2,:);
            parms(2).sensors = CybergloveHand.Palm2Patch();
            theta = 0; alpha = 0; a = pts(3,2) - pts(2,2); d = pts(3,1) - pts(2,1);
            xform = JointSystemOrigin2LinkPose(a, d, parms(2).dim(1))*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
            parms(2).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
            parms(2).qlim = [0 0];
                        
            parms(3).dim = dim(3,:);
            parms(3).sensors = CybergloveHand.Palm3_5Patch();
            theta = 0; alpha = 0; a = 0; d = pts(4,1) - pts(3,1);
            xform = JointSystemOrigin2LinkPose(a, d, parms(3).dim(1))*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
            parms(3).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
            parms(3).qlim = [0 0];            
            
            parms(4).dim = dim(4,:);
            parms(4).sensors = CybergloveHand.Palm3_5Patch();
            theta = 0; alpha = 0; a = 0; d = pts(5,1) - pts(4,1);
            xform = JointSystemOrigin2LinkPose(a, d, parms(4).dim(1))*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
            parms(4).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
            parms(4).qlim = [0 0];            
                        
            parms(5).dim = dim(5,:);
            parms(5).sensors = CybergloveHand.Palm3_5Patch();
            theta = 0; alpha = 0; a = 0; d = pts(6,1) - pts(5,1);
            xform = JointSystemOrigin2LinkPose(a, d, parms(5).dim(1))*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
            parms(5).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
            parms(5).qlim = [0 0];            
            
            parms(6).dim = dim(6,:);
            parms(6).sensors = CybergloveHand.Palm6Patch();
            theta = 0; alpha = 0; a = 0; d = 0;
            xform = JointSystemOrigin2LinkPose(a, d, parms(6).dim(1))*linkModelFFD2JointSystemOrigin*linkModel2LMFrontFaceDown;
            parms(6).dhp = CybergloveHand.dhpstruct(d, a, theta, alpha, xform);
            parms(6).qlim = [0 0];                        
        end
            
        % 0.05, 0.16,   0.005, 0.1
        function sp = DistalPatch()
            sp(1).geom = struct('rowspc', 0.05, 'colspc', 0.05, 'senselArea', 0.16, 'nrows', 4, 'ncols', 4, 'placement', eye(4));
            sp(1).pos = 'front';
            sp(2).geom = struct('rowspc', 0.05, 'colspc', 0.05, 'senselArea', 0.16, 'nrows', 4, 'ncols', 4, 'placement', eye(4));
            sp(2).pos = 'left';
        end
        
        function sp = ProxMidPatch()
            sp(1).geom = struct('rowspc', 0.05, 'colspc', 0.05, 'senselArea', 0.16, 'nrows', 3, 'ncols', 4, 'placement', eye(4));
            sp(1).pos = 'front';
            sp(2).geom = struct('rowspc', 0.05, 'colspc', 0.05, 'senselArea', 0.16, 'nrows', 3, 'ncols', 4, 'placement', eye(4));
            sp(2).pos = 'left';            
        end
        
        function sp = ThumbProxPatch()
            sp(1).geom = struct('rowspc', 0.05, 'colspc', 0.05, 'senselArea', 0.16, 'nrows', 9, 'ncols', 5, 'placement', trotz(-pi/2));
            sp(1).pos = 'front';
        end        
        
        function sp = Palm1Patch()
            sp(1).geom = struct('rowspc', 0.05, 'colspc', 0.05, 'senselArea', 0.16, 'nrows', 4, 'ncols', 8, 'placement', eye(4));
            sp(1).pos = 'front';
        end
        
        function sp = Palm2Patch()
            sp(1).geom = struct('rowspc', 0.05, 'colspc', 0.05, 'senselArea', 0.16, 'nrows', 5, 'ncols', 4, 'placement', eye(4));
            sp(1).pos = 'front';
        end

        function sp = Palm3Patch()
            sp(1).geom = struct('rowspc', 0.05, 'colspc', 0.05, 'senselArea', 0.16, 'nrows', 4, 'ncols', 19, 'placement', eye(4));
            sp(1).pos = 'front';
        end       
        
        function sp = Palm6Patch()
            sp(1).geom = struct('rowspc', 0.05, 'colspc', 0.05, 'senselArea', 0.16, 'nrows', 4, 'ncols', 4, 'placement', eye(4));
            sp(1).pos = 'front';
            sp(2).geom = struct('rowspc', 0.05, 'colspc', 0.05, 'senselArea', 0.16, 'nrows', 4, 'ncols', 4, 'placement', eye(4));
            sp(2).pos = 'left';            
        end

        function sp = Palm3_5Patch()
            sp(1).geom = struct('rowspc', 0.05, 'colspc', 0.05, 'senselArea', 0.16, 'nrows', 4, 'ncols', 5, 'placement', eye(4));
            sp(1).pos = 'front';
        end               
    end
end