    data{1} = load('trjcart_pick.txt');
    demos{1} = data{1}(:, 1:3)';
    
    demos{1}(:,1) = demos{1}(:, 1) - demos{1}(end,1);
    demos{1}(:,2) = demos{1}(:, 2) - demos{1}(end,2);
    demos{1}(:,3) = demos{1}(:, 3) - demos{1}(end,3);





% %% Simulation
% 
% % A set of options that will be passed to the Simulator. Please type 
% % 'doc preprocess_demos' in the MATLAB command window to get detailed
% % information about each option.
% opt_sim.dt = 0.25;
% opt_sim.i_max = 3000;
% opt_sim.tol = 0.001;
% d = size(Data,1)/2; %dimension of data
% x0_all = Data(1:d,index(1:end-1)); %finding initial points of all demonstrations
% fn_handle = @(x) GMR(Priors,Mu,Sigma,x,1:d,d+1:2*d);
% [x xd]=Simulation(x0_all,[],fn_handle,opt_sim); %running the simulator