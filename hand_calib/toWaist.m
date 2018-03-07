% function m = toWaist(o)
%    
%     for i=1:size(o,2)
%         neck = o(:,i,3);
%         waist = o(:,i,1);
%         lsho = o(:,i,4);
%     %    rsho = mean(o(:,:,5), 2);
%         nw = waist-neck; nnw = nw/norm(nw); nls = lsho-neck; nnls = nls/norm(nls);
%         alpha = acos(dot(nnls, nnw));
%         ax = cross(nnls, nnw);
%         T = angvec2tr(2*alpha, ax);
%         nnrs = hrem(T*hset(nnls));
%         rsho = neck + nnrs*norm(nls); 
%         o(:,i,5) = rsho;
%     end
%     
%     neck = mean(o(:,:,3), 2);
%     waist = mean(o(:,:,1), 2);
%     lsho = mean(o(:,:,4), 2);
%     rsho = mean(o(:,:,5), 2);
%     
% %     figure; hold on;
% %     ln = [neck'; lsho'];
% %     plot3(ln(:,1), ln(:,2), ln(:,3), 'LineStyle', '-', 'Color', 'b');
% %     ln = [neck'; waist'];
% %     plot3(ln(:,1), ln(:,2), ln(:,3), 'LineStyle', '-', 'Color', 'r');
% %     ln = [neck'; neck' + ax'*10];
% %     plot3(ln(:,1), ln(:,2), ln(:,3), 'LineStyle', '-', 'Color', 'k');
% %     ln = [neck'; rsho'];
% %     plot3(ln(:,1), ln(:,2), ln(:,3), 'LineStyle', '-', 'Color', 'g');
%     
%     z = (neck - waist) ./ norm(neck - waist);
%     y = (lsho - rsho) ./ norm(lsho - rsho);
%     x = cross(y,z);
%     x = x./norm(x);
%     y = cross(z,x);
%  
%     swplane = [y z];  
%     neck0 = neck-lsho;
%     neck1 = swplane*(pinv(swplane)*neck0);
%     correction1 = neck1 - neck0;
% 
%     neck0 = neck + correction1;
%     neck1 = (lsho + rsho) ./ 2;
%     correction2 = neck1 - neck0;
%     
%     correction = correction1 + correction2;
%     Hcorrection = [ eye(3) correction; zeros(1,3) 1 ];
%     
%     waist = waist + correction;
%     H = [x y z waist; 0 0 0 1];
%     H = Hinv(H);
%     
%     m = zeros(size(o));
%     for i=1:size(o,3)
%         if i <= 3
%             m(:,:,i) = hrem(H*Hcorrection*hset(o(:,:,i)));
%         else
%             m(:,:,i) = hrem(H*hset(o(:,:,i)));
%         end
%     end
% end

function m = toWaist(o)
   
    neck = mean(o(:,:,3), 2);
    waist = mean(o(:,:,1), 2);
    lsho = mean(o(:,:,4), 2);
    rsho = mean(o(:,:,5), 2);
    z = (neck - waist) ./ norm(neck - waist);
    y = (lsho - rsho) ./ norm(lsho - rsho);
    x = cross(y,z);
    x = x./norm(x);
    y = cross(z,x);
    
    swplane = [y z];  
    neck0 = neck-lsho;
    neck1 = swplane*(pinv(swplane)*neck0);
    correction1 = neck1 - neck0;

    neck0 = neck + correction1;
    neck1 = (lsho + rsho) ./ 2;
    correction2 = neck1 - neck0;
    
    correction = correction1 + correction2;
    Hcorrection = [ eye(3) correction; zeros(1,3) 1 ];
    
    waist = waist + correction;
    H = [x y z waist; 0 0 0 1];
    H = Hinv(H);
    
    m = zeros(size(o));
    for i=1:size(o,3)
        if i <= 3
            m(:,:,i) = hrem(H*Hcorrection*hset(o(:,:,i)));
        else
            m(:,:,i) = hrem(H*hset(o(:,:,i)));
        end
    end
end