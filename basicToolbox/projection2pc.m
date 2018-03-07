function [score]=projection2pc(dGrasp,coeff,globalMeans,nbComponents)


% dSet=[];

score=struct([]);

for tr=1:length(dGrasp)
    
    cntrdImgMatrix=dGrasp{tr}'-repmat(mean((globalMeans),1),size((dGrasp{tr}'),1),1);
    
    proj= cntrdImgMatrix*coeff;
    
    score{tr}=proj(:,1:nbComponents)';
        
end
% 
% cntrdImgMatrix_power=dSet'-repmat(mean((globalMeans),1),size((dSet'),1),1);
% 
% score= cntrdImgMatrix_power*coeff;
% 
% average_coord=mean(score(:,1:nbComponents));
% 
% std_coord=std(score(:,1:nbComponents))

end