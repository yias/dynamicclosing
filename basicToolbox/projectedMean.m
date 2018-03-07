function [average_coord,std_coord]=projectedMean(dGrasp,coeff,globalMeans,nbComponents)


dSet=[];

for tr=1:length(dGrasp)
    
    dSet=[dSet,dGrasp{tr}(:,end)];
        
end

cntrdImgMatrix_power=dSet'-repmat(mean((globalMeans),1),size((dSet'),1),1);

score= cntrdImgMatrix_power*coeff;

average_coord=mean(score(:,1:nbComponents));

std_coord=std(score(:,1:nbComponents));

end