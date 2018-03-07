


organize_data


nb_folders=3;


% normalize data
all_data=[];
velocity_labels=[];
angle_labels=[];

for i=1:nb_folders
    for j=1:length(crossvalidationFolders{i})
        all_data=[all_data;crossvalidationFolders{i}{j}.emg];
        velocity_labels=[velocity_labels;crossvalidationFolders{i}{j}.elbow_angular_velocity];
        angle_labels=[angle_labels;crossvalidationFolders{i}{j}.elbow_angle];
    end
end

[maxValues,~]=max(all_data);
% [maxVel,~]=max(velocity_labels);
% [maxAng,~]=max(angle_labels);

for i=1:nb_folders
    for j=1:length(crossvalidationFolders{i})
        for k=1:size(crossvalidationFolders{i}{j}.emg)
            crossvalidationFolders{i}{j}.emg(k,:)=crossvalidationFolders{i}{j}.emg(k,:)./maxValues;
%             crossvalidationFolders{i}{j}.elbow_angular_velocity=crossvalidationFolders{i}{j}.elbow_angular_velocity/maxVel;
%             crossvalidationFolders{i}{j}.elbow_angle=crossvalidationFolders{i}{j}.elbow_angle/maxAng;
        end
    end
end

for i=1:size(all_data,1)
    
    all_data(i,:)=all_data(i,:)./maxValues;

end



%%   3) Do K-fold cross validation on hyper-parameters for \nu-SVR  %%                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Parameter grid search SVR');

% Set these parameters!
svm_type        = '0';        % SVR Type (0:epsilon-SVR, 1:nu-SVR)
kernel_type     = 2;          % 0: linear: u'*v, 1: polynomial: (gamma*u'*v + coef0)^degree, 2: radial basis function: exp(-gamma*|u-v|^2)
limits_C        = [100 10000];    % Limits of penalty C
limits_nu       = [10 100]; % Limits of epsilon
limits_w        = [0.1 2];     % Limits of kernel width \sigma
step            = 10;          % Step of parameter grid 
Kfold           = 3;
metric = 'nmse';

function_type   = {svm_type , kernel_type};
parameters      = vertcat(limits_C, limits_nu, limits_w);

% Do Grid Search
[ ctest, ctrain , cranges ] = ml_grid_search_regr( all_data, velocity_labels, Kfold, parameters, step, function_type);


%% Get CV statistics
statsSVR = ml_get_cv_grid_states_regression(ctest,ctrain);

%% Plot Heatmaps from Grid Search 
cv_plot_options              = [];
cv_plot_options.title        = strcat('$\nu$-SVR :: ', num2str(Kfold),'-fold CV with RBF');
cv_plot_options.para_names  = {'C','\nu', '\sigma'};
cv_plot_options.metrics      = {'nrmse'};
cv_plot_options.param_ranges = [cranges{1} ; cranges{2}; cranges{3}];

parameters_used = [cranges{1};cranges{2};cranges{3}];

% if exist('hcv','var') && isvalid(hcv), delete(hcv);end
figure;
hcv = ml_plot_cv_grid_states_regression(statsSVR,parameters_used,cv_plot_options);

%% Find 'optimal hyper-parameters'
% Extract parameter ranges
range_C  = cranges(1,:);
range_eps  = cranges(2,:);
range_w  = cranges(3,:);

stats= statsSVR;

[max_acc,ind] = min(stats.train.nrmse.mean(:));
[C_max, eps_max, w_max] = ind2sub(size(stats.train.nrmse.mean),ind);

C_opt = range_C{1}(C_max)
eps_opt = range_eps{1}(eps_max)
w_opt = range_w{1}(w_max)


%% 2c) epsilon-SVR + RBF Kernel
% SVR OPTIONS
clear svr_options
svr_options.svr_type    = 0;    % 0: epsilon-SVR, 1: nu-SVR
svr_options.C           = C_opt;   % set the parameter C of C-SVC, epsilon-SVR, and nu-SVR 
svr_options.epsilon     = eps_opt;  % set the epsilon in loss function of epsilon-SVR 
% Kernel OPTIONS
svr_options.kernel_type = 2;    % 0: linear: u'*v, 1: polynomial: (gamma*u'*v + coef0)^degree, 2: radial basis function: exp(-gamma*|u-v|^2)
svr_options.sigma       = w_opt;  %  radial basis function: exp(-gamma*|u-v|^2), gamma = 1/(2*sigma^2)


% Train SVR Model
clear model
[~, model] = svm_regressor(all_data, velocity_labels, svr_options, []);

%% validation with training data

 % validate the regressor with training data
[angle_predict_label_tr, angle_accuracy_tr, angle_decision_value_tr] = svmpredict(velocity_labels, all_data, model, ' -q');


%%

% velocity_labels=velocity_labels/maxVel;
% angle_labels=angle_labels/maxAng;

epsilon=10:10:100;
constraint=[100,1000,5000,10000];
gamma=[0.1,0.2,0.3,0.4,0.5,0.6];

velocity_training_performce_R2=zeros(length(epsilon),length(gamma),length(constraint));
velocity_testing_performce_R2=zeros(length(epsilon),length(gamma),length(constraint));

velocity_training_performce_MSE=zeros(length(epsilon),length(gamma),length(constraint));
velocity_testing_performce_MSE=zeros(length(epsilon),length(gamma),length(constraint));

angle_training_performce_R2=zeros(length(epsilon),length(gamma),length(constraint));
angle_testing_performce_R2=zeros(length(epsilon),length(gamma),length(constraint));

angle_training_performce_MSE=zeros(length(epsilon),length(gamma),length(constraint));
angle_testing_perforamce_MSE=zeros(length(epsilon),length(gamma),length(constraint));



for eps=1:length(epsilon)
    for g=1:length(gamma)
        for cc=1:length(constraint)
            
            velocity_performance_train=[];
            velocity_performance_validation=[];
            angle_performance_train=[];
            angle_performance_validation=[];
            
            for i=1:nb_folders


                validation_data=[];
                validation_labels_velocity=[];
                validation_labels_angle=[];

                for j=1:length(crossvalidationFolders{i})
                    validation_data=[validation_data;crossvalidationFolders{i}{j}.emg];
                    validation_labels_velocity=[validation_labels_velocity;crossvalidationFolders{i}{j}.elbow_angular_velocity];
                    validation_labels_angle=[validation_labels_angle;crossvalidationFolders{i}{j}.elbow_angle];
                end



                training_data=[];
                traing_labels_velocity=[];
                traing_labels_angle=[];


                for kk=1:nb_folders
                    if kk~=i
                        for j=1:length(crossvalidationFolders{kk})
                            training_data=[training_data;crossvalidationFolders{kk}{j}.emg];
                            traing_labels_velocity=[traing_labels_velocity;crossvalidationFolders{kk}{j}.elbow_angular_velocity];
                            traing_labels_angle=[traing_labels_angle;crossvalidationFolders{kk}{j}.elbow_angle];
                        end
                    end
                end


                % train SVR for velocity
                velocity_model = svmtrain(traing_labels_velocity, training_data, [' -q -s 3 -t 2 -p ' num2str(epsilon(eps)) ' -g ' num2str(gamma(g)) ' -c ' num2str(constraint(cc))]);

                % validate the regressor with training data
                [velocity_predict_label_tr, velocity_accuracy_tr, velocity_decision_value_tr] = svmpredict(traing_labels_velocity, training_data, velocity_model, ' -q');

                % validate the regressor with the validation data
                [velocity_predict_label_validation, velocity_accuracy_validation, velocity_decision_value_validation] = svmpredict(validation_labels_velocity, validation_data, velocity_model, ' -q');
                
                velocity_performance_train=[velocity_performance_train;velocity_accuracy_tr(2:3)'];
                velocity_performance_validation=[velocity_performance_validation;velocity_accuracy_validation(2:3)'];
                

                % train SVR for joint angle
                angle_model = svmtrain(traing_labels_angle, training_data, [' -q -s 3 -t 2 -p ' num2str(epsilon(eps)) ' -g ' num2str(gamma(g)) ' -c ' num2str(constraint(cc))]);

                % validate the regressor with training data
                [angle_predict_label_tr, angle_accuracy_tr, angle_decision_value_tr] = svmpredict(traing_labels_angle, training_data, angle_model, ' -q');

                % validate the regressor with the validation data
                [angle_predict_label_validation, angle_accuracy_validation, angle_decision_value_validation] = svmpredict(validation_labels_angle, validation_data, angle_model, ' -q');
                
                angle_performance_train=[angle_performance_train;angle_accuracy_tr(2:3)'];
                angle_performance_validation=[angle_performance_validation;angle_accuracy_validation(2:3)'];                             
                


            end
            
            velocity_training_performce_R2(eps,g,cc)=mean(velocity_performance_train(:,2));
            velocity_training_performce_MSE(eps,g,cc)=mean(velocity_performance_train(:,1));
            
            velocity_testing_performce_R2(eps,g,cc)=mean(velocity_performance_validation(:,2));
            velocity_testing_performce_MSE(eps,g,cc)=mean(velocity_performance_validation(:,1));
            
            angle_training_performce_R2(eps,g,cc)=mean(angle_performance_train(:,2));
            angle_training_performce_MSE(eps,g,cc)=mean(angle_performance_train(:,1));
            
            angle_testing_performce_R2(eps,g,cc)=mean(angle_performance_validation(:,2));
            angle_testing_perforamce_MSE(eps,g,cc)=mean(angle_performance_validation(:,1));
            
            
            
        end
    end


end
%%
[X,Y,Z]=meshgrid(gamma,epsilon,constraint);

figure(1)

slice(X,Y,Z,velocity_testing_performce_R2,[],epsilon,[])
hold on
contourslice(X,Y,Z,velocity_testing_performce_R2,[],epsilon,[])
xlabel('gamma')
ylabel('epsilon')
zlabel('C')
title('velocity performance R2')
grid on
colorbar

figure(2)
hold on
slice(X,Y,Z,angle_testing_performce_R2,[],epsilon,[])
hold on
contourslice(X,Y,Z,angle_testing_performce_R2,[],epsilon,[])
xlabel('gamma')
ylabel('epsilon')
zlabel('C')
title('angle performance R2')
grid on
colorbar

%%

% find best parameters for velocity

[vel_best_epsilon,vel_best_gamma,vel_best_C,best_performance_velocity]=best_parameters(velocity_testing_performce_R2,epsilon,gamma,constraint,'min');

% find best parameters for angle

[ang_best_epsilon,ang_best_gamma,ang_best_C,best_performance_angle]=best_parameters(angle_testing_performce_R2,epsilon,gamma,constraint,'min');



%% validation with the testing set

velocity_model = svmtrain(velocity_labels, all_data, [' -q -s 3 -t 2 -p ' num2str(vel_best_epsilon) ' -g ' num2str(vel_best_gamma) ' -c ' num2str(vel_best_C)]);

angle_model = svmtrain(angle_labels, all_data, [' -q -s 3 -t 2 -p ' num2str(ang_best_epsilon) ' -g ' num2str(ang_best_gamma) ' -c ' num2str(ang_best_C)]);


testingData=[];
velocity_testing_labels=[];
angle_testing_labels=[];

for i=1:length(testingSet)
    
    testingData=[testingData;testingSet{i}.emg/maxValues];
    
    velocity_testing_labels=[velocity_testing_labels;testingSet{i}.elbow_angular_velocity];
    
    angle_testing_labels=[angle_testing_labels;testingSet{i}.elbow_angle];
    
end


[velocity_predict_label_test, velocity_accuracy_test, velocity_decision_value_test] = svmpredict(velocity_testing_labels, testingData, velocity_model, ' -q');

[angle_predict_label_test, angle_accuracy_test, angle_decision_value_test] = svmpredict(angle_testing_labels, testingData, angle_model, ' -q');

disp(['regression perforamnce in velocity: R2= ' num2str(velocity_accuracy_test(3)) ' , MSE= ' num2str(velocity_accuracy_test(2)) ' nSV= ' num2str(velocity_model.totalSV/size(all_data,1))])

disp(['regression perforamnce in angle: R2= ' num2str(angle_accuracy_test(3)) ' , MSE= ' num2str(angle_accuracy_test(2)) ' nSV= ' num2str(angle_model.totalSV/size(all_data,1))])


figure(5)
plot(velocity_testing_labels,'b')
hold on
plot(velocity_predict_label_test,'r')
grid on
xlabel('samples')
ylabel('degrees/sec')
legend('groundtruth','predicted')
title('angular velocity performance')

figure(6)
plot(angle_testing_labels,'b')
hold on
plot(angle_predict_label_test,'r')
grid on
xlabel('samples')
ylabel('degrees')
legend('groundtruth','predicted')
title('joint angle performance')





