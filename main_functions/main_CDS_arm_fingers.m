

SR_mocap=250;

organize_data




% create data

master_data=struct([]);
slave_data=struct([]);
counter=1;


for i=1:length(crossvalidationFolders)
    for j=1:length(crossvalidationFolders{i})
        if crossvalidationFolders{i}{j}.grasp==3
        master_data{counter}=[crossvalidationFolders{i}{j}.elbow_a';crossvalidationFolders{i}{j}.elbow_v'];
        slave_data{counter}=[crossvalidationFolders{i}{j}.FTipsArea'];%crossvalidationFolders{i}{j}.velocity_Area'];
        counter=counter+1;
        end
    end
end


%%

%% Master Parameters 

% === General parameters ===
cds_learning_parameters.master.K    = 6;            % Number of Gaussian functions
cds_learning_parameters.master.dt   = 1/SR_mocap;     % sampling frequency of the data x the decimation factor used when loading
cds_learning_parameters.master.tol  = 0.2;          % Tolerance factor for cutting the demos

% === Solver parameters ===

% A set of options that will be passed to the solver. Please type 'doc
% preprocess_demos' in the MATLAB command window to get detailed
% information about each option.

options=[];
options.tol_mat_bias    = 10^-6;   % to avoid instabilities in the gaussian kernel
options.perior_opt      = 0;
options.mu_opt          = 1;       % optimize centers
options.sigma_x_opt     = 1;
options.display         = 1;
options.tol_stopping    = 10^-10;
options.max_iter        = 5000;
options.normalization   = 1;
options.objective       = 'mse';
options.cons_penalty    = 1e20; % penalty for not going straight to the attractor. 
                                % Increase to obtain a more straight line
cds_learning_parameters.master.solver_options = options;
clear options; 

% === Simulator parameters === 

opt_sim.dt      = 0.01;
opt_sim.i_max   = 3000;
opt_sim.tol     = 0.001;

cds_learning_parameters.master.sim_options = opt_sim;



%% Learn Master Dynamics (pos -> velocity)
masterGMM   = cds_learn_master(master_data, cds_learning_parameters);

