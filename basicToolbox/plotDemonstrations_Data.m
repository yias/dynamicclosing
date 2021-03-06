function [sp]=plotDemonstrations_Data(Data,x0,index,sp)

figPositions=[0, 710, 510, 400;...
              510, 710, 510, 400;...
              1020, 710, 510, 400;...
              1530, 710, 510, 400;...
              0, 150,510, 400;...
              510, 150   510, 400;...
              1020, 150, 510, 400;...
              1530, 150, 510, 400;...
              2040, 710, 510, 400;...
              2540, 710, 510, 400;...
              2040, 150, 510, 400;...
              2550, 150, 510, 400;...
              3060, 710, 510, 400;...
              3060, 150, 510, 400;...
              0, 710, 510, 400;...
              510, 710, 510, 400;...
              1020, 710, 510, 400;...
              1530, 710, 510, 400;...
              0, 150,510, 400;...
              510, 150   510, 400;...
              1020, 150, 510, 400;...
              1530, 150, 510, 400;...
              2040, 710, 510, 400;...
              2540, 710, 510, 400;...
              2040, 150, 510, 400;...
              2550, 150, 510, 400;...
              3060, 710, 510, 400;...
              3060, 150, 510, 400];
 
 d=size(x0,1);
 if isempty(sp)
     sp=struct([]);
     for i=2:d
         sp{i-1}.fig=figure('name',['Simulation of the task; dim ' num2str(1) ',' num2str(i)],'position',figPositions(i-1,:));
     end
 end
 if length(sp)<2
      if d<3
          for demosID=1:length(index)-1
            plot(Data(1,index(demosID):index(demosID+1)-1),Data(2,index(demosID):index(demosID+1)-1),'linewidth',1.5,'LineStyle','--')
          end
      else
          for demosID=1:length(index)-1
            plot3(Data(1,index(demosID):index(demosID+1)-1),Data(2,index(demosID):index(demosID+1)-1),Data(3,index(demosID):index(demosID+1)-1),'linewidth',1.5,'LineStyle','--')
          end
      end
 else
     for i=2:d
         figure(sp{i-1}.fig)
         hold on
         for demosID=1:length(index)-1
            plot(Data(1,index(demosID):index(demosID+1)-1),Data(i,index(demosID):index(demosID+1)-1),'linewidth',1.5,'LineStyle','--')
            plot(x0(1,demosID),x0(i,demosID),'ok','markersize',10,'linewidth',1.5);
            if demosID==length(index)-1
                xlabel(['$\xi_{' num2str(1) '}$'],'interpreter','latex','fontsize',12);
                 ylabel(['$\xi_{' num2str(i) '}$'],'interpreter','latex','fontsize',12);
            end
        end
     end
end
 
 
end