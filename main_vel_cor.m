
GTypesDatata=struct([]);
GTypesDatata{1}=[];
GTypesDatata{2}=[];
GTypesDatata{3}=[];
GTypesDatata{4}=[];
GTypesDatata{5}=[];

OrientationData=struct([]);
OrientationData{1}=[];
OrientationData{2}=[];
OrientationData{3}=[];

PositionData=struct([]);
PositionData{1}=[];
PositionData{2}=[];
PositionData{3}=[];

for i=1:length(dataTrials)
    
    t1=max(abs(dataTrials{i}.velocity_Aperture(dataTrials{i}.reaching_motion_onset:dataTrials{i}.reaching_motion_end)));
    
    t2=max(abs(dataTrials{i}.Aperture(dataTrials{i}.reaching_motion_onset:dataTrials{i}.reaching_motion_end)));
    
    t3=max(abs(dataTrials{i}.elbow_angular_velocity(dataTrials{i}.reaching_motion_onset:dataTrials{i}.reaching_motion_end)));
    
    GTypesDatata{dataTrials{i}.grasp}=[GTypesDatata{dataTrials{i}.grasp};[t1,t2,t3]];
    
    OrientationData{dataTrials{i}.orientation}=[OrientationData{dataTrials{i}.orientation};[t1,t2,t3]];
    
    PositionData{dataTrials{i}.position}=[PositionData{dataTrials{i}.position};[t1,t2,t3]];
    
    
end

figure(1)
subplot(3,2,1)
scatter(GTypesDatata{1}(:,1),GTypesDatata{1}(:,3),'Marker','s','SizeData',200,'MarkerFaceColor',[0.749,0.749,0])
% hold on
% scatter(GTypesDatata{2}(:,1),GTypesDatata{2}(:,3))
% scatter(GTypesDatata{3}(:,1),GTypesDatata{3}(:,3))
% scatter(GTypesDatata{4}(:,1),GTypesDatata{4}(:,3))
% scatter(GTypesDatata{5}(:,1),GTypesDatata{5}(:,3))

X = [ones(length(GTypesDatata{1}(:,1)),1) GTypesDatata{1}(:,1)];
b1 = X\GTypesDatata{1}(:,3);
yCalc1 = X*b1;
p = polyfit(GTypesDatata{1}(:,1),GTypesDatata{1}(:,3),2);
yfit2=polyval(p,GTypesDatata{1}(:,1));

Rsq1 = 1 - sum((GTypesDatata{1}(:,3)-yCalc1).^2)/sum((GTypesDatata{1}(:,3) - mean(GTypesDatata{1}(:,3))).^2)
hold on
plot(GTypesDatata{1}(:,1),yCalc1,'LineWidth',5,'Color','b')
plot(GTypesDatata{1}(:,1),yfit2,'LineWidth',5,'Color','r')
xlabel('Aperture Velocity [cm/s]')
ylabel('elbow angular vel [degrees/s]')
title('Precision')
grid on


% figure(2)
subplot(3,2,2)
scatter(GTypesDatata{1}(:,2),GTypesDatata{1}(:,3),'Marker','s','SizeData',200,'MarkerFaceColor',[0.749,0.749,0])
% hold on
% scatter(GTypesDatata{2}(:,2),GTypesDatata{2}(:,3))
% scatter(GTypesDatata{3}(:,2),GTypesDatata{3}(:,3))
% scatter(GTypesDatata{4}(:,2),GTypesDatata{4}(:,3))
% scatter(GTypesDatata{5}(:,2),GTypesDatata{5}(:,3))

X = [ones(length(GTypesDatata{1}(:,2)),1) GTypesDatata{1}(:,2)];
b1 = X\GTypesDatata{1}(:,3);
yCalc1 = X*b1;
Rsq2 = 1 - sum((GTypesDatata{1}(:,3)-yCalc1).^2)/sum((GTypesDatata{1}(:,3) - mean(GTypesDatata{1}(:,3))).^2)
hold on
plot(GTypesDatata{1}(:,2),yCalc1,'b','LineWidth',5)
xlabel('Aperture [cm]')
ylabel('elbow angular vel[degrees/s]')
title('Precision')
grid on

subplot(3,2,3)
scatter(GTypesDatata{2}(:,1),GTypesDatata{2}(:,3),'SizeData',200,'MarkerFaceColor',[0,0.447,0.741])

X = [ones(length(GTypesDatata{2}(:,1)),1) GTypesDatata{2}(:,1)];
b1 = X\GTypesDatata{2}(:,3);
yCalc1 = X*b1;
Rsq2 = 1 - sum((GTypesDatata{2}(:,3)-yCalc1).^2)/sum((GTypesDatata{2}(:,3) - mean(GTypesDatata{2}(:,3))).^2)
hold on
plot(GTypesDatata{2}(:,1),yCalc1,'b','LineWidth',5)
xlabel('Aperture Velocity [cm/s]')
ylabel('elbow angular vel [degrees/s]')
title('tripod')
grid on


subplot(3,2,4)
scatter(GTypesDatata{2}(:,2),GTypesDatata{2}(:,3),'SizeData',200,'MarkerFaceColor',[0,0.447,0.741])

X = [ones(length(GTypesDatata{2}(:,2)),1) GTypesDatata{2}(:,2)];
b1 = X\GTypesDatata{2}(:,3);
yCalc1 = X*b1;
Rsq2 = 1 - sum((GTypesDatata{2}(:,3)-yCalc1).^2)/sum((GTypesDatata{2}(:,3) - mean(GTypesDatata{2}(:,3))).^2)
hold on
plot(GTypesDatata{2}(:,2),yCalc1,'b','LineWidth',5)
xlabel('Aperture [cm]')
ylabel('elbow angular vel[degrees/s]')
title('tripod')
grid on

subplot(3,2,5)
scatter(GTypesDatata{3}(:,1),GTypesDatata{3}(:,3),'SizeData',200,'MarkerFaceColor',[0.467,0.675,0.188])

X = [ones(length(GTypesDatata{3}(:,1)),1) GTypesDatata{3}(:,1)];
b1 = X\GTypesDatata{3}(:,3);
yCalc1 = X*b1;
Rsq2 = 1 - sum((GTypesDatata{3}(:,3)-yCalc1).^2)/sum((GTypesDatata{3}(:,3) - mean(GTypesDatata{3}(:,3))).^2)
hold on
plot(GTypesDatata{3}(:,1),yCalc1,'b','LineWidth',5)

xlabel('Aperture Velocity [cm/s]')
ylabel('elbow angular vel [degrees/s]')
title('t2')
grid on

subplot(3,2,6)
scatter(GTypesDatata{3}(:,2),GTypesDatata{3}(:,3),'SizeData',200,'MarkerFaceColor',[0.467,0.675,0.188])

X = [ones(length(GTypesDatata{3}(:,2)),1) GTypesDatata{3}(:,2)];
b1 = X\GTypesDatata{3}(:,3);
yCalc1 = X*b1;
Rsq2 = 1 - sum((GTypesDatata{3}(:,3)-yCalc1).^2)/sum((GTypesDatata{3}(:,3) - mean(GTypesDatata{3}(:,3))).^2)
hold on
plot(GTypesDatata{3}(:,2),yCalc1,'b','LineWidth',5)

xlabel('Aperture [cm]')
ylabel('elbow angular vel[degrees/s]')
title('t2')
grid on

figure(2)

subplot(2,2,1)
scatter(GTypesDatata{4}(:,1),GTypesDatata{4}(:,3),'Marker','d','SizeData',200,'MarkerFaceColor',[0.635,0.078,0.184])

X = [ones(length(GTypesDatata{4}(:,1)),1) GTypesDatata{4}(:,1)];
b1 = X\GTypesDatata{4}(:,3);
yCalc1 = X*b1;
Rsq2 = 1 - sum((GTypesDatata{4}(:,3)-yCalc1).^2)/sum((GTypesDatata{4}(:,3) - mean(GTypesDatata{3}(:,3))).^2)
hold on
plot(GTypesDatata{4}(:,1),yCalc1,'b','LineWidth',5)

xlabel('Aperture Velocity [cm/s]')
ylabel('elbow angular vel [degrees/s]')
title('t4')
grid on


subplot(2,2,2)
scatter(GTypesDatata{4}(:,2),GTypesDatata{4}(:,3),'Marker','d','SizeData',200,'MarkerFaceColor',[0.635,0.078,0.184])

X = [ones(length(GTypesDatata{4}(:,2)),1) GTypesDatata{4}(:,2)];
b1 = X\GTypesDatata{4}(:,3);
yCalc1 = X*b1;
Rsq2 = 1 - sum((GTypesDatata{4}(:,3)-yCalc1).^2)/sum((GTypesDatata{4}(:,3) - mean(GTypesDatata{4}(:,3))).^2)
hold on
plot(GTypesDatata{4}(:,2),yCalc1,'b','LineWidth',5)

xlabel('Aperture [cm]')
ylabel('elbow angular vel[degrees/s]')
title('t4')
grid on

subplot(2,2,3)
scatter(GTypesDatata{5}(:,1),GTypesDatata{5}(:,3),'Marker','d','SizeData',200,'MarkerFaceColor',[0,0,1])

X = [ones(length(GTypesDatata{5}(:,1)),1) GTypesDatata{5}(:,1)];
b1 = X\GTypesDatata{5}(:,3);
yCalc1 = X*b1;
Rsq2 = 1 - sum((GTypesDatata{5}(:,3)-yCalc1).^2)/sum((GTypesDatata{5}(:,3) - mean(GTypesDatata{5}(:,3))).^2)
hold on
plot(GTypesDatata{5}(:,1),yCalc1,'b','LineWidth',5)

xlabel('Aperture Velocity [cm/s]')
ylabel('elbow angular vel [degrees/s]')
title('lateral')
grid on


subplot(2,2,4)
scatter(GTypesDatata{5}(:,2),GTypesDatata{5}(:,3),'Marker','d','SizeData',200,'MarkerFaceColor',[0,0,1])

X = [ones(length(GTypesDatata{5}(:,2)),1) GTypesDatata{5}(:,2)];
b1 = X\GTypesDatata{5}(:,3);
yCalc1 = X*b1;
Rsq2 = 1 - sum((GTypesDatata{5}(:,3)-yCalc1).^2)/sum((GTypesDatata{5}(:,3) - mean(GTypesDatata{5}(:,3))).^2)
hold on
plot(GTypesDatata{5}(:,2),yCalc1,'b','LineWidth',5)

xlabel('Aperture [cm]')
ylabel('elbow angular vel[degrees/s]')
title('lateral')
grid on


