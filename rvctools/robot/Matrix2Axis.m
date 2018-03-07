function [q axis angle]= Matrix2Axis(rotMatrix)

axis  = [rotMatrix(3, 2) - rotMatrix(2, 3) 
         rotMatrix(1, 3) - rotMatrix(3, 1) 
         rotMatrix(2, 1) - rotMatrix(1, 2)];

if norm(axis)>0.0001
    axis  = axis ./ norm(axis);
else
    axis = axis*0;
    if trace(rotMatrix) == -1
        for i=1:3
            if rotMatrix(i,i)==1
                axis(i) = 1;
            end
        end
    end
end

angle = acos((trace(rotMatrix) - 1) / 2);
q = axis * angle;
%q = [cos(angle/2); sin(angle/2)*axis];

