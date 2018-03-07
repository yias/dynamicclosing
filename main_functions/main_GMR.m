

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

% for i=1:size(all_data,1)
%     
%     all_data(i,:)=all_data(i,:)./maxValues;
% 
% end

%% Fit GMM with Chosen parameters
K = 10;

%%%% Run MY GMM-EM function, estimates the paramaters by maximizing loglik
Xi = [all_data velocity_labels angle_labels]'; close all;
[Priors, Mu, Sigma] = ml_gmmEM(Xi, K);

%%

% GMM parameters
cov_type = 'full';  plot_iter = 0;

% Cross-validation parameters
tt_ratio  = 0.7;    % train/test ratio
k_range   = 1:20;   % range of K to evaluate
F_fold    = 3;     % # of Folds for cv

% Compute F-fold cross-validation
[MSE_F_fold, NMSE_F_fold, R2_F_fold, AIC_F_fold, BIC_F_fold, std_MSE_F_fold, std_NMSE_F_fold, std_R2_F_fold, ...,
    std_AIC_F_fold, std_BIC_F_fold] = cross_validation_gmr(all_data', [velocity_labels angle_labels]', cov_type, plot_iter, F_fold, tt_ratio, k_range);

figure
plot(k_range,MSE_F_fold)
hold on
errorbar(k_range,MSE_F_fold,std_MSE_F_fold)
title('MSE')
xlabel('number of gaussians')
ylabel('MSE')
grid on


figure
plot(k_range,BIC_F_fold)
hold on
plot(k_range,AIC_F_fold)
errorbar(k_range,BIC_F_fold,std_BIC_F_fold)
errorbar(k_range,AIC_F_fold,std_AIC_F_fold)
title('  BIC AIC criteria')
xlabel('number of gausians')
ylabel('AIC/BIC Score')
legend('BIC', 'AIC')
grid on

%%
figure
plot(k_range,NMSE_F_fold)
hold on
errorbar(k_range,NMSE_F_fold,std_NMSE_F_fold)
title('NMSE')
xlabel('number of gaussians')
ylabel('NMSE')
grid on

%%
%%%% Run MY GMM-EM function, estimates the paramaters by maximizing loglik

% select number of gaussians
K=7;

% fit the data to K gaussians
[Priors, Mu, Sigma] = my_gmmEM([all_data velocity_labels angle_labels]', K, cov_type,  plot_iter);

% validation with the training data

in  = 1:size(all_data,2);       % input dimensions
out = size(all_data,2)+1:size([all_data velocity_labels angle_labels],2); % output dimensions


% [y_est, ~] = my_gmr(Priors, Mu, Sigma, all_data', in, out);


% validation with the testing data
testingData=[];
velocity_testing_labels=[];
angle_testing_labels=[];

for i=1:length(testingSet)
    
%     testingData=[testingData;testingSet{i}.emg/maxValues];
    testingData=[testingData;testingSet{i}.emg];
    
    velocity_testing_labels=[velocity_testing_labels;testingSet{i}.elbow_angular_velocity];
    
    angle_testing_labels=[angle_testing_labels;testingSet{i}.elbow_angle];
    
end

[y_est, var_est] = my_gmr(Priors, Mu, Sigma, testingData', in, out);

% compute MSE
velMSE=sum(((y_est(1,:)-velocity_testing_labels').^2))/length(velocity_testing_labels);
angMSE=sum(((y_est(2,:)-angle_testing_labels').^2))/length(angle_testing_labels);

% compute R2
% velR2 = (sum((velocity_testing_labels-mean(velocity_testing_labels)).*(y_est(1,:) - mean(y_est(1,:))))/(sqrt(sum((velocity_testing_labels-mean(velocity_testing_labels)).^2))*sqrt(sum((y_est(1,:)-mean(y_est(1,:),2)).^2))))^2;

velR2=1-(sum((velocity_testing_labels-y_est(1,:)').^2))/sum((velocity_testing_labels-mean(velocity_testing_labels)).^2);
angR2=1-(sum((angle_testing_labels-y_est(2,:)').^2))/sum((angle_testing_labels-mean(angle_testing_labels)).^2);

disp([num2str(K) ' Gaussians, Performance: '])
disp(['velocity R2= ' num2str(velR2) ' MSE= ' num2str(velMSE)])
disp(['angle R2= ' num2str(angR2) ' MSE= ' num2str(angMSE) ])

figure()
plot(velocity_testing_labels,'b')
hold on
plot(y_est(1,:),'r')
legend('Ground truth','predicted')
ylabel('degrees/sec')
xlabel('samples')
title(['elbow angular velocity K=' num2str(K)])
grid on

figure()
plot(angle_testing_labels,'b')
hold on
plot(y_est(2,:),'r')
legend('Ground truth','predicted')
ylabel('degrees/sec')
xlabel('samples')
title(['elbow joint angle K=' num2str(K)])
grid on




