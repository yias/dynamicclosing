%%
%% load subject parameters
%%

subject_name='lucia'; thumb_model='rpij'; visualization='importancebar'; setupHand


%%
%% setting up the parameters
%%

% joint angles needed from the glove

JA_keep=[3,6,5,7,8,10,11,12,14,15,16,18,19];

% calibration should be completely within the specialized hand.
calibration_directory = ['data/calibration/' calibration];

% recorded maximum and minimum joint angles
min_file_path = [calibration_directory '/min_glove_values'];
load(min_file_path)
max_file_path = [calibration_directory '/max_glove_values'];
load(max_file_path)
calib_file_path = [calibration_directory '/thumb_calibration_' thumb_model];

% calibrate max/min values (from raw values to radians)

gloveUpperLimits=getCalibratedHandAngles(max_glove_values, calib_file_path, min_file_path, max_file_path);
gloveUpperLimits=gloveUpperLimits(JA_keep);

gloveLowerLimits=getCalibratedHandAngles(min_glove_values, calib_file_path, min_file_path, max_file_path);
gloveLowerLimits=gloveLowerLimits(JA_keep);

% set glove limits
gloveLimits=[gloveUpperLimits;gloveLowerLimits];

% allegro hand joint limits

% index, middle and ring fingers
FingersJointLimits=[0.57181227113054078, 1.7367399715833842, 1.8098808147084331, 1.71854352396125431;...        % upper limit
                     -0.59471316618668479, -0.29691276729768068, -0.27401187224153672, -0.32753605719833834];   % lower limit
                 
% removing the rotation on the MCP joint
FingersJointLimits=[FingersJointLimits(1,2:end);FingersJointLimits(2,2:end)];
                 
% thumb
ThumbJointLimits=[1.4968131524486665, 1.2630997544532125, 1.7440185506322363, 1.8199110516903878;...            
                  0.3635738998060688, -0.20504289759570773, -0.28972295140796106, -0.26220637207693537];
              

% gouping the fingers all together
AllegroJointLimits=[ThumbJointLimits,FingersJointLimits,FingersJointLimits,FingersJointLimits];



%%
%% create dataset
%%

powerGrasp=struct([]);
tripod=struct([]);
t2f=struct([]);
t4f=struct([]);
lateral=struct([]);

powerGrasp_tmp=struct([]);
tripod_tmp=struct([]);
t2f_tmp=struct([]);
t4f_tmp=struct([]);
lateral_tmp=struct([]);

load('data/organizedData_16042017.mat')

pcaSet=[];
 
for tr=1:length(dataTrials)
    
    switch dataTrials{tr}.grasp
        case 1
            
           powerGrasp_tmp{length(powerGrasp_tmp)+1}=dataTrials{tr}.jointAngles(dataTrials{tr}.reaching_motion_onset:dataTrials{tr}.reaching_motion_end,:);
           powerGrasp{length(powerGrasp)+1}=dataTrials{tr}.jointAngles(dataTrials{tr}.reaching_motion_onset:dataTrials{tr}.reaching_motion_end,JA_keep)';
%            size(powerGrasp{end},1)
%            disp(length(powerGrasp))
           for i=1:size(powerGrasp{end},1)
               
                powerGrasp{end}(i,:)=smooth(powerGrasp{end}(i,:),12,'lowess');
           end
           pcaSet=[pcaSet,powerGrasp{end}];
        case 2
           tripod_tmp{length(tripod_tmp)+1}=dataTrials{tr}.jointAngles(dataTrials{tr}.reaching_motion_onset:dataTrials{tr}.reaching_motion_end,:);
           tripod{length(tripod)+1}=dataTrials{tr}.jointAngles(dataTrials{tr}.reaching_motion_onset:dataTrials{tr}.reaching_motion_end,JA_keep)';
%            disp(length(tripod))
%            size(tripod{end},1)
           for i=1:size(tripod{end},1)
                tripod{end}(i,:)=smooth(tripod{end}(i,:),12,'lowess');
           end
           pcaSet=[pcaSet,tripod{end}];
        case 3
           t2f_tmp{length(t2f_tmp)+1}=dataTrials{tr}.jointAngles(dataTrials{tr}.reaching_motion_onset:dataTrials{tr}.reaching_motion_end,:);
           t2f{length(t2f)+1}=dataTrials{tr}.jointAngles(dataTrials{tr}.reaching_motion_onset:dataTrials{tr}.reaching_motion_end,JA_keep)';
           for i=1:size(t2f{end},1)
                t2f{end}(i,:)=smooth(t2f{end}(i,:),12,'lowess');
           end
           pcaSet=[pcaSet,t2f{end}];
        case 4
           t4f_tmp{length(t4f_tmp)+1}=dataTrials{tr}.jointAngles(dataTrials{tr}.reaching_motion_onset:dataTrials{tr}.reaching_motion_end,:); 
           t4f{length(t4f)+1}=dataTrials{tr}.jointAngles(dataTrials{tr}.reaching_motion_onset:dataTrials{tr}.reaching_motion_end,JA_keep)'; 
           for i=1:size(t4f{end},1)
                t4f{end}(i,:)=smooth(t4f{end}(i,:),12,'lowess');
           end
           pcaSet=[pcaSet,t4f{end}];
        case 5
           lateral_tmp{length(lateral_tmp)+1}=dataTrials{tr}.jointAngles(dataTrials{tr}.reaching_motion_onset:dataTrials{tr}.reaching_motion_end,:);
           lateral{length(lateral)+1}=dataTrials{tr}.jointAngles(dataTrials{tr}.reaching_motion_onset:dataTrials{tr}.reaching_motion_end,JA_keep)';
           for i=1:size(lateral{end},1)
                lateral{end}(i,:)=smooth(lateral{end}(i,:),12,'lowess');
           end
           pcaSet=[pcaSet,lateral{end}];
        otherwise
           disp(['trial' num2str(tr) ': grasp type not defined'])
    end
            
end


%%
[coeff,score,latent] = pca(pcaSet');
% 
% [coeff,score,latent] = mypca2(pcaSet');

globalMeans=mean(pcaSet,2)';

% number of components to keep
nbComp=3;

% plots of the power (sparsity) over principal components and the
% distribution of the data in the new hyperplane
plotPowerCurve(latent,score,nbComp)

cntrdImgMatrix=pcaSet'-repmat(mean((pcaSet'),1),size((pcaSet'),1),1);

% sum(score-cntrdImgMatrix*coeff)

[pwr_coord,pwr_std]=projectedMean(powerGrasp,coeff,globalMeans,nbComp);

[t2f_coord,t2f_std]=projectedMean(t2f,coeff,globalMeans,nbComp);

[lateral_coord,lateral_std]=projectedMean(lateral,coeff,globalMeans,nbComp);

[t4f_coord,t4f_std]=projectedMean(t4f,coeff,globalMeans,nbComp);

[tri_coor,tri_std]=projectedMean(tripod,coeff,globalMeans,nbComp);


figure

scatter3(pwr_coord(1),pwr_coord(2),pwr_coord(3),1000*max(pwr_std),1,'filled','MarkerEdgeColor','r','MarkerFaceColor','r')
hold on
scatter3(t2f_coord(1),t2f_coord(2),t2f_coord(3),1000*max(t2f_std),1,'filled','MarkerEdgeColor','b','MarkerFaceColor','b')
scatter3(lateral_coord(1),lateral_coord(2),lateral_coord(3),1000*max(lateral_std),1,'filled','MarkerEdgeColor','g','MarkerFaceColor','g')
scatter3(t4f_coord(1),t4f_coord(2),t4f_coord(3),1000*max(t4f_std),1,'filled','MarkerEdgeColor','k','MarkerFaceColor','k')
scatter3(tri_coor(1),tri_coor(2),tri_coor(3),1000*max(tri_std),1,'filled','MarkerEdgeColor','m','MarkerFaceColor','m')


pwrData=projection2pc(powerGrasp,coeff,globalMeans,nbComp);
for tr=1:length(pwrData)
    scatter3(pwrData{tr}(1,end),pwrData{tr}(2,end),pwrData{tr}(3,end),100,1,'*','r')
    plot3(pwrData{tr}(1,:),pwrData{tr}(2,:),pwrData{tr}(3,:),'-.k','LineWidth',2)
    
end

xlabel('PC1')
ylabel('PC2')
zlabel('PC3')
legend('power grasp','t2f','lateral','t4f','tripod')

% ss=scatter3(score(imgs_id==i,1),score(imgs_id==i,2),score(imgs_id==i,3),100,ones(length(find(imgs_id==i)),1)*i,'MarkerEdgeColor',clr(i,:),'Marker','*');
% ssMeans{i}=scatter3(class_proj_means(i,1),class_proj_means(i,2),class_proj_means(i,3),300,i,'MarkerEdgeColor',clr(i,:),'Marker','o');
% ss{i}.MarkerEdgeColor = clr(i,:);
% ssMeans{i}.MarkerEdgeColor = clr(i,:);


%%
%% mapping with allegro hand (project to Allegro hand's joint angles)
%%

% power grasp
powerGraspAllegro=allegroHandMapping(powerGrasp,gloveLimits,AllegroJointLimits);

% tripod 
tripodAllegro=allegroHandMapping(tripod,gloveLimits,AllegroJointLimits);

% t2f
t2fAllegro=allegroHandMapping(t2f,gloveLimits,AllegroJointLimits);

% t4f
t4fAllegro=allegroHandMapping(t4f,gloveLimits,AllegroJointLimits);

% lateral
lateralAllegro=allegroHandMapping(lateral,gloveLimits,AllegroJointLimits);


%%
%% visualize fingers motion
%%



% display the hand
h.refresh(0,1);
view(-28,40);
trial_nb=4;

% display each joint angle
for ji=1:size(lateral_tmp{trial_nb},1)
    j = lateral_tmp{trial_nb}(ji,:);
    j(1)=-0.8;
%     j([3 4]) = j([3 4]) + deg2rad([-10 20]);
    
%     h.Q = tripod_tmp{trial_nb}(ji,:);    
    h.Q =j;    
    h.refresh(0,1);    
    
    pause(0.0001);
end




%%
%%  build SEDS 
%%


% Training parameters

dt=0.004;

tol_cutting = 1; % A threshold on velocity that will be used for trimming demos

options.tol_mat_bias = 10^-6; 
                              
options.display = 1;         
                              
options.tol_stopping=10^-10;  

options.max_iter = 1000;       

options.objective = 'mse';  



%% power grasp

K = 3; %Number of Gaussian funcitons

pwrData=projection2pc(powerGraspAllegro(5:12),coeff,globalMeans,nbComp);

demosSet_Indx=[1:18,20,23,23];
ri=random_numbers(length(demosSet_Indx),1,12);
demosTrainSet_Indx=demosSet_Indx(ri);
demosTestSet_Indx=demosSet_Indx;
demosTestSet_Indx(ri)=[];

% [x0 , xT, Data, index] = preprocess_demos(powerGraspAllegro,dt,0.000001);
[x0 , xT, Data, index] = preprocess_demos(pwrData,dt,0.000001);
[Priors_0, Mu_0, Sigma_0] = initialize_SEDS(Data,K); %finding an initial guess for GMM's parameter

%% plot the initial fitting
figure('name','prior Gaussians, dim 1-2')
hold on
plotGMM(Mu_0(1:2,:), Sigma_0(1:2,1:2,:), [1.0 0.0 0.6], 1);
hold on
plot(Data(1,:),Data(2,:),'k--')
xlabel('$\xi_1 (mm)$','interpreter','latex','fontsize',15);
ylabel('$\xi_2 (mm)$','interpreter','latex','fontsize',15);
title('prior fitting')
figure('name','Gaussians, dim 2-3')
hold on
plotGMM(Mu_0(2:3,:), Sigma_0(2:3,2:3,:), [1.0 0.0 0.6], 1);
plot(Data(2,:),Data(3,:),'k--')
xlabel('$\xi_2 (mm)$','interpreter','latex','fontsize',15);
ylabel('$\xi_3 (mm)$','interpreter','latex','fontsize',15);
title('prior fitting')

%% 3D plotting the initial fitting

figure('name','prior Gaussians, dim 1-2')
hold on
plot_3D_GMM(Mu_0(1:3,:),Sigma_0(1:3,1:3,:),1)
hold on
plot3(Data(1,:),Data(2,:),Data(3,:),'k','LineStyle','-','LineWidth',3)
grid on
%% train SEDS


[Priors Mu Sigma]=SEDS_Solver(Priors_0,Mu_0,Sigma_0,Data,options); %running SEDS optimization solver
%% Simulation of the model
opt_sim.dt = 0.1;
opt_sim.i_max = 3000;
opt_sim.tol = 0.1;

d = size(Data,1)/2; %dimension of data
x0_all = Data(1:d,index(1:end-1)); %finding initial points of all demonstrations

fn_handle = @(x) GMR(Priors,Mu,Sigma,x,1:d,d+1:2*d);
[x xd,~,~,~, sp]=Simulation(x0_all,[],fn_handle,opt_sim); %running the simulator
sp=plotDemonstrations_Data(Data,x0_all,index,sp);

%% 2D plot
dd_toPlot=[1,3];
ds_plot_options = [];
ds_plot_options.sim_traj  = 1;                      % To simulate trajectories from x0_all
ds_plot_options.x0_all    = x0_all(dd_toPlot,:);    % Intial Points
ds_plot_options.init_type = 'ellipsoid';            % For 3D DS, to initialize streamlines
                                                    % 'ellipsoid' or 'cube'  
ds_plot_options.nb_points = 30;                     % No of streamlines to plot (3D)
ds_plot_options.plot_vol  = 1;                      % Plot volume of initial points (3D)

t_Sigma=zeros(2*length(dd_toPlot),2*length(dd_toPlot),K);
t_Sigma(:,:,1)=[Sigma(dd_toPlot,dd_toPlot,1),Sigma(dd_toPlot,d+dd_toPlot,1);Sigma(d+dd_toPlot,dd_toPlot,1),Sigma(d+dd_toPlot,d+dd_toPlot,1)];
t_Sigma(:,:,2)=[Sigma(dd_toPlot,dd_toPlot,2),Sigma(dd_toPlot,d+dd_toPlot,2);Sigma(d+dd_toPlot,dd_toPlot,2),Sigma(d+dd_toPlot,d+dd_toPlot,2)];
t_Sigma(:,:,3)=[Sigma(dd_toPlot,dd_toPlot,3),Sigma(dd_toPlot,d+dd_toPlot,3);Sigma(d+dd_toPlot,dd_toPlot,3),Sigma(d+dd_toPlot,d+dd_toPlot,3)];

fn_handle = @(x) GMR(Priors,[Mu(dd_toPlot,:);Mu(d+dd_toPlot,:)],t_Sigma,x,1:length(dd_toPlot),length(dd_toPlot)+1:2*length(dd_toPlot));
[hd, hs, hr, x_sim] = visualizeEstimatedDS(Data(dd_toPlot,:), fn_handle, ds_plot_options);

%% 3D plot

ds_plot_options = [];
ds_plot_options.sim_traj  = 1;                      % To simulate trajectories from x0_all
ds_plot_options.x0_all    = x0_all;                 % Intial Points
ds_plot_options.init_type = 'ellipsoid';            % For 3D DS, to initialize streamlines
                                                    % 'ellipsoid' or 'cube'  
ds_plot_options.nb_points = 30;                     % No of streamlines to plot (3D)
ds_plot_options.plot_vol  = 1;                      % Plot volume of initial points (3D)

fn_handle = @(x) GMR(Priors,Mu,Sigma,x,1:d,d+1:2*d);
[hd, hs, hr, x_sim] = visualizeEstimatedDS(Data(1:d,:), fn_handle, ds_plot_options);
%%

figure('name','Gaussians, dim 1-2')
hold on
plotGMM(Mu(1:2,:), Sigma(1:2,1:2,:), [1.0 0.0 0.6], 2);
hold on
plot(Data(1,:),Data(2,:),'k--')
xlabel('$\xi_1 (mm)$','interpreter','latex','fontsize',15);
ylabel('$\xi_2 (mm)$','interpreter','latex','fontsize',15);
title('Simulation Results')
figure('name','Gaussians, dim 2-3')
hold on
plotGMM(Mu(2:3,:), Sigma(2:3,2:3,:), [1.0 0.0 0.6], 2);
plot(Data(2,:),Data(3,:),'k--')
xlabel('$\xi_2 (mm)$','interpreter','latex','fontsize',15);
ylabel('$\xi_3 (mm)$','interpreter','latex','fontsize',15);
title('Simulation Results')

%% 3D plotting the final fitting after SEDS

figure('name','SEDS Gaussians 3D')
hold on
plot_3D_GMM(Mu(1:3,:),Sigma(1:3,1:3,:),1)
hold on
plot3(Data(1,:),Data(2,:),Data(3,:),'k','LineStyle','-','LineWidth',3)
grid on



%%
M = size(Data,1)/2; 
ds_seds = @(x) GMR_SEDS(Priors,Mu,Sigma,x-repmat(att,[1 size(x,2)]),1:M,M+1:2*M);
%%

structGMM.Mu = Mu;
structGMM.Priors = Priors;
structGMM.Sigma = Sigma;
%%

SaveGMM(structGMM, './graspSEDSModels/', 'powerGrasp20181011');

out = export2SEDS_Cpp_lib('./graspSEDSModels/powerGrasp20181011.txt',Priors, Mu, Sigma);

%% t2f

options.tol_stopping=10^-10;  

options.max_iter = 500;       

options.objective = 'mse';  

K = 4; %Number of Gaussian funcitons

% t2fData=projection2pc(t2fAllegro(5:12),coeff,globalMeans,nbComp);

[x0 , xT, Data, index] = preprocess_demos(tripodAllegro,dt,0.000001);

[Priors_0, Mu_0, Sigma_0] = initialize_SEDS(Data,K); %finding an initial guess for GMM's parameter
[Priors Mu Sigma]=SEDS_Solver(Priors_0,Mu_0,Sigma_0,Data,options); %running SEDS optimization solver


opt_sim.dt = 0.1;
opt_sim.i_max = 3000;
opt_sim.tol = 0.1;

d = size(Data,1)/2; %dimension of data
x0_all = Data(1:d,index(1:end-1)); %finding initial points of all demonstrations
fn_handle = @(x) GMR(Priors,Mu,Sigma,x,1:d,d+1:2*d);
% [x xd]=Simulation(x0_all,[],fn_handle,opt_sim); %running the simulator

[x xd,~,~,~, sp]=Simulation(x0_all,[],fn_handle,opt_sim); %running the simulator
sp=plotDemonstrations_Data(Data,x0_all,index,sp)

structGMM.Mu = Mu;
structGMM.Priors = Priors;
structGMM.Sigma = Sigma;

SaveGMM(structGMM, './graspSEDSModels/', 't2f220181011');

out = export2SEDS_Cpp_lib('./graspSEDSModels/t2f20181011.txt',Priors, Mu, Sigma);

%% lateral

% lateralData=projection2pc(lateralAllegro(5:12),coeff,globalMeans,nbComp);

[x0 , xT, Data, index] = preprocess_demos(lateralAllegro,dt,0.000001);

[Priors_0, Mu_0, Sigma_0] = initialize_SEDS(Data,K); %finding an initial guess for GMM's parameter
[Priors Mu Sigma]=SEDS_Solver(Priors_0,Mu_0,Sigma_0,Data,options); %running SEDS optimization solver

%%
opt_sim.dt = 0.1;
opt_sim.i_max = 3000;
opt_sim.tol = 0.1;

d = size(Data,1)/2; %dimension of data
x0_all = Data(1:d,index(1:end-1)); %finding initial points of all demonstrations
fn_handle = @(x) GMR(Priors,Mu,Sigma,x,1:d,d+1:2*d);
[x xd,~,~,~, sp]=Simulation(x0_all,[],fn_handle,opt_sim); %running the simulator
sp=plotDemonstrations_Data(Data,x0_all,index,sp);

%%
structGMM.Mu = Mu;
structGMM.Priors = Priors;
structGMM.Sigma = Sigma;

SaveGMM(structGMM, './graspSEDSModels/', 'latera20181011l');

out = export2SEDS_Cpp_lib('./graspSEDSModels/lateral20181011.txt',Priors, Mu, Sigma);

%%




[area1,distance1]=preshape_criteria(sessions{1}.trials{1}.jointAngles,h,1);

a1=smooth(area1,100,'lowess');

d1=smooth(distance1,100,'lowess');



