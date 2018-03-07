function Q = getCalibratedHandAngles(g, calibFile, minFile, maxFile)
    persistent min_glove max_glove start_hand_poses end_hand_poses;
    %persistent gprmcjf gprmcja gprpijf gprpijr gprdijf;
    persistent tc qlim
    
    if isempty(calibFile)
        useCal = 0;
    else
        useCal = 1;
    end
    
    if isempty(min_glove) || isempty(max_glove)
        load(minFile); min_glove = min_glove_values;
        load(maxFile); max_glove = max_glove_values;
        poses = [
          %start     end  
            10       -100
            20      -45            
            0       -80
            0       -70
            20      -80

            3       -8
            0      -90
            0       -100
            0       -50

            -5      5
            0      -90
            0       -100
            0       -65

            -5      10
            0       -90
            0       -100
            0       -65

            0       25
            0      -90
            0       -100
            0       -65
        ];
        start_hand_poses = deg2rad(poses(:,1));
        end_hand_poses = deg2rad(poses(:,2));  
        
        if useCal
            load(calibFile);
            if ~exist('nGMRcomp', 'var')
                nGMRcomp = 15;
            end
            tc =  ThumbCalibrationGMR(regressionData, nGMRcomp);
        end
        qlim = deg2rad([
            20       -100
            20      -47            
            10       -80
            0       -80
            25      -90]);
    end

  
    q = zeros(21,1);
    
    poses = g;
    for i=1:size(g,2)
         if poses(i) > max_glove(i) 
             poses(i) = max_glove(i);
         end
         if poses(i) < min_glove(i)
             poses(i) = min_glove(i);
         end
         poses(i) = (poses(i)-min_glove(i))/(max_glove(i)-min_glove(i));
    end        
        
    q(1)  = poses(1); %poses(1); % feval(fitobject1,[poses(1) poses(4)]);
    q(2)  = poses(4); % feval(fitobject2,[poses(1) poses(4)]);
    q(3)  = 0; % feval(fitobject3,[poses(1) poses(4)]);
    q(4) = poses(2);
    q(5) = poses(3);
    q(6) = poses(12);
    q(7:9) = poses(5:7);
    q(10) = poses(12);
    q(11:13)  = poses(9:11);
    q(14) = poses(16);
    q(15:17) = poses(13:15);
    q(18) = poses(20);
    q(19:21) = poses(17:19);
    

    qold = q(1)';
    range = end_hand_poses - start_hand_poses;
    q  = start_hand_poses + q.*(end_hand_poses - start_hand_poses);
    %[qold; rad2deg(start_hand_poses(1))'; rad2deg(range(1))'; rad2deg(q(1))']
    if useCal
        y = tc.GMR_query(g([1 4 2 3]));
%         y = max(y, qlim(:,2)');
%         y = min(y, qlim(:,1)');
    end
    
    Q = zeros(1,23);
    Q(1) = 0; %(pi/3) -  poses(22)*abs(pi/3-(-pi/3));     % wrist flexion
    Q(2) = 0; %(pi/9) -  poses(23)*abs(pi/9-(-pi/9));     % wrist abduction    
    if useCal
        Q(3:7) = y;
    else
        Q(3) = q(1); %deg2rad(gprmcjf.f(g(1))); % thumb flexion
        Q(4) = q(2); %deg2rad(gprmcja.f([g(1) g(4) g(2) g(3)])); % thumb abduct
        Q(5) = q(4); %deg2rad(gprpijf.f([g(1) g(4) g(2) g(3)]));
        Q(6) = 0; %deg2rad(gprpijr.f([g(1) g(4) g(2) g(3)])); % thumb pij roll
        Q(7) = q(5); %deg2rad(gprdijf.f([g(1) g(4) g(2) g(3)]));        
    end
    Q(8) = q(7); % index mcj flexion
    Q(9) = q(6); % index mcj abduct
    Q(10) = q(8); % index pij
    Q(11) = q(9); % index dij
    Q(12) = q(11); % middle mcj flexion
    Q(13) = q(10); % middle mcj abduct 
    Q(14) = q(12); % middle pij
    Q(15) = q(13); % middle dij
    Q(16) = q(15); % ring mcj flexion
    Q(17) = q(14); % ring mcj abduct
    Q(18) = q(16);
    Q(19) = q(17);
    Q(20) = q(19); % pinky mcj flexion
    Q(21) = q(18); % pinky mcj abduct
    Q(22) = q(20);
    Q(23) = q(21);        
end