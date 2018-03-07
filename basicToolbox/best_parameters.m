function [best_epsilon,best_gamma,best_C,best_performance]=best_parameters(performcances,epsilon,gamma,constraint,criterion)



bestPerf=zeros(length(epsilon),1);

% first column corresponds to gamma, the second columb to C
best_gC=zeros(length(epsilon),2);

for i=1:length(epsilon)
    
    if strcmp(criterion,'max')
    
        [a,b]=max(squeeze(performcances(i,:,:)));
    
        [bestPerf(i),best_g]=max(a);
    else
        if strcmp(criterion,'min')
            [a,b]=min(squeeze(performcances(i,:,:)));
    
            [bestPerf(i),best_g]=min(a);
        else
            disp('wrong definition of criterion')
        end
    end
    
    best_gC(i,2)=best_g;
    best_gC(i,1)=b(best_g);
    
end

[best_performance,id]=max(bestPerf);


best_epsilon=epsilon(id);
best_gamma=gamma(best_gC(id,1));
best_C=constraint(best_gC(id,2));







end