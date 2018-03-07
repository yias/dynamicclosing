

for i=3:length(dataTrials)
    

%     for j=1:length(sess{i}.trials)

        a=smooth(dataTrials{i}.velocity_Aperture(1:600),10,'loess');
        a1=smooth(dataTrials{i}.velocity_Aperture(1:600),200,'loess');
        b=smooth(dataTrials{i}.elbow_angular_velocity(1:600),10,'loess');
%         ap=smooth(dataTrials{i}.Aperture(1:600),100,'loess');
    
        figure(36)
        hold on
        plot(a/max(a))
        plot(a1/max(a1))
        plot(b/max(b))
%         plot(ap/max(ap))
        
%         legend('vel_ap','vel_ap(smoothed)','elbow vel(smoothed)','aperture')
        hold off
        i
        close all
%     end
    
    
end

