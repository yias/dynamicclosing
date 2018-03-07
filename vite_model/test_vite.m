t = generate_vite(0.0,10.0,4.0,0.25,1.0/250.0);
figure
%position plot
plot(1:length(t),t(:,1))
figure
%speed plot
plot(1:length(t),t(:,2))
figure
%acceleration plot
plot(1:length(t),t(:,3))