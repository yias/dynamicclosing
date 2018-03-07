% a mectory is made up of a sequence of marker sets contained in 'm'
n = size(m,2);

close all
figure
%xyzlabel
view(-160,44);
axis([-100 100 -100 100 -100 100 caxis]);
set(gcf, 'position', [309   173   962   749]);
hold on; grid on;

h = []; h_old = [];
for ti=1:n
    disp([ int2str(ti) '/' int2str(n) ]);
    mi = reshape(m(:,ti,:), 3, 9)';    
    h = plot3(mi(:,1), mi(:,2), mi(:,3), '*b', 'MarkerSize', 6, 'LineStyle', '-', 'Color', 'b');
    
    if exist('h_old','var') && ~isempty(h_old)
         delete(h_old); 
    end          
    h_old = h;
    pause(0.001);
%     pause;
end