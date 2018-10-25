clc
close all
clear
%function [amlval,t] = Practical(K)
% This is a matlab script illustrating how to use SEDS_lib to learn
% an arbitrary model from a set of demonstrations.
tic;clear;close all;clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Copyright (c) 2010 S. Mohammad Khansari-Zadeh, LASA Lab, EPFL,   %%%
%%%          CH-1015 Lausanne, Switzerland, http://lasa.epfl.ch         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Raph & Roland Parameters
demoType = 'place';         %Specifying the type of demonstrations. Its 
                           %value should either be 'pick' or 'place'
                           
Priors=load('/home/lasa-katana/fuerte_workspace/roscodes/PracticalCodes/data/model/place_prio.txt');
Mu=load('/home/lasa-katana/fuerte_workspace/roscodes/PracticalCodes/data/model/place_mu.txt');
Sigma_handle=load('/home/lasa-katana/fuerte_workspace/roscodes/PracticalCodes/data/model/place_sigma.txt');
Size=size(Priors,2);
for i=1:Size
Sigma(:,:,i)=Sigma_handle(6*(i-1)+1:6*(i),:);
end

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

PracticalRootPath = getenv('PRACTICAL');
dt = 0.25; % time step of demonstration

%% Load the demonstrations
%  - load all the txt file in the trajectory directory 
%  - shift the all the trajectory to be finish in the same point (0,0,0)
%  - save the demonstrations in the demo variable

MotionDir = [PracticalRootPath '/data/trj/'];
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
hold on 
plot3(Data(1,:),Data(2,:),Data(3,:),'Marker','.','LineStyle','none','Color',[1 0 0],...
    'DisplayName','The Real Data')


t=toc

%end