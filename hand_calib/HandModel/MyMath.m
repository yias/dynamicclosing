classdef MyMath < handle
    methods (Static)
        % pts specifies coordinates in rows to be transformed by homogeneous transform T
        function ptx= transform(pts, T)
            ptsh = [pts' ; ones(1, size(pts,1))];
            ptx = T*ptsh;
            ptx = ptx(1:3, :)';
        end
        
        % normalize a vector
        function nv = normalize(v, scale)
            l = sqrt(v*v');
            nv = v/l * scale;    
        end        
        
        function nm = normalizeM(m, scale)
            l = diag(sqrt(m*m'));
            l = diag(l)\eye(length(l));
            s = diag(scale);
            nm = s*l*m;
        end
    end
end