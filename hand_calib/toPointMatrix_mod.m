function [m, valid] = toPointMatrix(r)  
    n = numel(r);
    m = zeros(3,n,9);
    valid = false(1,n);
    for i=1:n
%         if i==558
%         i
%         end
        valid(i) = validMarkerSet(r{i});
        m(:,i,1) = r{i}.waist(1:3,4);
        m(:,i,2) = r{i}.chest(1:3,4);
        m(:,i,3) = r{i}.neck(1:3,4);
        m(:,i,4) = r{i}.leftShoulder(1:3,4);
        m(:,i,5) = r{i}.rightShoulder(1:3,4);
        m(:,i,6) = r{i}.elbow(1:3,4);
        x = r{i}.hand2' - r{i}.hand3'; x = x ./ norm(x);
        y = r{i}.hand1' - r{i}.hand3'; y = y ./ norm(y);
        z = cross(x,y); z = z ./ norm(z);
        y = cross(z,x); y = y ./ norm(y);
        m(:,i,7) = r{i}.hand3' + x .* 6 + y .* 8;
        m(:,i,8) = r{i}.hand1';        
        m(:,i,9) = r{i}.hand2';        
    end
    
    m = m(:,valid,:);
end

function m = toPointMatrix1(r)
    n = numRecords(r);
    
    m = zeros(3,n,9);
    valid = false(1,n);
    for i=1:n
        valid(i) = validMarkerSet(r{i});
        m(:,i,1) = r{i}.waist(1:3,4);
        m(:,i,2) = r{i}.chest(1:3,4);
        m(:,i,3) = r{i}.neck(1:3,4);
        m(:,i,4) = r{i}.leftShoulder(1:3,4);
        m(:,i,5) = r{i}.rightShoulder(1:3,4);
        m(:,i,6) = r{i}.elbow(1:3,4);
        m(:,i,7) = ((r{i}.hand1 + r{i}.hand2) ./ 2)';
%         m(:,i,8) = r{i}.hand3';
%         m(:,i,9) = r{i}.hand4';
        m(:,i,8) = r{i}.hand4';
        m(:,i,9) = r{i}.hand3';        
    end
    
    m = m(:,valid,:);
end
