function [kdata, klen] = toKinematicDataFiles(m, calibration_file, length_file)

    fid1 = fopen(calibration_file,'w+');
    fid2 = fopen(length_file,'w+');

    filename1 = calibration_file;
    filename2 = length_file;    

    pts = [m(:,:,1)' m(:,:,2)' m(:,:,3)' m(:,:,4)' m(:,:,5)' m(:,:,6)' m(:,:,7)' m(:,:,8)' m(:,:,9)'];
%    pts(abs(pts) < 0.001) = 0;
    pts = pts ./ 100;    
    dlmwrite(filename1,size(pts,1),'newline', 'pc');
    dlmwrite(filename1,pts, '-append', 'newline', 'pc','delimiter','\t');

    waist = mean(m(:,:,1), 2);
    chest = mean(m(:,:,2), 2);
    neck = mean(m(:,:,3), 2);    
    rsho = mean(m(:,:,5), 2);
    elbow = m(:,1,6);
    hand1 = m(:,1,7);
    hand2 = m(:,1,8);
    hand3 = m(:,1,9);        
    len = [norm(chest-waist) norm(neck-chest) norm(rsho-neck) norm(elbow-rsho) norm(hand1-elbow) norm(hand2-hand1) norm(hand3-hand2)];
%    len(len<0.001)=0;
    len = len ./ 100;    
    dlmwrite(filename2,len,'newline', 'pc','delimiter','\t');
    
    fclose(fid1);
    fclose(fid2);
    
    kdata = pts;
    klen = len;
end