classdef SensorPatch < handle
    properties 
        sensorTransform = eye(4);        
        model
        vis
        relevant
        importance
        avg
        sum        
        hand
        oppositions
    end
    
    properties (Dependent, SetAccess = private)
        pts
    end   

    properties (Dependent)
        raw
        cal
        hLoc
    end
        
    properties (Access = private)        
        valRaw
        valCal        
        placementTransform
        myhandles
        myKC
        myLoc
    end
    
    methods
        function sp = SensorPatch(geom)
            sp.model = SensorPatch.patchModel(geom);
            sp.valRaw = zeros(size(sp.model.p, 1), 1);
            sp.valCal = zeros(size(sp.valRaw));
            if ~isfield(geom, 'placement') || isempty(geom.placement)
                sp.placementTransform = eye(4);
            else
                sp.placementTransform = geom.placement;
            end
            sp.myhandles = [];
            sp.importance = 0;     
            sp.relevant = 0;
        end
        
        function visualize(s)
            try
                if ~isempty(s.myhandles)
                    delete(s.myhandles); s.myhandles = [];
                end
            catch exception
                s.myhandles = [];
            end            
            
            if ~s.relevant, return; end;
            
            points = s.pts;            
            switch s.vis.type
                case 'pressurebar'             
                    active = find(s.valRaw);
                    if isempty(active) || sum(s.valRaw)/numel(active) <= s.vis.threshold
                        return;
                    end
                    val = s.valRaw / 255 * s.vis.height;
                    
                    % draw points                    
                    h1 = [];
                    if s.vis.bar
                        points.n = points.p + diag(val)*repmat(points.ndir, length(val), 1);
                        h1 = plot3([points.p(:,1)'; points.n(:,1)'], [points.p(:,2)'; points.n(:,2)'], [points.p(:,3)'; points.n(:,3)'], ...
                                            s.vis.barProperties{:});
                    end
            
                    % draw centroid
                    h2 = [];
                    if s.vis.centroid
                        n = points.centroid + points.ndir*(sum(val)/numel(active));
                        l = [points.centroid ; n];                      
                        h2 = plot3(l(:,1), l(:,2), l(:,3), s.vis.centroidProperties{:});
                    end
        
                    s.myhandles = [h1' h2'];
                    
                case 'importancebar'
%                    plot3(points.centroid(1), points.centroid(2), points.centroid(3), '.k', 'MarkerSize', 14);
                    if s.importance <= s.vis.threshold
                        return;
                    end
                    
                    val = ones(size(s.valRaw))*s.vis.height*s.importance;
                    cold = colormap();
                    c = colormap(flipud(copper(100)));
                    clr = ceil(s.importance * size(c,1));
                    points.n = points.p + diag(val)*repmat(points.ndir, length(val), 1);
                    h1 = plot3([points.p(:,1)'; points.n(:,1)'], [points.p(:,2)'; points.n(:,2)'], [points.p(:,3)'; points.n(:,3)'], ...
                                        s.vis.barProperties{:}, 'Color', c(clr, :));                                                        
                    s.myhandles = h1';   
                    colormap(cold);
                    
%                case 'intensity'
%                     active = find(s.valRaw);
%                     if isempty(active) || sum(s.valRaw)/numel(active) <= s.vis.threshold
%                         return;
%                     end
                    
%                     val = s.valRaw / 255;
%                     points.n = points.p + diag(s.vis.height)*repmat(points.ndir, length(val), 1);
%                     
%                     x = [points.p(:,1)'; points.n(:,1)']; y = [points.p(:,2)'; points.n(:,2)']; z = [points.p(:,3)'; points.n(:,3)'];
%                     % draw places
%                     h1 = plot3(x, y, z, s.vis.placeProperties{:});
%                     h1 = h1';
%                     % draw tactile intensity
%                     for pi = 1:size(x,2)
%                         h1 = [h1 patchline(x(:,pi), y(:,pi), z(:,pi), s.vis.barProperties{:}, 'edgealpha', val(pi));];
%                     end                    
%             
%                     % draw centroid
%                     if s.vis.centroid
%                         n = points.centroid + points.ndir*s.vis.height;
%                         l = [points.centroid ; n];                      
%                         h2 = plot3(l(:,1), l(:,2), l(:,3), s.vis.centroidProperties{:});
%                     end
%                    h1 = fillPolygon3d(s.pts.bounds, [0.7 0.7 0.7]);                    
        
%                    s.myhandles = [h1];                    

                case 'pressurebar1'     
                    active = find(s.valRaw);
%                     if isempty(active) || sum(s.valRaw)/numel(active) <= s.vis.threshold
%                         return;
%                     end                    
                    val = s.valRaw / 255 * s.vis.height;
                    
                    h1 = fillPolygon3d(s.pts.bounds, [0.7 0.7 0.7]);  
                    % draw places
                    hplaces = plot3(points.p(:,1)', points.p(:,2)', points.p(:,3)', '*', 'MarkerSize', 2, 'Color', 'w' );
                    h1 = [h1 hplaces'];
                    
                    % draw points                    
                    if s.vis.bar
                        points.n = points.p + diag(val)*repmat(points.ndir, length(val), 1);
                        hpoints = plot3([points.p(:,1)'; points.n(:,1)'], [points.p(:,2)'; points.n(:,2)'], [points.p(:,3)'; points.n(:,3)'], ...
                                            s.vis.barProperties{:});
                    end
                    h1 = [h1 hpoints'];
                    h1 = [h1 drawPolygon3d(s.pts.bounds, 'LineStyle', '-', 'Color', 'k', 'LineWidth', 1)];
                    
                    % draw centroid
                    h2 = [];
                    if s.vis.centroid && ~isempty(active)
                        n = points.centroid + points.ndir*sum(val);
                        l = [points.centroid ; n]; 
                        h2 = arrow(l(1,:), l(2,:), 'BaseAngle', 60, 'Length', 3, 'LineWidth', 1);
                        %h2 = plot3(l(:,1), l(:,2), l(:,3), s.vis.centroidProperties{:});
                    end
        
                    s.myhandles = [h1 h2];
            end
        end
        
        function pnts = get.pts(s)
            xform = s.sensorTransform*s.placementTransform;
            pnts.p = MyMath.transform(s.model.p, xform);                                    
            pnts.ndir = MyMath.transform(s.model.ndir, r2t(t2r(xform)));
                        
            pnts.centroid =  pnts.p.*repmat(s.valRaw,1,3);
            pnts.centroid =  sum(pnts.centroid) ./ sum(s.valRaw);
%            pnts.centroid =  sum(pnts.p) ./ size(pnts.p,1);
            
            pnts.xform = xform;
            %pnts.xform(1:3,4) = pnts.centroid';
                        
            pnts.bounds = MyMath.transform(s.model.bounds, xform);
            %pnts.bounds = pnts.bounds + repmat(pnts.ndir*0.1, size(pnts.bounds,1), 1);
        end
        
        function set.raw(s, v)
            if size(v,1)*size(v,2) ~= length(s.valRaw)
                error('EFW:SensorPatch:badargs', 'update to sensor patch values should match number of sensels');
            end
            
            s.valRaw = reshape(v, length(s.valRaw), 1);                        
        end
        function v = get.raw(s)
            v = s.valRaw;
            
            %v = sum(s.valRaw) / length(s.valRaw);
        end
        
        function set.cal(s, v)
            if size(v,1)*size(v,2) ~= length(s.valCal)
                error('EFW:SensorPatch:badargs', 'update to sensor patch values should match number of sensels');
            end
            
            s.valCal = reshape(v, length(s.valCal), 1);
        end
        function v = get.cal(s)
            v = s.valCal;
        end
        
        function set.hLoc(s, v)
            s.myLoc = v;
            if v(1) > 5, return; end
            % construct KC
            %  get the DH parameters from link 1 to this id. We need [theta d a alpha sigma offset]
            %  use s.placementTransform as the tool
            %  construct a KC            
            finger = s.hand.Fingers(v(1));
            lid = s.hand.linkidx(v(1), v(2));
            links(lid) = Link;
            for i=1:lid
                li = finger.links(i);
                links(i) = Link([0 li.d li.a li.alpha 0 li.offset]);
            end
            s.myKC = SerialLink(links, 'name', mat2str(v), 'base', finger.base, 'tool', finger.links(lid).jointSystemXform * s.placementTransform);
            s.myKC.addprop('jointRange');
            s.myKC.jointRange = s.hand.fingerId2jointRange(v(1));
            s.myKC.jointRange = s.myKC.jointRange(1:lid);
            %s.myKC.plot(s.hand.Q(s.myKC.jointRange), 'nobase', 'noshadow', 'noname'); hold on;
        end
        function v = get.hLoc(s)
            v = s.myLoc;
        end
        
        function j = patchJacobian(s)
            j = s.myKC.jacobn(s.hand.Q(s.myKC.jointRange));
        end
    end
    
    methods (Access = private)
    end
    
    methods (Static)
        % A sensor patch is modeled in a standard RHS in the XY plane. The patch
        % is centered at the origin.
        % Sensels are assumed to be square.
        function model = patchModel(geom)
            senselSize = sqrt(geom.senselArea);
            b = span(geom.rowspc, senselSize, geom.nrows);
            l = span(geom.colspc, senselSize, geom.ncols);
            
            length = -b/2+senselSize/2:senselSize+geom.rowspc:b/2;
            breadth = -l/2+senselSize/2:senselSize+geom.colspc:l/2;
            [X, Y] = meshgrid(breadth, length);
            model = struct('p', zeros(size(length,2)*size(breadth, 2), 3), 'ndir', [], 'l', [], 'b', []);
            k = 0;
            for j=1:size(breadth, 2)
                for i=1:size(length, 2)
                    k = k+1;
                    model.p(k,:) = [X(i,j) Y(i,j) 0.2]; 
                end
            end
            model.ndir = [0 0 1];
            model.l = b;  % rows
            model.b = l;  % cols
            model.senselArea = geom.senselArea;
            model.bounds = [
                -l/2    -b/2    0.2
                -l/2    b/2     0.2
                l/2     b/2     0.2
                l/2     -b/2    0.2
            ];
            
            function l=span(spacing, dim, nsensels)
                l= (nsensels-1)*spacing + nsensels*dim;
            end            
        end
        
        function vis = getVisualization(type)
            vis = [];
            switch type
                case 'pressurebar'
                    vis.type = 'pressurebar';
                    vis.height = 5;
                    vis.threshold = 0;
                    vis.bar = 1;
                    vis.barProperties = {'LineStyle', '-', 'LineWidth', 1, 'Color', 'r'}; 
                    vis.centroid = 1;
                    vis.centroidProperties = {'LineStyle', '-', 'LineWidth', 2, 'Color', 'k'};
                    
                case 'importancebar'
                    vis.type = 'importancebar';
                    vis.threshold = 0;
                    vis.height = 0.6;
                    vis.barProperties = {'LineStyle', '-', 'LineWidth', 2.5};
                    
                case 'intensity'
                    vis.type = 'intensity';
                    vis.height = 0.2;
                    vis.threshold = 0;
                    vis.barProperties = {'linestyle', '-', 'edgecolor', 'r', 'linewidth', 5}; 
                    vis.placeProperties = {'linestyle', '-', 'color', 'w', 'linewidth', 5}; 
                    vis.centroid = 1;
                    vis.centroidProperties = {'linestyle', '-', 'color', 'k', 'linewidth', 5};                    
                    
                case 'pressurebar1'
                    vis.type = 'pressurebar1';
                    vis.height = 5;
                    vis.threshold = 0;
                    vis.bar = 1;
                    vis.barProperties = {'LineStyle', '-', 'LineWidth', 2, 'Color', 'r'}; 
                    vis.centroid = 1;
                    vis.centroidProperties = {'LineStyle', '-', 'LineWidth', 2, 'Color', 'k'};
                    
            end
        end       
        
        function r = avgTactileResponse(patch, importanceFactor)
            threshold = importanceFactor * max(max(patch));
            active = patch(patch > threshold);
            if isempty(active)
                r = 0; 
            else
                r = sum(active) /  length(active);
            end
        end        
        
        function a = activeArea(patch, senselArea, importanceFactor)
            threshold = importanceFactor * max(max(patch));
            active = patch(patch > threshold);
            a = length(active)*senselArea;
        end
    end
end