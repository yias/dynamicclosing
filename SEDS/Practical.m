%function [amlval,t] = Practical(K)
% This is a matlab script illustrating how to use SEDS_lib to learn
% an arbitrary model from a set of demonstrations.
tic;clear;close all;clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Copyright (c) 2010 S. Mohammad Khansari-Zadeh, LASA Lab, EPFL,   %%%
%%%          CH-1015 Lausanne, Switzerland, http://lasa.epfl.ch         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Raph & Roland Parameters
demoType = 'pick';         %Specifying the type of demonstrations. Its 
                           %value should either be 'pick' or 'place'
                           
K = 4;                     %Number of Gaussian functions

options.objective = 'mse'; %The criterion that optimization uses to train 
                           %the model. Possible values are:
                           % 'mse': use mean square error as criterion to optimize parameters of GMM
                           % 'likelihood': use mselikelihood as criterion to optimize parameters of GMM
                           
options.max_iter = 500;    %Maximum number of iterations. The optimization 
                           %exits if it does not converge within the specified iterations

%%
% To run this demo you need to provide the variable demos composed of all
% demosntration trajectories. To get more detailed information about the
% structure of the variable 'demo', type 'doc preprocess_demos' in the
% MATLAB command window

if isempty(regexp(path,['SEDS_lib' pathsep], 'once'))
    addpath([pwd, '/SEDS_lib']);    % add SEDS dir to path
end
if isempty(regexp(path,['GMR_lib' pathsep], 'once'))
    addpath([pwd, '/GMR_lib']);    % add GMR dir to path
end

PracticalRootPath = '/home/katana/catkin_ws/PracticalsData';
dt = 0.25; % time step of demonstration

%% Load the demonstrations
%  - load all the txt file in the trajectory directory 
%  - shift the all the trajectory to be finish in the same point (0,0,0)
%  - save the demonstrations in the demo variable

MotionDir = [PracticalRootPath '/trj/'];
Listing = dir([MotionDir demoType '*.txt']);

nbDemo = length(Listing);

for i=1:nbDemo
    data{i} = load([MotionDir Listing(i).name]);
    demos{i} = data{i}(:, 1:3)';
    
    demos{i}(:,1) = demos{i}(:, 1) - demos{i}(end,1);
    demos{i}(:,2) = demos{i}(:, 2) - demos{i}(end,2);
    demos{i}(:,3) = demos{i}(:, 3) - demos{i}(end,3);
end;


%% Cross validation
% - devide the demonstrations into N subfolds
% - 

b_testDataset=0;

if b_testDataset && nbDemo > 2
    ind = randperm(nbDemo);
    demos_test = demos(ind(1:2));
    demos_training = demos(ind(3:end));
else
    demos_training = demos;
    demos_test = demos;
end


%% SEDS learning algorithm

tol_cutting = 0.001; 

% a threshold on velocity that will be used for trimming demos
% To get more detailed information type 'doc preprocess_demos'
% in the MATLAB command window

[x0 , xT, Data, index] = preprocess_demos(demos_training,dt,tol_cutting); %preprocessing datas

% A set of options that will be passed to the solver. Please type 
% 'doc preprocess_demos' in the MATLAB command window to get detailed
% information about each option.
options.tol_mat_bias = 10^-6;
options.perior_opt = 1;
options.mu_opt = 1;
options.sigma_x_opt = 1;
options.display = 1;
options.tol_stopping=10^-10;
options.normalization = 1;

[Priors_0, Mu_0, Sigma_0] = initialize_SEDS(Data,K); %finding an initial guess for GMM's parameter
[Priors Mu Sigma amlval]=SEDS_Solver(Priors_0,Mu_0,Sigma_0,Data,options); %running SEDS optimization solver

structGMM.Mu = Mu;
structGMM.Priors = Priors;
structGMM.Sigma = Sigma;

% save the result

%save([PracticalRootPath '/data/model/pick_GMM.mat'], structGMM );
SaveGMM(structGMM, [PracticalRootPath '/model/'], demoType);

%% Simulation

% A set of options that will be passed to the Simulator. Please type 
% 'doc preprocess_demos' in the MATLAB command window to get detailed
% information about each option.
opt_sim.dt = 0.25;
opt_sim.i_max = 3000;
opt_sim.tol = 0.001;
d = size(Data,1)/2; %dimension of data
x0_all = Data(1:d,index(1:end-1)); %finding initial points of all demonstrations
fn_handle = @(x) GMR(Priors,Mu,Sigma,x,1:d,d+1:2*d);
[x xd]=Simulation(x0_all,[],fn_handle,opt_sim); %running the simulator


%%
% plotting the result
D = axis(gca);
figure('name','Results from Simulation','position',[265   200   520   720])
sp(1)=subplot(3,1,1);
hold on; box on
plotGMM(Mu(1:2,:), Sigma(1:2,1:2,:), [0.6 1.0 0.6], 1,[0.6 1.0 0.6]);
plot(Data(1,:),Data(2,:),'r.')
xlabel('$\xi_1 (mm)$','interpreter','latex','fontsize',15);
ylabel('$\xi_2 (mm)$','interpreter','latex','fontsize',15);
title('Simulation Results')

sp(2)=subplot(3,1,2);
hold on; box on
plotGMM(Mu([1 3],:), Sigma([1 3],[1 3],:), [0.6 1.0 0.6], 1,[0.6 1.0 0.6]);
plot(Data(1,:),Data(3,:),'r.')
xlabel('$\xi_1 (mm)$','interpreter','latex','fontsize',15);
ylabel('$\dot{\xi}_1 (mm/s)$','interpreter','latex','fontsize',15);

sp(3)=subplot(3,1,3);
hold on; box on
plotGMM(Mu([2 4],:), Sigma([2 4],[2 4],:), [0.6 1.0 0.6], 1,[0.6 1.0 0.6]);
plot(Data(2,:),Data(4,:),'r.')
xlabel('$\xi_2 (mm)$','interpreter','latex','fontsize',15);
ylabel('$\dot{\xi}_2 (mm/s)$','interpreter','latex','fontsize',15);

for i=1:size(x,3)
    plot(sp(1),x(1,:,i),x(2,:,i),'linewidth',2)
    plot(sp(2),x(1,:,i),xd(1,:,i),'linewidth',2)
    plot(sp(3),x(2,:,i),xd(2,:,i),'linewidth',2)
    plot(sp(1),x(1,1,i),x(2,1,i),'ok','markersize',5,'linewidth',5)
    plot(sp(2),x(1,1,i),xd(1,1,i),'ok','markersize',5,'linewidth',5)
    plot(sp(3),x(2,1,i),xd(2,1,i),'ok','markersize',5,'linewidth',5)
end

for i=1:3
    axis(sp(i),'tight')
    ax=get(sp(i));
    axis(sp(i),...
        [ax.XLim(1)-(ax.XLim(2)-ax.XLim(1))/10 ax.XLim(2)+(ax.XLim(2)-ax.XLim(1))/10 ...
        ax.YLim(1)-(ax.YLim(2)-ax.YLim(1))/10 ax.YLim(2)+(ax.YLim(2)-ax.YLim(1))/10]);
    plot(sp(i),0,0,'k*','markersize',15,'linewidth',3)
end

% plotting streamlines
figure('name','Streamlines','position',[800   90   560   320])
plotStreamLines(Priors,Mu,Sigma,D)
hold on
plot(Data(1,:),Data(2,:),'r.')
plot(0,0,'k*','markersize',15,'linewidth',3)
xlabel('$\xi_1 (mm)$','interpreter','latex','fontsize',15);
ylabel('$\xi_2 (mm)$','interpreter','latex','fontsize',15);
title('Streamlines of the model')
set(gca,'position',[0.1300    0.1444    0.7750    0.7619])

amlval = amlval(end);
t=toc

%end