classdef LLink < Link
    properties
        linkTransform  % Places the DH system frame in the world.
        jointSystemXform  % Places the link in the DH system frame of the joint
        geometry % link structure        
        sensors
        vis
    end
    
    properties (Access = private)
        myhandles
    end
    
    methods 
        function l = LLink(jointXform, dim, sensors, varargin)
            l = l@Link(varargin{:});
            l.jointSystemXform = jointXform;
            l.geometry = LLink.linkStructure(dim);
            l.vis.background = 0;
            l.myhandles = [];
            makeSensors();            
            
            function makeSensors()
                l.sensors = struct('front', [], 'left', [], 'right', []);
                
                if isempty(sensors)
                    return;
                end
                
                for i=1:length(sensors)
                    switch sensors(i).pos
                        case 'front'
                            sensors(i).geom.placement = l.geometry.frontSurfaceTransform*sensors(i).geom.placement;                           
                            l.sensors.front = SensorPatch(sensors(i).geom);
                        case 'left'
                            sensors(i).geom.placement = l.geometry.leftSurfaceTransform*sensors(i).geom.placement;                                                       
                            l.sensors.left = SensorPatch(sensors(i).geom);
                        case 'right'
                            sensors(i).geom.placement = l.geometry.rightSurfaceTransform*sensors(i).geom.placement;                                                       
                            l.sensors.right = SensorPatch(sensors(i).geom);
                    end
                end                               
            end            
        end
        
        function update(l, baseTransform, q, varargin)
            l.linkTransform = baseTransform*l.A(q)*l.jointSystemXform;            
            l.runSensors(@setSensorTransform);
            function setSensorTransform(s)
                s.sensorTransform = l.linkTransform;
                if numel(varargin) > 0 && varargin{1} 
                    plotAxes(l.linkTransform, 2, 2);
                    pts = s.pts;
                    plotAxes(pts.xform, 1, 3);
                end                
            end
        end
        
        function visualize(l) 
            try 
                if ~isempty(l.myhandles)
                    delete(l.myhandles)
                end            
            catch exception
                l.myhandles = [];
            end
            l.myhandles = l.drawLink();
            l.runSensors(@visualizeSensor);
            function visualizeSensor(s)
                s.visualize();
            end
        end
        
        function yn = intersect(l, pt, vec, d)
            yn = 0;
            vertices = l.geometry.vertices;
            if sum(vertices(:,3)) == 0  
               return; 
            end
            vertices = MyMath.transform(vertices, l.linkTransform);
            inter = intersectRayPolyhedron([pt' vec'], vertices, l.geometry.faces);
            if ~isnan(sum(sum(inter))) && size(inter,1) > 1                
                dinter = repmat(pt, 1, size(inter,1)) - inter';
                dinter = sqrt(diag(dinter'*dinter));
                if min(dinter) < d
                    yn = 1;
                end
            end
            
%             hnd = [];
%             cdata = l.geometry.facevertexcdatahighlight;
%             alpha = l.geometry.facevertexalphadata;            
%             hnd = [hnd patch('Vertices', vertices, 'Faces', l.geometry.faces, ...
%                   'FaceVertexCData', cdata, 'FaceVertexAlphaData', alpha, ...
%                   'FaceColor', 'flat', 'EdgeColor', 'none', 'FaceAlpha', 'flat', 'AlphaDataMapping', 'none' ...
%                   )];            
%             if yn, clr = 'r'; else clr = 'g'; end
%             st = pt; ed = pt+vec*d;
%             l = [st'; ed'];
%             hnd = [hnd plot3(l(:,1), l(:,2), l(:,3), clr, 'LineStyle', '-', 'LineWidth', 2)];
%             if yn
%                 pause;
%             end
%             pause;
%             delete(hnd);
        end
    end
    
    methods (Access= private)   
        function h= drawLink(l)
            h = [];
            vertices = l.geometry.vertices;
            if sum(vertices(:,3)) == 0
                return;
            end
            vertices = MyMath.transform(vertices, l.linkTransform);
            cdata = l.geometry.facevertexcdata;
            alpha = l.geometry.facevertexalphadata;
            if l.vis.background
                cdata = l.geometry.facevertexcdatabackground;
                alpha = l.geometry.facevertexalphadatabackground;
            end
            h = patch('Vertices', vertices, 'Faces', l.geometry.faces, ...
                  'FaceVertexCData', cdata, 'FaceVertexAlphaData', alpha, ...
                  'FaceColor', 'flat', 'EdgeColor', 'none', 'FaceAlpha', 'flat', 'AlphaDataMapping', 'none' ...
                  );
        end
        
        function runSensors(l, f)
            if ~isempty(l.sensors.front)
                f(l.sensors.front);
            end
            if ~isempty(l.sensors.left)
                f(l.sensors.left);
            end
            if ~isempty(l.sensors.right)
                f(l.sensors.right);
            end
        end
    end
    
    methods (Static)
        % dim = [thicknessStart, thicknessEnd, widthStart, widthEnd, height]
        function geometry= linkStructure(dim)
            geometry.dim = dim;
            ts = dim(1); te = dim(2); ws = dim(3); we = dim(4); h = dim(5);
            geometry.vertices = [
               -ws/2 -ts    0
               ws/2  -ts    0
               ws/2  0     0
               -ws/2 0     0
               -we/2 -te    h
               we/2  -te    h
               we/2  0     h
               -we/2 0     h               
            ];
            geometry.faces = [
                4 3 7 8  % front
                3 2 6 7  % right
                4 1 5 8  % left
                1 5 6 2  % rear
                1 4 3 2  % bottom                
                5 8 7 6  % top
            ];            
            geometry.facevertexcdata = [
                65  32  251
%                0   0   0
                237 163 80
                240 216 77
                255 216 176
                255 216 176
                255 216 176
            ];
        
%             geometry.facevertexcdata = [
% %                65  32  251
%                 237 163 80
%                 255 216 176
%                 255 216 176
%                 255 216 176
%                 255 216 176
%                 255 216 176
%             ];
        
            geometry.facevertexcdata = geometry.facevertexcdata/255;
            geometry.facevertexalphadata = [
                0.5
                0.5
                0.5
                0.3
                0.3
                0.3
            ];
            geometry.facevertexcdatahighlight = [
                1 0 0 
                1 0 0
                1 0 0
                1 0 0
                1 0 0
                1 0 0
            ];
        
%             geometry.facevertexcdatabackground = [
%                 0.851   0.851   0.851
%                 0.851   0.851   0.851
%                 0.851   0.851   0.851
%                 0.851   0.851   0.851
%                 0.851   0.851   0.851
%                 0.851   0.851   0.851
%             ];        
            geometry.facevertexcdatabackground = geometry.facevertexcdata;
            geometry.facevertexalphadatabackground = [
                0.1
                0.1
                0.1
                0.1
                0.1
                0.1
            ];
        
            geometry.frontSurfaceTransform = transl(0, 0, h/2)*trotx(-pi/2);
            geometry.leftSurfaceTransform = transl(-ws/2, -ts/2, h/2)*trotz(-pi/2)*trotx(pi/2);
            geometry.rightSurfaceTransform = transl(ws/2, -ts/2, h/2)*trotz(pi/2)*trotx(pi/2);
        end        
    end
end