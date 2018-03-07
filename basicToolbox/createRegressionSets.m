


function [testingSet,crossvalidationFolders]=createRegressionSets(trials,varargin)


testingSet=struct([]);


crossvalidationFolders=struct([]);


% number of crossvalidation folders
nb_cvf=3;

% the percentage of the data to keep for the cross-validation folders
trainingPercentage=0.7;

% the options for which data set to use
% 1: only data from the elbow extension
% 2: only data from the elbow flexion
% 3: all the data(from both elbow extension and flexion)
Set_Option=3;

% length of the time window in seconds
tw_length=0.15;

% overlap between the time windows
tw_overlap=0.1;

% sampling rate of the mocap system
SR_mocap=250;

% sampling rate of the emg system
SR_emg=1500;

% ids of the features to be extracted
% 1: rms
% 2: average
% 3: std
% 4: waveform length
% 5: zero crossings
% 6: slopechanges
featuresIDs=[2,4,6];

% ids of the muscles to keep
mIDs=1:16;

if ~isempty(varargin)
    for kk=1:2:length(varargin)
        
        if strcmp(varargin{kk},'NuberOfCrossValidationFolders')
            nb_cvf=varargin{kk+1};
        end
        if strcmp(varargin{kk},'TraingPercentage')
            trainingPercentage=varargin{kk+1};
        end    
        if strcmp(varargin{kk},'DatasetOption')
            Set_Option=varargin{kk+1};
        end 
        if strcmp(varargin{kk},'TwLength')
            tw_length=varargin{kk+1};
        end
        if strcmp(varargin{kk},'OverLap')
            tw_overlap=varargin{kk+1};
        end
        if strcmp(varargin{kk},'MoCapSR')
            SR_mocap=varargin{kk+1};
        end 
        if strcmp(varargin{kk},'emgSR')
            SR_emg=varargin{kk+1};
        end
        if strcmp(varargin{kk},'MusclesIDs')
            mIDs=varargin{kk+1};
        end
        if strcmp(varargin{kk},'Features')
            featuresIDs=[];
            nbFeatures=length(varargin{kk+1});
            for i=1:nbFeatures
                if strcmp(varargin{kk+1}{i},'RMS')
                    featuresIDs=[featuresIDs;1];
                end
                if strcmp(varargin{kk+1}{i},'Average')
                    featuresIDs=[featuresIDs;2];
                end
                if strcmp(varargin{kk+1}{i},'STD')
                    featuresIDs=[featuresIDs;3];
                end
                if strcmp(varargin{kk+1}{i},'WaveFormLength')
                    featuresIDs=[featuresIDs;4];
                end
                if strcmp(varargin{kk+1}{i},'ZeroCrossings')
                    featuresIDs=[featuresIDs;5];
                end
                if strcmp(varargin{kk+1}{i},'SlopeChanges')
                    featuresIDs=[featuresIDs;6];
                end
            end
         end

    end
end


nb_testingTrials=round(length(trials)*(1-trainingPercentage));

tmp_rn=random_numbers(length(trials),nb_testingTrials,1);

testingTrials=trials(tmp_rn);

trials(tmp_rn)=[];

nb_of_trials_perFolder=floor(length(trials)/nb_cvf);


for i=1:nb_cvf
    
    tmp_rn=random_numbers(length(trials),nb_of_trials_perFolder,1);
    
    tmpFolder=trials(tmp_rn);
    
    
    for j=1:nb_of_trials_perFolder
        
        switch Set_Option
            case 1    
                crossvalidationFolders{i}{j}.emg=createTW(floor((tmpFolder{j}.elbow_extension_onset/SR_mocap)*SR_emg),floor((tmpFolder{j}.elbow_extension_end/SR_mocap)*SR_emg),tmpFolder{j}.emg,tw_length,SR_emg,mIDs,tw_overlap,featuresIDs);
                
                crossvalidationFolders{i}{j}.elbow_angle=createTW(tmpFolder{j}.elbow_extension_onset,tmpFolder{j}.elbow_extension_end,tmpFolder{j}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
                crossvalidationFolders{i}{j}.elbow_angular_velocity=createTW(tmpFolder{j}.elbow_extension_onset,tmpFolder{j}.elbow_extension_end,tmpFolder{j}.elbow_angular_velocity,tw_length,SR_mocap,1,tw_overlap,2);
        
                crossvalidationFolders{i}{j}.emg=crossvalidationFolders{i}{j}.emg(1:min([size(crossvalidationFolders{i}{j}.emg,1),length(crossvalidationFolders{i}{j}.elbow_angle)]),:);
                crossvalidationFolders{i}{j}.elbow_angle=crossvalidationFolders{i}{j}.elbow_angle(1:min([size(crossvalidationFolders{i}{j}.emg,1),length(crossvalidationFolders{i}{j}.elbow_angle)]));
                crossvalidationFolders{i}{j}.elbow_angular_velocity=crossvalidationFolders{i}{j}.elbow_angular_velocity(1:min([size(crossvalidationFolders{i}{j}.emg,1),length(crossvalidationFolders{i}{j}.elbow_angle)]));
                
                crossvalidationFolders{i}{j}.Aperture=createTW(tmpFolder{j}.fingers_motion_onset,tmpFolder{j}.fingers_motion_end+20,tmpFolder{j}.Aperture,tw_length/3,SR_mocap,1,tw_overlap/4,2);
                crossvalidationFolders{i}{j}.velocity_Aperture=createTW(tmpFolder{j}.fingers_motion_onset,tmpFolder{j}.fingers_motion_end+20,tmpFolder{j}.velocity_Aperture,tw_length/3,SR_mocap,1,tw_overlap/4,2);
        
                crossvalidationFolders{i}{j}.FTipsArea=createTW(tmpFolder{j}.fingers_motion_onset,tmpFolder{j}.fingers_motion_end+20,tmpFolder{j}.FTipsArea,tw_length/3,SR_mocap,1,tw_overlap/4,2);
                crossvalidationFolders{i}{j}.velocity_Area=createTW(tmpFolder{j}.fingers_motion_onset,tmpFolder{j}.fingers_motion_end+20,tmpFolder{j}.velocity_Area,tw_length/3,SR_mocap,1,tw_overlap/4,2);
                
                crossvalidationFolders{i}{j}.elbow_a=createTW(tmpFolder{j}.elbow_motion_onset,tmpFolder{j}.elbow_motion_end+20,tmpFolder{j}.elbow_angle,tw_length/3,SR_mocap,1,tw_overlap/4,2);
                crossvalidationFolders{i}{j}.elbow_v=createTW(tmpFolder{j}.elbow_motion_onset,tmpFolder{j}.elbow_motion_end+20,tmpFolder{j}.elbow_angular_velocity,tw_length/3,SR_mocap,1,tw_overlap/4,2);
                
                crossvalidationFolders{i}{j}.grasp=tmpFolder{j}.grasp;
                
            case 2
                
                crossvalidationFolders{i}{j}.emg=createTW(floor((tmpFolder{j}.elbow_flexion_onset/SR_mocap)*SR_emg),floor((tmpFolder{j}.elbow_flexion_end/SR_mocap)*SR_emg),tmpFolder{j}.emg,tw_length,SR_emg,mIDs,tw_overlap,featuresIDs);
                
                crossvalidationFolders{i}{j}.elbow_angle=createTW(tmpFolder{j}.elbow_flexion_onset,tmpFolder{j}.elbow_flexion_end,tmpFolder{j}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
                crossvalidationFolders{i}{j}.elbow_angular_velocity=createTW(tmpFolder{j}.elbow_flexion_onset,tmpFolder{j}.elbow_flexion_end,tmpFolder{j}.elbow_angular_velocity,tw_length,SR_mocap,1,tw_overlap,2);
        
                crossvalidationFolders{i}{j}.emg=crossvalidationFolders{i}{j}.emg(1:min([size(crossvalidationFolders{i}{j}.emg,1),length(crossvalidationFolders{i}{j}.elbow_angle)]),:);
                crossvalidationFolders{i}{j}.elbow_angle=crossvalidationFolders{i}{j}.elbow_angle(1:min([size(crossvalidationFolders{i}{j}.emg,1),length(crossvalidationFolders{i}{j}.elbow_angle)]));
                crossvalidationFolders{i}{j}.elbow_angular_velocity=crossvalidationFolders{i}{j}.elbow_angular_velocity(1:min([size(crossvalidationFolders{i}{j}.emg,1),length(crossvalidationFolders{i}{j}.elbow_angle)]));
                
        
                crossvalidationFolders{i}{j}.Aperture=createTW(tmpFolder{j}.fingers_motion_onset,tmpFolder{j}.fingers_motion_end+20,tmpFolder{j}.Aperture,tw_length/3,SR_mocap,1,tw_overlap/4,2);
                crossvalidationFolders{i}{j}.velocity_Aperture=createTW(tmpFolder{j}.fingers_motion_onset,tmpFolder{j}.fingers_motion_end+20,tmpFolder{j}.velocity_Aperture,tw_length/3,SR_mocap,1,tw_overlap/4,2);
        
                crossvalidationFolders{i}{j}.FTipsArea=createTW(tmpFolder{j}.fingers_motion_onset,tmpFolder{j}.fingers_motion_end+20,tmpFolder{j}.FTipsArea,tw_length/3,SR_mocap,1,tw_overlap/4,2);
                crossvalidationFolders{i}{j}.velocity_Area=createTW(tmpFolder{j}.fingers_motion_onset,tmpFolder{j}.fingers_motion_end+20,tmpFolder{j}.velocity_Area,tw_length/3,SR_mocap,1,tw_overlap/4,2);
                
                crossvalidationFolders{i}{j}.elbow_a=createTW(tmpFolder{j}.elbow_motion_onset,tmpFolder{j}.elbow_motion_end+20,tmpFolder{j}.elbow_angle,tw_length/3,SR_mocap,1,tw_overlap/4,2);
                crossvalidationFolders{i}{j}.elbow_v=createTW(tmpFolder{j}.elbow_motion_onset,tmpFolder{j}.elbow_motion_end+20,tmpFolder{j}.elbow_angular_velocity,tw_length/3,SR_mocap,1,tw_overlap/4,2);
                
                crossvalidationFolders{i}{j}.grasp=tmpFolder{j}.grasp;
                
            case 3
                
                
                tmpEMG1=createTW(floor((tmpFolder{j}.elbow_extension_onset/SR_mocap)*SR_emg),floor((tmpFolder{j}.elbow_extension_end/SR_mocap)*SR_emg),tmpFolder{j}.emg,tw_length,SR_emg,mIDs,tw_overlap,featuresIDs);
                
                tmp_elbow_angle1=createTW(tmpFolder{j}.elbow_extension_onset,tmpFolder{j}.elbow_extension_end,tmpFolder{j}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
                tmp_elbow_angular_velocity1=createTW(tmpFolder{j}.elbow_extension_onset,tmpFolder{j}.elbow_extension_end,tmpFolder{j}.elbow_angular_velocity,tw_length,SR_mocap,1,tw_overlap,2);
        
                tmpEMG2=createTW(floor((tmpFolder{j}.elbow_flexion_onset/SR_mocap)*SR_emg),floor((tmpFolder{j}.elbow_flexion_end/SR_mocap)*SR_emg),tmpFolder{j}.emg,tw_length,SR_emg,mIDs,tw_overlap,featuresIDs);
                
                tmp_elbow_angle2=createTW(tmpFolder{j}.elbow_flexion_onset,tmpFolder{j}.elbow_flexion_end,tmpFolder{j}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
                tmp_elbow_angular_velocity2=createTW(tmpFolder{j}.elbow_flexion_onset,tmpFolder{j}.elbow_flexion_end,tmpFolder{j}.elbow_angular_velocity,tw_length,SR_mocap,1,tw_overlap,2);
                
        
                
                
                crossvalidationFolders{i}{j}.emg=[tmpEMG1(1:min([size(tmpEMG1,1),length(tmp_elbow_angle1)]),:);tmpEMG2(1:min([size(tmpEMG2,1),length(tmp_elbow_angle2)]),:)];
                crossvalidationFolders{i}{j}.elbow_angle=[tmp_elbow_angle1(1:min([size(tmpEMG1,1),length(tmp_elbow_angle1)]));tmp_elbow_angle2(1:min([size(tmpEMG2,1),length(tmp_elbow_angle2)]))];
                crossvalidationFolders{i}{j}.elbow_angular_velocity=[tmp_elbow_angular_velocity1(1:min([size(tmpEMG1,1),length(tmp_elbow_angle1)]));tmp_elbow_angular_velocity2(1:min([size(tmpEMG2,1),length(tmp_elbow_angle2)]))];
                
                crossvalidationFolders{i}{j}.Aperture=createTW(tmpFolder{j}.fingers_motion_onset,tmpFolder{j}.fingers_motion_end+20,tmpFolder{j}.Aperture,tw_length/3,SR_mocap,1,tw_overlap/4,2);
                crossvalidationFolders{i}{j}.velocity_Aperture=createTW(tmpFolder{j}.fingers_motion_onset,tmpFolder{j}.fingers_motion_end+20,tmpFolder{j}.velocity_Aperture,tw_length/3,SR_mocap,1,tw_overlap/4,2);
        
                crossvalidationFolders{i}{j}.FTipsArea=createTW(tmpFolder{j}.fingers_motion_onset,tmpFolder{j}.fingers_motion_end+20,tmpFolder{j}.FTipsArea,tw_length/3,SR_mocap,1,tw_overlap/4,2);
                crossvalidationFolders{i}{j}.velocity_Area=createTW(tmpFolder{j}.fingers_motion_onset,tmpFolder{j}.fingers_motion_end+20,tmpFolder{j}.velocity_Area,tw_length/3,SR_mocap,1,tw_overlap/4,2);
                
                crossvalidationFolders{i}{j}.elbow_a=createTW(tmpFolder{j}.elbow_motion_onset,tmpFolder{j}.elbow_motion_end+20,tmpFolder{j}.elbow_angle,tw_length/3,SR_mocap,1,tw_overlap/4,2);
                crossvalidationFolders{i}{j}.elbow_v=createTW(tmpFolder{j}.elbow_motion_onset,tmpFolder{j}.elbow_motion_end+20,tmpFolder{j}.elbow_angular_velocity,tw_length/3,SR_mocap,1,tw_overlap/4,2);
                
                crossvalidationFolders{i}{j}.grasp=tmpFolder{j}.grasp;
                
            otherwise
                disp('set options not properly defined');
                return;
        end
        
    end
    
    trials(tmp_rn)=[];
    
    
end


for i=1:length(testingTrials)
    
    switch Set_Option
        case 1    
            testingSet{i}.emg=createTW(floor((testingTrials{i}.elbow_extension_onset/SR_mocap)*SR_emg),floor((testingTrials{i}.elbow_extension_end/SR_mocap)*SR_emg),testingTrials{i}.emg,tw_length,SR_emg,mIDs,tw_overlap,featuresIDs);
            
            testingSet{i}.elbow_angle=createTW(testingTrials{i}.elbow_extension_onset,testingTrials{i}.elbow_extension_end,testingTrials{i}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
            testingSet{i}.elbow_angular_velocity=createTW(testingTrials{i}.elbow_extension_onset,testingTrials{i}.elbow_extension_end,testingTrials{i}.elbow_angular_velocity,tw_length,SR_mocap,1,tw_overlap,2);
        
            testingSet{i}.emg=testingSet{i}.emg(1:min([size(testingSet{i}.emg,1),length(testingSet{i}.elbow_angle)]),:);
            testingSet{i}.elbow_angle=testingSet{i}.elbow_angle(1:min([size(testingSet{i}.emg,1),length(testingSet{i}.elbow_angle)]));
            testingSet{i}.elbow_angular_velocity=testingSet{i}.elbow_angular_velocity(1:min([size(testingSet{i}.emg,1),length(testingSet{i}.elbow_angle)]));
            
            
            testingSet{i}.Aperture=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.Aperture,tw_length/2,SR_mocap,1,tw_overlap/4,2);
            testingSet{i}.velocity_Aperture=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.velocity_Aperture,tw_length/2,SR_mocap,1,tw_overlap/4,2);
        
            testingSet{i}.FTipsArea=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.FTipsArea,tw_length/2,SR_mocap,1,tw_overlap/4,2);
            testingSet{i}.velocity_Area=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.velocity_Area,tw_length/2,SR_mocap,1,tw_overlap/4,2);
            
            testingSet{i}.elbow_a=createTW(testingTrials{i}.elbow_motion_onset,testingTrials{i}.elbow_motion_end,testingTrials{i}.elbow_angle,tw_length/2,SR_mocap,1,tw_overlap/4,2);
            testingSet{i}.elbow_v=createTW(testingTrials{i}.elbow_motion_onset,testingTrials{i}.elbow_motion_end,testingTrials{i}.elbow_angular_velocity,tw_length/2,SR_mocap,1,tw_overlap/4,2);
                
            testingSet{i}.grasp=testingTrials{i}.grasp;
            
        case 2
                
            testingSet{i}.emg=createTW(floor((testingTrials{i}.elbow_flexion_onset/SR_mocap)*SR_emg),floor((testingTrials{i}.elbow_flexion_end/SR_mocap)*SR_emg),testingTrials{i}.emg,tw_length,SR_emg,mIDs,tw_overlap,featuresIDs);
                
            testingSet{i}.elbow_angle=createTW(testingTrials{i}.elbow_flexion_onset,testingTrials{i}.elbow_flexion_end,testingTrials{i}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
            testingSet{i}.elbow_angular_velocity=createTW(testingTrials{i}.elbow_flexion_onset,testingTrials{i}.elbow_flexion_end,testingTrials{i}.elbow_angular_velocity,tw_length,SR_mocap,1,tw_overlap,2);
        
            
            testingSet{i}.emg=testingSet{i}.emg(1:min([size(testingSet{i}.emg,1),length(testingSet{i}.elbow_angle)]),:);
            testingSet{i}.elbow_angle=testingSet{i}.elbow_angle(1:min([size(testingSet{i}.emg,1),length(testingSet{i}.elbow_angle)]));
            testingSet{i}.elbow_angular_velocity=testingSet{i}.elbow_angular_velocity(1:min([size(testingSet{i}.emg,1),length(testingSet{i}.elbow_angle)]));
        
            testingSet{i}.Aperture=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.Aperture,tw_length/2,SR_mocap,1,tw_overlap/4,2);
            testingSet{i}.velocity_Aperture=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.velocity_Aperture,tw_length/2,SR_mocap,1,tw_overlap/4,2);
        
            testingSet{i}.FTipsArea=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.FTipsArea,tw_length/2,SR_mocap,1,tw_overlap/4,2);
            testingSet{i}.velocity_Area=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.velocity_Area,tw_length/2,SR_mocap,1,tw_overlap/4,2);
            
            testingSet{i}.elbow_a=createTW(testingTrials{i}.elbow_motion_onset,testingTrials{i}.elbow_motion_end,testingTrials{i}.elbow_angle,tw_length/2,SR_mocap,1,tw_overlap/4,2);
            testingSet{i}.elbow_v=createTW(testingTrials{i}.elbow_motion_onset,testingTrials{i}.elbow_motion_end,testingTrials{i}.elbow_angular_velocity,tw_length/2,SR_mocap,1,tw_overlap/4,2);
          
            testingSet{i}.grasp=testingTrials{i}.grasp;
            
        case 3
                
                
            tmpEMG1=createTW(floor((testingTrials{i}.elbow_extension_onset/SR_mocap)*SR_emg),floor((testingTrials{i}.elbow_extension_end/SR_mocap)*SR_emg),testingTrials{i}.emg,tw_length,SR_emg,mIDs,tw_overlap,featuresIDs);
                
            tmp_elbow_angle1=createTW(testingTrials{i}.elbow_extension_onset,testingTrials{i}.elbow_extension_end,testingTrials{i}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
            tmp_elbow_angular_velocity1=createTW(testingTrials{i}.elbow_extension_onset,testingTrials{i}.elbow_extension_end,testingTrials{i}.elbow_angular_velocity,tw_length,SR_mocap,1,tw_overlap,2);
        
            tmpEMG2=createTW(floor((testingTrials{i}.elbow_flexion_onset/SR_mocap)*SR_emg),floor((testingTrials{i}.elbow_flexion_end/SR_mocap)*SR_emg),testingTrials{i}.emg,tw_length,SR_emg,mIDs,tw_overlap,featuresIDs);
                
            tmp_elbow_angle2=createTW(testingTrials{i}.elbow_flexion_onset,testingTrials{i}.elbow_flexion_end,testingTrials{i}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
            tmp_elbow_angular_velocity2=createTW(testingTrials{i}.elbow_flexion_onset,testingTrials{i}.elbow_flexion_end,testingTrials{i}.elbow_angular_velocity,tw_length,SR_mocap,1,tw_overlap,2);
                
        
            testingSet{i}.emg=[tmpEMG1(1:min([size(tmpEMG1,1),length(tmp_elbow_angle1)]),:);tmpEMG2(1:min([size(tmpEMG2,1),length(tmp_elbow_angle2)]),:)];
            testingSet{i}.elbow_angle=[tmp_elbow_angle1(1:min([size(tmpEMG1,1),length(tmp_elbow_angle1)]));tmp_elbow_angle2(1:min([size(tmpEMG2,1),length(tmp_elbow_angle2)]))];
            testingSet{i}.elbow_angular_velocity=[tmp_elbow_angular_velocity1(1:min([size(tmpEMG1,1),length(tmp_elbow_angle1)]));tmp_elbow_angular_velocity2(1:min([size(tmpEMG2,1),length(tmp_elbow_angle2)]))];
                
            testingSet{i}.Aperture=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.Aperture,tw_length/2,SR_mocap,1,tw_overlap/4,2);
            testingSet{i}.velocity_Aperture=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.velocity_Aperture,tw_length/2,SR_mocap,1,tw_overlap/4,2);
        
            testingSet{i}.FTipsArea=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.FTipsArea,tw_length/2,SR_mocap,1,tw_overlap/4,2);
            testingSet{i}.velocity_Area=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.velocity_Area,tw_length/2,SR_mocap,1,tw_overlap/4,2);
            
            testingSet{i}.elbow_a=createTW(testingTrials{i}.elbow_motion_onset,testingTrials{i}.elbow_motion_end,testingTrials{i}.elbow_angle,tw_length/2,SR_mocap,1,tw_overlap/4,2);
            testingSet{i}.elbow_v=createTW(testingTrials{i}.elbow_motion_onset,testingTrials{i}.elbow_motion_end,testingTrials{i}.elbow_angular_velocity,tw_length/2,SR_mocap,1,tw_overlap/4,2);
            
            testingSet{i}.grasp=testingTrials{i}.grasp;
            
        otherwise
            disp('set options not properly defined');
            return;
    end

    
end





end