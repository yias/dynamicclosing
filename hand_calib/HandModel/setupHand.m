if ~exist('subject_name', 'var')
    error('The variable subject_name must exist before calling setupHand');
end
if ~exist('thumb_model', 'var')
    error('The variable thumb_model must exist before calling setupHand');
end
if ~exist('task', 'var')
    disp('Task not specified ... using default');
    task = 'default';
end
if ~exist('calibration', 'var')
    disp(['Calibration not specified ... using ' subject_name]);
    calibration = subject_name;
end
if ~exist('visualization', 'var')
    disp('Sensor Visualization not specified ... using pressurebar');
    visualization = 'pressurebar';
end


data_directory = ['data/' task '/' subject_name];

clear h min_glove max_glove;
handParms = {   'thumb_mod', thumb_model, ...
                'hand_geom', CybergloveHand.handGeom(subject_name), ...
                'default_wrist', Hand.wrld_T_palmYup ...
                'sensor_visualization', visualization 
                %'hand_box', [-7 13; 0 20; -3 10]
            };
global h;
h = CybergloveHand(true, handParms{:});
% calibration should be completely within the specialized hand.
calibration_directory = ['data/calibration/' calibration];
min_file = [calibration_directory '/min_glove_values'];
max_file = [calibration_directory '/max_glove_values'];
calib_file = [calibration_directory '/thumb_calibration_' thumb_model];
h.calibration.calib_file = calib_file;
h.calibration.min_file = min_file;
h.calibration.max_file = max_file;


% for default_wrist = Hand.wrld_T_palmYup
%armtoolThand = trotx(pi/2)*troty(-pi/2);
%wrldThand = troty(pi);

% for default_wrist = Hand.wrld_T_palmYdown
armtoolThand = trotx(pi/2)*troty(pi/2);
wrldThand = eye(4);
