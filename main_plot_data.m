

 load('data/CouplingData.mat')
 
 
 graspTypes={'Pr','Tri','T2','T4','La'};
 
 figure(1)
 hold on
 
 for i=1:length(emgDD)
     
     subplot(3,2,1)
     plot(emgDD{i}.FTipsArea)
     title(['grasptype ' graspTypes{emgDD{i}.grasp}])
     ylabel('Area')
     grid on
     
     subplot(3,2,3)
     plot(emgDD{i}.Aperture)
     ylabel('Apertre')
     grid on
     
     subplot(3,2,5)
     plot(emgDD{i}.elbow_angle)
     ylabel('Elbow angle ')
     grid on
     
     subplot(3,2,2)
     plot(emgDD{i}.velocity_Area)
     ylabel('Vel Area')
     grid on
     
     subplot(3,2,4)
     plot(emgDD{i}.velocity_Aperture)
     ylabel('Vel Aperture')
     grid on
     
     subplot(3,2,6)
     plot(emgDD{i}.elbow_angular_velocity)
     ylabel('Elbow Vel ')
     grid on
     
     pause;
     
     
 end