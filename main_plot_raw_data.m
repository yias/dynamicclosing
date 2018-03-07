
% load('data/data09032017.mat')

graspTypes={'Pr','Tri','T2','T4','La'};

SR_mocap=250;
SR_emg=1500;

delay_TW=0.05;

l_TW=0.15;

velThreshold=0.2;

figure(3)
hold on


for i=4:length(sess)

    for j=6:length(sess{i}.trials)
        
        
        
        [motionOnset,motionEnd]=findMotionLimits(sess{i}.trials{j}.velocity_Aperture,SR_mocap,l_TW,l_TW-delay_TW,0.001,velThreshold);
        
%         motionOnset=1;
%         motionEnd=1000;
    
        subplot(5,1,1)
        plot(sess{i}.trials{j}.Aperture)
        grid on
        ylabel('Ap')
        title(['session ' num2str(i) ' trial ' num2str(j) ' grasptype ' graspTypes{sess{i}.trials{j}.grasp}])
        
        
        subplot(5,1,2)
        plot(sess{i}.trials{j}.velocity_Aperture)
        grid on
        ylabel('Ap vel')
%         vline([motionOnset,motionEnd],{'g','r'},{'onset','end'})
        
        subplot(5,1,3)
        plot(sess{i}.trials{j}.elbow_angle)
        grid on
        ylabel('elbow angle')
        
        
        velThreshold=2;
        [motionOnset,motionEnd]=findMotionLimits(sess{i}.trials{j}.elbow_angular_velocity,SR_mocap,l_TW,l_TW-delay_TW,0.001,velThreshold);
        
        
        subplot(5,1,4)
        plot(sess{i}.trials{j}.elbow_angular_velocity)
        hold on
        plot(smooth(sess{i}.trials{j}.elbow_angular_velocity,0.12,'loess'))
        grid on
        ylabel('elbow ang vel')
%         vline([motionOnset,motionEnd],{'g','r'},{'onset','end'})
        hold off
        
        subplot(5,1,5)
        plot(sess{i}.trials{j}.emg)
        grid on
        ylabel('emg')
%         vline([round(motionOnset*(SR_emg/SR_mocap)),round(motionEnd*(SR_emg/SR_mocap))],{'g','r'},{'onset','end'})
        hold off
        
    
    end


end