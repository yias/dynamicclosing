classdef HandGeom < handle
    properties 
        step
        name
    end
    
    properties (Dependent)
        lPalm
        lMid
        lWidth
        lThumb
    end

    properties (Access = private)
        palm
        mid
        width
        thumb
    end
    
    methods
        function h= HandGeom(name, palm, mid, width, thumb)
            h.name = name;
            
            h.palm = palm;
            h.mid = mid;
            h.width = width;
            h.thumb = thumb;
            
            h.step = struct('palm', [], 'mid', [], 'width', [], 'thumb', []);
        end
        
        function v = get.lPalm(h)
            v = HandGeom.getVal(h.palm, h.step.palm);
        end
        
        function v = get.lMid(h)
            v = HandGeom.getVal(h.mid, h.step.mid);
        end
        
        function v = get.lWidth(h)
            v = HandGeom.getVal(h.width, h.step.width);
        end
        
        function v = get.lThumb(h)
            v = HandGeom.getVal(h.thumb, h.step.thumb);
        end        
    end    
    
    methods (Static)
        function v = getVal(comp, steps)
            if ~isempty(steps)
                v = stepIntoRange([comp.default comp.default] + comp.range);
                return;
            end
            
            v = comp.val;            
            if v == -1
                v = comp.default;
            end
            
            function v = stepIntoRange(range)
                curstep = steps(1);
                if steps(2) == 1, curstep = 2; end
                nsteps = max(steps(2), 3);
                
                interval = (range(2)-range(1)) / (nsteps-1);
                v = range(1) + (curstep-1)*interval;
            end
        end            
    end
end