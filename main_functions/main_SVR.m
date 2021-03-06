


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

%%
[maxValues,~]=max(all_data);
% [maxVel,~]=max(velocity_labels);
% [maxAng,~]=max(angle_labels);

% for i=1:nb_folders
%     for j=1:length(crossvalidationFolders{i})
%         for k=1:size(crossvalidationFolders{i}{j}.emg)
%             crossvalidationFolders{i}{j}.emg(k,:)=crossvalidationFolders{i}{j}.emg(k,:)./maxValues;
% %             crossvalidationFolders{i}{j}.elbow_angular_velocity=crossvalidationFolders{i}{j}.elbow_angular_velocity/maxVel;
% %             crossvalidationFolders{i}{j}.elbow_angle=crossvalidationFolders{i}{j}.elbow_angle/maxAng;
%         end
%     end
% end

% for i=1:size(all_data,1)
%     
%     all_data(i,:)=all_data(i,:)./maxValues;
% 
% end
%%
% velocity_labels=velocity_labels/maxVel;
% angle_labels=angle_labels/maxAng;

epsilon=1:5:60;
constraint=[1,10,100,200,10000,11000,12000,13000];
gamma=[0.1,0.3,0.5,0.7,0.8,1,5,10,100,500,1000];

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

disp('done!')
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
[X,Y,Z]=meshgrid(gamma,epsilon,constraint);

figure(21)

slice(X,Y,Z,velocity_testing_performce_MSE,[],epsilon,[])
hold on
contourslice(X,Y,Z,velocity_testing_performce_MSE,[],epsilon,[])
xlabel('gamma')
ylabel('epsilon')
zlabel('C')
title('velocity performance MSE')
grid on
colorbar

figure(22)
hold on
slice(X,Y,Z,angle_testing_perforamce_MSE,[],epsilon,[])
hold on
contourslice(X,Y,Z,angle_testing_perforamce_MSE,[],epsilon,[])
xlabel('gamma')
ylabel('epsilon')
zlabel('C')
title('angle performance MSE')
grid on
colorbar



%%

% find best parameters for velocity

[vel_best_epsilon,vel_best_gamma,vel_best_C,best_performance_velocity]=best_parameters(velocity_testing_performce_R2,epsilon,gamma,constraint,'max');
% [vel_best_epsilon,vel_best_gamma,vel_best_C,best_performance_velocity]=best_parameters(velocity_testing_performce_MSE,epsilon,gamma,constraint,'min');

% find best parameters for angle

[ang_best_epsilon,ang_best_gamma,ang_best_C,best_performance_angle]=best_parameters(angle_testing_performce_R2,epsilon,gamma,constraint,'max');
% [ang_best_epsilon,ang_best_gamma,ang_best_C,best_performance_angle]=best_parameters(angle_testing_perforamce_MSE,epsilon,gamma,constraint,'min');


disp(['velocity best parameters(epsilon,gamma,C): ' num2str([vel_best_epsilon,vel_best_gamma,vel_best_C])])
disp(['angle best parameters(epsilon,gamma,C): ' num2str([ang_best_epsilon,ang_best_gamma,ang_best_C])])



%% training an SVR with the best parameters

velocity_model = svmtrain(velocity_labels, all_data, [' -q -s 3 -t 2 -p ' num2str(vel_best_epsilon) ' -g ' num2str(vel_best_gamma) ' -c ' num2str(vel_best_C)]);

angle_model = svmtrain(angle_labels, all_data, [' -q -s 3 -t 2 -p ' num2str(ang_best_epsilon) ' -g ' num2str(ang_best_gamma) ' -c ' num2str(ang_best_C)]);


%% validation with the training data

[velocity_predict_label_tr, velocity_accuracy_tr, velocity_decision_value_tr] = svmpredict(velocity_labels, all_data, velocity_model, ' -q');

[angle_predict_label_tr, angle_accuracy_tr, angle_decision_value_tr] = svmpredict(angle_labels, all_data, angle_model, ' -q');

velR2=1-(sum((velocity_labels-velocity_predict_label_tr).^2))/sum((velocity_labels-mean(velocity_labels)).^2);
angR2=1-(sum((angle_labels-angle_predict_label_tr).^2))/sum((angle_labels-mean(angle_labels)).^2);

figure(15)
plot(velocity_labels,'b')
hold on
plot(velocity_predict_label_tr,'r')
grid on
xlabel('samples')
ylabel('degrees/sec')
legend('groundtruth','predicted')
title('Training set - angular velocity performance')

figure(16)
plot(angle_labels,'b')
hold on
plot(angle_predict_label_tr,'r')
grid on
xlabel('samples')
ylabel('degrees')
legend('groundtruth','predicted')
title('Training set - joint angle performance')


%%


testingData=[];
velocity_testing_labels=[];
angle_testing_labels=[];

for i=1:length(testingSet)
    
%     testingData=[testingData;testingSet{i}.emg/maxValues];
    testingData=[testingData;testingSet{i}.emg];
    
    velocity_testing_labels=[velocity_testing_labels;testingSet{i}.elbow_angular_velocity];
    
    angle_testing_labels=[angle_testing_labels;testingSet{i}.elbow_angle];
    
end


[velocity_predict_label_test, velocity_accuracy_test, velocity_decision_value_test] = svmpredict(velocity_testing_labels, testingData, velocity_model, ' -q');

[angle_predict_label_test, angle_accuracy_test, angle_decision_value_test] = svmpredict(angle_testing_labels, testingData, angle_model, ' -q');


velR2=1-(sum((velocity_testing_labels-velocity_predict_label_test).^2))/sum((velocity_testing_labels-mean(velocity_testing_labels)).^2);
angR2=1-(sum((angle_testing_labels-angle_predict_label_test).^2))/sum((angle_testing_labels-mean(angle_testing_labels)).^2);

disp(['regression perforamnce in velocity: R2= ' num2str(velR2) ' , MSE= ' num2str(velocity_accuracy_test(2)) ' nSV= ' num2str(velocity_model.totalSV/size(all_data,1))])

disp(['regression perforamnce in angle: R2= ' num2str(angR2) ' , MSE= ' num2str(angle_accuracy_test(2)) ' nSV= ' num2str(angle_model.totalSV/size(all_data,1))])


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





