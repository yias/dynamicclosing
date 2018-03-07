


function [Folders]=createRegressionSets_test(trials,varargin)


Folders=struct([]);





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
tw_overlap=0.05;

% sampling rate of the mocap system
SR_mocap=251;

% sampling rate of the emg system
SR_emg=1500;

% ids of the features to be extracted
% 1: rms
% 2: average
% 3: std
% 4: waveform length
% 5: zero crossings
% 6: slopechanges
featuresIDs=[1,2,4,6];

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
            SR_emg=varargin{kk+1};
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




testingTrials=trials;



for i=1:length(testingTrials)
    
%     if i==41
    
    i
%     end
    
    switch Set_Option
        case 1    
            Folders{i}.emg=createTW(floor((testingTrials{i}.elbow_extension_onset/SR_mocap)*SR_emg),floor((testingTrials{i}.elbow_extension_end/SR_mocap)*SR_emg),testingTrials{i}.emg,tw_length,SR_emg,mIDs,tw_overlap,featuresIDs);
            
            Folders{i}.elbow_angle=createTW(testingTrials{i}.elbow_extension_onset,testingTrials{i}.elbow_extension_end,testingTrials{i}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
            Folders{i}.elbow_angular_velocity=createTW(testingTrials{i}.elbow_extension_onset,testingTrials{i}.elbow_extension_end,testingTrials{i}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
        
        
            Folders{i}.Aperture=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.Aperture,tw_length,SR_mocap,1,tw_overlap,2);
            Folders{i}.velocity_Aperture=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.velocity_Aperture,tw_length,SR_mocap,1,tw_overlap,2);
            
            Folders{i}.FTipsArea=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.FTipsArea,tw_length,SR_mocap,1,tw_overlap,2);
            Folders{i}.velocity_Area=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.velocity_Area,tw_length,SR_mocap,1,tw_overlap,2);
            
            Folders{i}.elbow_a=createTW(testingTrials{i}.elbow_motion_onset,testingTrials{i}.elbow_motion_end,testingTrials{i}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
            Folders{i}.elbow_v=createTW(testingTrials{i}.elbow_motion_onset,testingTrials{i}.elbow_motion_end,testingTrials{i}.elbow_angular_velocity,tw_length,SR_mocap,1,tw_overlap,2);
                
        case 2
                
            Folders{i}.emg=createTW(floor((testingTrials{i}.elbow_flexion_onset/SR_mocap)*SR_emg),floor((testingTrials{i}.elbow_flexion_end/SR_mocap)*SR_emg),testingTrials{i}.emg,tw_length,SR_emg,mIDs,tw_overlap,featuresIDs);
                
            Folders{i}.elbow_angle=createTW(testingTrials{i}.elbow_flexion_onset,testingTrials{i}.elbow_flexion_end,testingTrials{i}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
            Folders{i}.elbow_angular_velocity=createTW(testingTrials{i}.elbow_flexion_onset,testingTrials{i}.elbow_flexion_end,testingTrials{i}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
        
        
            Folders{i}.Aperture=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.Aperture,tw_length,SR_mocap,1,tw_overlap,2);
            Folders{i}.velocity_Aperture=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.velocity_Aperture,tw_length,SR_mocap,1,tw_overlap,2);
        
            Folders{i}.FTipsArea=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.FTipsArea,tw_length,SR_mocap,1,tw_overlap,2);
            Folders{i}.velocity_Area=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.velocity_Area,tw_length,SR_mocap,1,tw_overlap,2);
            
            Folders{i}.elbow_a=createTW(testingTrials{i}.elbow_motion_onset,testingTrials{i}.elbow_motion_end,testingTrials{i}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
            Folders{i}.elbow_v=createTW(testingTrials{i}.elbow_motion_onset,testingTrials{i}.elbow_motion_end,testingTrials{i}.elbow_angular_velocity,tw_length,SR_mocap,1,tw_overlap,2);
          
        case 3
                
                
            tmpEMG1=createTW(floor((testingTrials{i}.elbow_extension_onset/SR_mocap)*SR_emg),floor((testingTrials{i}.elbow_extension_end/SR_mocap)*SR_emg),testingTrials{i}.emg,tw_length,SR_emg,mIDs,tw_overlap,featuresIDs);
                
            tmp_elbow_angle1=createTW(testingTrials{i}.elbow_extension_onset,testingTrials{i}.elbow_extension_end,testingTrials{i}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
            tmp_elbow_angular_velocity1=createTW(testingTrials{i}.elbow_extension_onset,testingTrials{i}.elbow_extension_end,testingTrials{i}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
        
            tmpEMG2=createTW(floor((testingTrials{i}.elbow_flexion_onset/SR_mocap)*SR_emg),floor((testingTrials{i}.elbow_flexion_end/SR_mocap)*SR_emg),testingTrials{i}.emg,tw_length,SR_emg,mIDs,tw_overlap,featuresIDs);
                
            tmp_elbow_angle2=createTW(testingTrials{i}.elbow_flexion_onset,testingTrials{i}.elbow_flexion_end,testingTrials{i}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
            tmp_elbow_angular_velocity2=createTW(testingTrials{i}.elbow_flexion_onset,testingTrials{i}.elbow_flexion_end,testingTrials{i}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
                
        
            Folders{i}.emg=[tmpEMG1;tmpEMG2];
            Folders{i}.elbow_angle=[tmp_elbow_angle1;tmp_elbow_angle2];
            Folders{i}.elbow_angular_velocity=[tmp_elbow_angular_velocity1;tmp_elbow_angular_velocity2];
                
            Folders{i}.Aperture=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.Aperture,tw_length,SR_mocap,1,tw_overlap,2);
            Folders{i}.velocity_Aperture=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.velocity_Aperture,tw_length,SR_mocap,1,tw_overlap,2);
        
            Folders{i}.FTipsArea=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.FTipsArea,tw_length,SR_mocap,1,tw_overlap,2);
            Folders{i}.velocity_Area=createTW(testingTrials{i}.fingers_motion_onset,testingTrials{i}.fingers_motion_end,testingTrials{i}.velocity_Area,tw_length,SR_mocap,1,tw_overlap,2);
            
            Folders{i}.elbow_a=createTW(testingTrials{i}.elbow_motion_onset,testingTrials{i}.elbow_motion_end,testingTrials{i}.elbow_angle,tw_length,SR_mocap,1,tw_overlap,2);
            Folders{i}.elbow_v=createTW(testingTrials{i}.elbow_motion_onset,testingTrials{i}.elbow_motion_end,testingTrials{i}.elbow_angular_velocity,tw_length,SR_mocap,1,tw_overlap,2);
            
        otherwise
            disp('set options not properly defined');
            return;
    end

    
end





end