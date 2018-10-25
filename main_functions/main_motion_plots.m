

organize_data

grasp1=struct([]);
counter1=1;
grasp2=struct([]);
counter2=1;
grasp3=struct([]);
counter3=1;
grasp4=struct([]);
counter4=1;
grasp5=struct([]);
counter5=1;


for i=1:length(crossvalidationFolders)
    for j=1:length(crossvalidationFolders{i})       
        if crossvalidationFolders{i}{j}.grasp==1
            grasp1{counter1}.Aperture=crossvalidationFolders{i}{j}.Aperture;
            grasp1{counter1}.velocity_Aperture=crossvalidationFolders{i}{j}.velocity_Aperture;
            grasp1{counter1}.FTipsArea=crossvalidationFolders{i}{j}.FTipsArea;
            grasp1{counter1}.velocity_Area=crossvalidationFolders{i}{j}.velocity_Area;
            grasp1{counter1}.elbow_a=crossvalidationFolders{i}{j}.elbow_a;
            grasp1{counter1}.elbow_v=crossvalidationFolders{i}{j}.elbow_v;
            counter1=counter1+1;
        end
        if crossvalidationFolders{i}{j}.grasp==2
            grasp2{counter2}.Aperture=crossvalidationFolders{i}{j}.Aperture;
            grasp2{counter2}.velocity_Aperture=crossvalidationFolders{i}{j}.velocity_Aperture;
            grasp2{counter2}.FTipsArea=crossvalidationFolders{i}{j}.FTipsArea;
            grasp2{counter2}.velocity_Area=crossvalidationFolders{i}{j}.velocity_Area;
            grasp2{counter2}.elbow_a=crossvalidationFolders{i}{j}.elbow_a;
            grasp2{counter2}.elbow_v=crossvalidationFolders{i}{j}.elbow_v;
            counter2=counter2+1;
        end
        if crossvalidationFolders{i}{j}.grasp==3
            grasp3{counter3}.Aperture=crossvalidationFolders{i}{j}.Aperture;
            grasp3{counter3}.velocity_Aperture=crossvalidationFolders{i}{j}.velocity_Aperture;
            grasp3{counter3}.FTipsArea=crossvalidationFolders{i}{j}.FTipsArea;
            grasp3{counter3}.velocity_Area=crossvalidationFolders{i}{j}.velocity_Area;
            grasp3{counter3}.elbow_a=crossvalidationFolders{i}{j}.elbow_a;
            grasp3{counter3}.elbow_v=crossvalidationFolders{i}{j}.elbow_v;
            counter3=counter3+1;
        end
        if crossvalidationFolders{i}{j}.grasp==4
            grasp4{counter4}.Aperture=crossvalidationFolders{i}{j}.Aperture;
            grasp4{counter4}.velocity_Aperture=crossvalidationFolders{i}{j}.velocity_Aperture;
            grasp4{counter4}.FTipsArea=crossvalidationFolders{i}{j}.FTipsArea;
            grasp4{counter4}.velocity_Area=crossvalidationFolders{i}{j}.velocity_Area;
            grasp4{counter4}.elbow_a=crossvalidationFolders{i}{j}.elbow_a;
            grasp4{counter4}.elbow_v=crossvalidationFolders{i}{j}.elbow_v;
            counter4=counter4+1;
        end
        if crossvalidationFolders{i}{j}.grasp==5
            grasp5{counter5}.Aperture=crossvalidationFolders{i}{j}.Aperture;
            grasp5{counter5}.velocity_Aperture=crossvalidationFolders{i}{j}.velocity_Aperture;
            grasp5{counter5}.FTipsArea=crossvalidationFolders{i}{j}.FTipsArea;
            grasp5{counter5}.velocity_Area=crossvalidationFolders{i}{j}.velocity_Area;
            grasp5{counter5}.elbow_a=crossvalidationFolders{i}{j}.elbow_a;
            grasp5{counter5}.elbow_v=crossvalidationFolders{i}{j}.elbow_v;
            counter5=counter5+1;
        end
 
    end
end

figure(1)
for i=1:length(grasp1)
    subplot(3,2,1)
    hold on
    plot(grasp1{i}.elbow_a)
    ylabel('degrees')
    title('ellbow joint angle')
    grid on
    
    subplot(3,2,2)
    hold on
    plot(grasp1{i}.elbow_v)
    ylabel('degrees/sec')
    title('ellbow joint angular velocity')
    grid on
    
    subplot(3,2,3)
    hold on
    plot(grasp1{i}.Aperture)
    ylabel('cm')
    title('hand aperture')
    grid on
    
    subplot(3,2,4)
    hold on
    plot(grasp1{i}.velocity_Aperture)
    ylabel('cm/s')
    title('hand aperture velocity')
    grid on
    
    subplot(3,2,5)
    hold on
    plot(grasp1{i}.FTipsArea)
    ylabel('cm/s')
    title('hand area')
    grid on
    
    subplot(3,2,6)
    hold on
    plot(grasp1{i}.velocity_Area)
    ylabel('cm/s')
    title('hand area velocity')
    grid on
    
end

figure(2)
for i=1:length(grasp2)
    subplot(3,2,1)
    hold on
    plot(grasp2{i}.elbow_a)
    ylabel('degrees')
    title('ellbow joint angle')
    grid on
    
    subplot(3,2,2)
    hold on
    plot(grasp2{i}.elbow_v)
    ylabel('degrees/sec')
    title('ellbow joint angular velocity')
    grid on
    
    subplot(3,2,3)
    hold on
    plot(grasp2{i}.Aperture)
    ylabel('cm')
    title('hand aperture')
    grid on
    
    subplot(3,2,4)
    hold on
    plot(grasp2{i}.velocity_Aperture)
    ylabel('cm/s')
    title('hand aperture velocity')
    grid on
    
    subplot(3,2,5)
    hold on
    plot(grasp2{i}.FTipsArea)
    ylabel('cm/s')
    title('hand area')
    grid on
    
    subplot(3,2,6)
    hold on
    plot(grasp2{i}.velocity_Area)
    ylabel('cm/s')
    title('hand area velocity')
    grid on
    
end
    
figure(3)
for i=1:length(grasp3)
    subplot(3,2,1)
    hold on
    plot(grasp3{i}.elbow_a)
    ylabel('degrees')
    title('ellbow joint angle')
    grid on
    
    subplot(3,2,2)
    hold on
    plot(grasp3{i}.elbow_v)
    ylabel('degrees/sec')
    title('ellbow joint angular velocity')
    grid on
    
    subplot(3,2,3)
    hold on
    plot(grasp3{i}.Aperture)
    ylabel('cm')
    title('hand aperture')
    grid on
    
    subplot(3,2,4)
    hold on
    plot(grasp3{i}.velocity_Aperture)
    ylabel('cm/s')
    title('hand aperture velocity')
    grid on
    
    subplot(3,2,5)
    hold on
    plot(grasp3{i}.FTipsArea)
    ylabel('cm/s')
    title('hand area')
    grid on
    
    subplot(3,2,6)
    hold on
    plot(grasp3{i}.velocity_Area)
    ylabel('cm/s')
    title('hand area velocity')
    grid on
    
end

figure(4)
for i=1:length(grasp4)
    subplot(3,2,1)
    hold on
    plot(grasp4{i}.elbow_a)
    ylabel('degrees')
    title('ellbow joint angle')
    grid on
    
    subplot(3,2,2)
    hold on
    plot(grasp4{i}.elbow_v)
    ylabel('degrees/sec')
    title('ellbow joint angular velocity')
    grid on
    
    subplot(3,2,3)
    hold on
    plot(grasp4{i}.Aperture)
    ylabel('cm')
    title('hand aperture')
    grid on
    
    subplot(3,2,4)
    hold on
    plot(grasp4{i}.velocity_Aperture)
    ylabel('cm/s')
    title('hand aperture velocity')
    grid on
    
    subplot(3,2,5)
    hold on
    plot(grasp4{i}.FTipsArea)
    ylabel('cm/s')
    title('hand area')
    grid on
    
    subplot(3,2,6)
    hold on
    plot(grasp4{i}.velocity_Area)
    ylabel('cm/s')
    title('hand area velocity')
    grid on
    
end

figure(5)
for i=1:length(grasp5)
    subplot(3,2,1)
    hold on
    plot(grasp5{i}.elbow_a)
    ylabel('degrees')
    title('ellbow joint angle')
    grid on
    
    subplot(3,2,2)
    hold on
    plot(grasp5{i}.elbow_v)
    ylabel('degrees/sec')
    title('ellbow joint angular velocity')
    grid on
    
    subplot(3,2,3)
    hold on
    plot(grasp5{i}.Aperture)
    ylabel('cm')
    title('hand aperture')
    grid on
    
    subplot(3,2,4)
    hold on
    plot(grasp5{i}.velocity_Aperture)
    ylabel('cm/s')
    title('hand aperture velocity')
    grid on
    
    subplot(3,2,5)
    hold on
    plot(grasp5{i}.FTipsArea)
    ylabel('cm/s')
    title('hand area')
    grid on
    
    subplot(3,2,6)
    hold on
    plot(grasp5{i}.velocity_Area)
    ylabel('cm/s')
    title('hand area velocity')
    grid on
    
end


%%

lls1=[];
lls2=[];
lls3=[];
lls4=[];
lls5=[];

lls_re1=[];
lls_re2=[];
lls_re3=[];
lls_re4=[];
lls_re5=[];

for i=1:length(grasp1)

    lls1=[lls1;length(grasp1{i}.velocity_Area)];
    lls_re1=[lls_re1;length(grasp1{i}.elbow_v)];
    
end

for i=1:length(grasp2)

    lls2=[lls2;length(grasp2{i}.velocity_Area)];
    lls_re2=[lls_re2;length(grasp2{i}.elbow_v)];
end

for i=1:length(grasp3)

    lls3=[lls3;length(grasp3{i}.velocity_Area)];
    lls_re3=[lls_re3;length(grasp3{i}.elbow_v)];
end

for i=1:length(grasp4)

    lls4=[lls4;length(grasp4{i}.velocity_Area)];
    lls_re4=[lls_re4;length(grasp4{i}.elbow_v)];
end

for i=1:length(grasp5)

    lls5=[lls5;length(grasp5{i}.velocity_Area)];
    lls_re5=[lls_re5;length(grasp5{i}.elbow_v)];
end

lls=[lls1;lls2;lls3;lls4;lls5];
lls_re=[lls_re1;lls_re2;lls_re3;lls_re4;lls_re5];

g1_v=[];
g2_v=[];
g3_v=[];
g4_v=[];
g5_v=[];

re_v1=[];
re_v2=[];
re_v3=[];
re_v4=[];
re_v5=[];

for i=1:length(grasp1)

    g1_v=[g1_v;resample(grasp1{i}.velocity_Area,round(mean(lls)),length(grasp1{i}.velocity_Area))'/max(abs(resample(grasp1{i}.velocity_Area,round(mean(lls)),length(grasp1{i}.velocity_Area))))];
    re_v1=[re_v1;resample(grasp1{i}.elbow_v,round(mean(lls)),length(grasp1{i}.elbow_v))'/max(abs(resample(grasp1{i}.elbow_v,round(mean(lls)),length(grasp1{i}.elbow_v))))];
end

for i=1:length(grasp2)

    g2_v=[g2_v;resample(grasp2{i}.velocity_Area,round(mean(lls)),length(grasp2{i}.velocity_Area))'/max(abs(resample(grasp2{i}.velocity_Area,round(mean(lls)),length(grasp2{i}.velocity_Area))))];
    re_v2=[re_v2;resample(grasp2{i}.elbow_v,round(mean(lls)),length(grasp2{i}.elbow_v))'/max(abs(resample(grasp2{i}.elbow_v,round(mean(lls)),length(grasp2{i}.elbow_v))))];
    
end

for i=1:length(grasp3)

    g3_v=[g3_v;resample(grasp3{i}.velocity_Area,round(mean(lls)),length(grasp3{i}.velocity_Area))'/max(abs(resample(grasp3{i}.velocity_Area,round(mean(lls)),length(grasp3{i}.velocity_Area))))];
    re_v3=[re_v3;resample(grasp3{i}.elbow_v,round(mean(lls)),length(grasp3{i}.elbow_v))'/max(abs(resample(grasp3{i}.elbow_v,round(mean(lls)),length(grasp3{i}.elbow_v))))];
    
end

for i=1:length(grasp4)

    g4_v=[g4_v;resample(grasp4{i}.velocity_Area,round(mean(lls)),length(grasp4{i}.velocity_Area))'/max(abs(resample(grasp4{i}.velocity_Area,round(mean(lls)),length(grasp4{i}.velocity_Area))))];
    re_v4=[re_v4;resample(grasp4{i}.elbow_v,round(mean(lls)),length(grasp4{i}.elbow_v))'/max(abs(resample(grasp4{i}.elbow_v,round(mean(lls)),length(grasp4{i}.elbow_v))))];
    
end

for i=1:length(grasp5)

    g5_v=[g5_v;resample(grasp5{i}.velocity_Area,round(mean(lls)),length(grasp5{i}.velocity_Area))'/max(abs(resample(grasp5{i}.velocity_Area,round(mean(lls)),length(grasp5{i}.velocity_Area))))];
    re_v5=[re_v5;resample(grasp5{i}.elbow_v,round(mean(lls)),length(grasp5{i}.elbow_v))'/max(abs(resample(grasp5{i}.elbow_v,round(mean(lls)),length(grasp5{i}.elbow_v))))];
    
end

re_v=[re_v1;re_v2;re_v3;re_v4;re_v5];

figure
plot(mean(re_v))
hold on
plot(mean(g1_v))
plot(mean(g2_v))
plot(mean(g3_v))
plot(mean(g4_v))
plot(mean(g5_v))
errorbar(mean(re_v),std(re_v)/sqrt(size(re_v,1)))
errorbar(mean(g1_v),std(g1_v)/sqrt(size(g1_v,1)))
errorbar(mean(g2_v),std(g2_v)/sqrt(size(g2_v,1)))
errorbar(mean(g3_v),std(g3_v)/sqrt(size(g3_v,1)))
errorbar(mean(g4_v),std(g4_v)/sqrt(size(g4_v,1)))
errorbar(mean(g5_v),std(g5_v)/sqrt(size(g5_v,1)))
legend('Elbow angular velocity','Precision','Tripod','T-2fingers','T-4finger','Lateral')
grid on
xlabel('normalized time')


