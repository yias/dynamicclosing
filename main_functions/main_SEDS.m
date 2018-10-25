% load('data/data09032017.mat')
load('data/organizedData_16042017.mat')



subject_name='lucia'; thumb_model='rpij'; visualization='importancebar'; setupHand




precision_Ftip=struct([]);
precision_elbow=struct([]);
precision_Ftip_xyz=struct([]);
t2_Ftip=struct([]);
t2_elbow=struct([]);
t2_Ftip_xyz=struct([]);
lateral_Ftip=struct([]);
lateral_elbow=([]);
lateral_Ftip_xyz=struct([]);

precision_counter=1;
t2_counter=1;
lateral_counter=1;


% for ns=1:2
    
    
    for trl=1:length(dataTrials)
        
        thump_tip=[];
        index_tip=[];
        middle_tip=[];
        
        thump_tip_dis=[];
        index_tip_dis=[];
        middle_tip_dis=[];
        
%         if sess{ns}.trials{trl}.orientation==1
            
            
            
            jointAngles=dataTrials{trl}.jointAngles(dataTrials{trl}.reaching_motion_onset:dataTrials{trl}.reaching_motion_end,:);
            
            l=size(jointAngles,1);
            
            for i=1:l
                
                thumb=h.Fingers(1).fkine(jointAngles(i,3:7));
                index=h.Fingers(2).fkine(jointAngles(i,8:11));
                middle=h.Fingers(3).fkine(jointAngles(i,12:15));
            
                thump_tip=[thump_tip;[thumb(1,4),thumb(2,4),thumb(3,4)]];
                thump_tip_dis=[thump_tip_dis;sqrt(sum([thumb(1,4),thumb(2,4),thumb(3,4)].^2))];
                index_tip=[index_tip;[index(1,4),index(2,4),index(3,4)]];
                index_tip_dis=[index_tip_dis;sqrt(sum([index(1,4),index(2,4),index(3,4)].^2))];
                middle_tip=[middle_tip;[middle(1,4),middle(2,4),middle(3,4)]];
                middle_tip_dis=[middle_tip_dis;sqrt(sum([middle(1,4),middle(2,4),middle(3,4)].^2))];
                
            end
            
            if dataTrials{trl}.grasp==1
                
                precision_Ftip{precision_counter}=[thump_tip_dis,index_tip_dis,middle_tip_dis]';
                precision_elbow{precision_counter}=dataTrials{trl}.elbow_angle(dataTrials{trl}.reaching_motion_onset:dataTrials{trl}.reaching_motion_end)';
                precision_Ftip_xyz{precision_counter}=[thump_tip,index_tip,middle_tip]';
                precision_counter=precision_counter+1;
            end
            
            if dataTrials{trl}.grasp==3
                
                t2_Ftip{t2_counter}=[thump_tip_dis,index_tip_dis,middle_tip_dis]';
                t2_elbow{t2_counter}=dataTrials{trl}.elbow_angle(dataTrials{trl}.reaching_motion_onset:dataTrials{trl}.reaching_motion_end)';
                t2_Ftip_xyz{t2_counter}=[thump_tip,index_tip,middle_tip]';
                t2_counter=t2_counter+1;
                
            end
            
            if dataTrials{trl}.grasp==5
                
                lateral_Ftip{lateral_counter}=[thump_tip_dis,index_tip_dis,middle_tip_dis]';
                lateral_elbow{lateral_counter}=dataTrials{trl}.elbow_angle(dataTrials{trl}.reaching_motion_onset:dataTrials{trl}.reaching_motion_end)';
                t2_Ftip_xyz{t2_counter}=[thump_tip,index_tip,middle_tip]';
                lateral_counter=lateral_counter+1;
                
            end
            
%         end
        
        
    end
    
% end



figure()
subplot(3,1,1)
plot(lateral_Ftip{1})
hold on
plot(lateral_elbow{1})

subplot(3,1,2)
plot(t2_Ftip{1})
hold on
plot(t2_elbow{1})

subplot(3,1,3)
plot(precision_Ftip{1})
hold on
plot(precision_elbow{1})




%%

precision_end=[];

for i=1:length(precision_Ftip)
    
    precision_end=[precision_end;precision_Ftip{i}(:,end)'];
    
end


t2_end=[];

for i=1:length(t2_Ftip)
    
    t2_end=[t2_end;t2_Ftip{i}(:,end)'];
    
end

lateral_end=[];

for i=1:length(lateral_Ftip)
    
    lateral_end=[lateral_end;lateral_Ftip{i}(:,end)'];
    
end

figure()
scatter3(precision_end(:,1),precision_end(:,2),precision_end(:,3),'b','filled')
hold on
scatter3(t2_end(:,1),t2_end(:,2),t2_end(:,3),'r','filled')
scatter3(lateral_end(:,1),lateral_end(:,2),lateral_end(:,3),'g','filled')
xlabel('$\xi_1 (cm)$','interpreter','latex','fontsize',15);
ylabel('$\xi_2 (cm)$','interpreter','latex','fontsize',15);
zlabel('$\xi_3 (cm)$','interpreter','latex','fontsize',15);

figure()
hold on
mm1=mean(precision_end);

scatter3(mm1(1),mm1(2),mm1(3),150,'b','filled')
mm2=mean(t2_end);

scatter3(mm2(1),mm2(2),mm2(3),150,'r','filled')
mm3=mean(lateral_end);

scatter3(mm3(1),mm3(2),mm3(3),150,'g','filled')

scatter3(mm1(1),mm1(2),mm1(3),1050,'b*')
scatter3(mm2(1),mm2(2),mm2(3),1050,'r*')
scatter3(mm3(1),mm3(2),mm3(3),1050,'g*')
for i=1:length(precision_Ftip)-10
    tmp_precision_Ftip=precision_Ftip{i}+repmat([mm1-precision_Ftip{i}(:,end)'],size(precision_Ftip{i},2),1)';
%     plot3(smooth(precision_Ftip{i}(1,:),100,'lowess'),smooth(precision_Ftip{i}(2,:),100,'lowess'),smooth(precision_Ftip{i}(3,:),100,'lowess'),'b')
    plot3(smooth(tmp_precision_Ftip(1,:),100,'lowess'),smooth(tmp_precision_Ftip(2,:),100,'lowess'),smooth(tmp_precision_Ftip(3,:),100,'lowess'),'b')
%     plot3(smooth([precision_Ftip{i}(1,:)+ones(size(precision_Ftip{i},2),1)*(mm1(1)-precision_Ftip{i}(1,end))],50,'lowess'),smooth([precision_Ftip{i}(2,:)+ones(size(precision_Ftip{i},2),1)*(mm1(2)-precision_Ftip{i}(2,end))],50,'lowess'),smooth([precision_Ftip{i}(3,:)+ones(size(precision_Ftip{i},2),1)*(mm1(3)-precision_Ftip{i}(3,end))],50,'lowess'),'b')
end
for i=1:length(t2_Ftip)-10
    tmp_t2_Ftip=t2_Ftip{i}+repmat([mm2-t2_Ftip{i}(:,end)'],size(t2_Ftip{i},2),1)';
    plot3(smooth(tmp_t2_Ftip(1,:),100,'lowess'),smooth(tmp_t2_Ftip(2,:),100,'lowess'),smooth(tmp_t2_Ftip(3,:),100,'lowess'),'r')
%     plot3(smooth(t2_Ftip{i}(1,:),100,'lowess'),smooth(t2_Ftip{i}(2,:),100,'lowess'),smooth(t2_Ftip{i}(3,:),100,'lowess'),'r')
end

for i=1:length(lateral_Ftip)-10
    tmp_lateral_Ftip=lateral_Ftip{i}+repmat([mm3-lateral_Ftip{i}(:,end)'],size(lateral_Ftip{i},2),1)';
    plot3(smooth(tmp_lateral_Ftip(1,:),100,'lowess'),smooth(tmp_lateral_Ftip(2,:),100,'lowess'),smooth(tmp_lateral_Ftip(3,:),100,'lowess'),'g')
%     plot3(smooth(lateral_Ftip{i}(1,:),100,'lowess'),smooth(lateral_Ftip{i}(2,:),100,'lowess'),smooth(lateral_Ftip{i}(3,:),100,'lowess'),'g')
end
xlabel('$\xi_1 (cm)$','interpreter','latex','fontsize',15);
ylabel('$\xi_2 (cm)$','interpreter','latex','fontsize',15);
zlabel('$\xi_3 (cm)$','interpreter','latex','fontsize',15);
legend('precision','t2-fingers','lateral')


%%


% Pre-processing
dt =1/100; %The time step of the demonstrations
tol_cutting = 1; % A threshold on velocity that will be used for trimming demos

% Training parameters
K = 2; %Number of Gaussian funcitons

% A set of options that will be passed to the solver. Please type 
% 'doc preprocess_demos' in the MATLAB command window to get detailed
% information about other possible options.
options.tol_mat_bias = 10^-6; % A very small positive scalar to avoid
                              % instabilities in Gaussian kernel [default: 10^-15]
                              
options.display = 1;          % An option to control whether the algorithm
                              % displays the output of each iterations [default: true]
                              
options.tol_stopping=10^-10;  % A small positive scalar defining the stoppping
                              % tolerance for the optimization solver [default: 10^-10]

options.max_iter = 500;       % Maximum number of iteration for the solver [default: i_max=1000]

options.objective = 'mse';    % 'likelihood': use likelihood as criterion to
                              % optimize parameters of GMM
                              % 'mse': use mean square error as criterion to
                              % optimize parameters of GMM
                              % 'direction': minimize the angle between the
                              % estimations and demonstrations (the velocity part)
                              % to optimize parameters of GMM                              
                              % [default: 'mse']
%% Build DS for the elbow motion (master)


[x0 , xT, Data, index] = preprocess_demos(precision_elbow,dt,tol_cutting); %preprocessing datas
[Priors_0, Mu_0, Sigma_0] = initialize_SEDS(Data,K); %finding an initial guess for GMM's parameter
[Priors Mu Sigma]=SEDS_Solver(Priors_0,Mu_0,Sigma_0,Data,options); %running SEDS optimization solver
                              


%% Build DS for the grasp #1 (slave 1)

[x0_1 , xT_1, Data_1, index_1] = preprocess_demos(precision_Ftip,dt,tol_cutting); % preprocessing data
[Priors_0_1, Mu_0_1, Sigma_0_1] = initialize_SEDS(Data_1,K); %finding an initial guess for GMM's parameter
[Priors_1 Mu_1 Sigma_1]=SEDS_Solver(Priors_0_1,Mu_0_1,Sigma_0_1,Data_1,options); %running SEDS optimization solver


% Simulation

% A set of options that will be passed to the Simulator. Please type 
% 'doc preprocess_demos' in the MATLAB command window to get detailed
% information about each option.
opt_sim.dt = 0.1;
opt_sim.i_max = 3000;
opt_sim.tol = 0.1;
d = size(Data_1,1)/2; %dimension of data
x0_all = Data_1(1:d,index_1(1:end-1)); %finding initial points of all demonstrations
fn_handle = @(x) GMR(Priors_1,Mu_1,Sigma_1,x,1:d,d+1:2*d);
[x xd]=Simulation(x0_all,[],fn_handle,opt_sim); %running the simulator
                              

%% Build DS for the grasp #2 (slave 2)

[x0_2 , xT_2, Data_2, index_2] = preprocess_demos(t2_Ftip,dt,tol_cutting); % preprocessing data
[Priors_0_2, Mu_0_2, Sigma_0_2] = initialize_SEDS(Data_2,K); %finding an initial guess for GMM's parameter
[Priors_2 Mu_2 Sigma_2]=SEDS_Solver(Priors_0_2,Mu_0_2,Sigma_0_2,Data_2,options); %running SEDS optimization solver


% Simulation

% A set of options that will be passed to the Simulator. Please type 
% 'doc preprocess_demos' in the MATLAB command window to get detailed
% information about each option.
opt_sim.dt = 0.1;
opt_sim.i_max = 3000;
opt_sim.tol = 0.1;
d = size(Data_2,1)/2; %dimension of data
x0_all = Data_2(1:d,index_2(1:end-1)); %finding initial points of all demonstrations
fn_handle = @(x) GMR(Priors_2,Mu_2,Sigma_2,x,1:d,d+1:2*d);
[x xd]=Simulation(x0_all,[],fn_handle,opt_sim); %running the simulator

%% Build DS for the grasp #3 (slave 3)

[x0_3 , xT_3, Data_3, index_3] = preprocess_demos(lateral_Ftip,dt,tol_cutting); % preprocessing data
[Priors_0_3, Mu_0_3, Sigma_0_3] = initialize_SEDS(Data_3,K); %finding an initial guess for GMM's parameter
[Priors_3 Mu_3 Sigma_3]=SEDS_Solver(Priors_0_3,Mu_0_3,Sigma_0_3,Data_3,options); %running SEDS optimization solver


% Simulation

% A set of options that will be passed to the Simulator. Please type 
% 'doc preprocess_demos' in the MATLAB command window to get detailed
% information about each option.
opt_sim.dt = 0.1;
opt_sim.i_max = 3000;
opt_sim.tol = 0.1;
d = size(Data_3,1)/2; %dimension of data
x0_all = Data_3(1:d,index_3(1:end-1)); %finding initial points of all demonstrations
fn_handle = @(x) GMR(Priors_3,Mu_3,Sigma_3,x,1:d,d+1:2*d);
[x xd]=Simulation(x0_all,[],fn_handle,opt_sim); %running the simulator


%%
[area1,distance1]=preshape_criteria(sessions{1}.trials{1}.jointAngles,h,1);

a1=smooth(area1,100,'lowess');

d1=smooth(distance1,100,'lowess');


