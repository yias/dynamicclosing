function allegroJA=allegroHandMapping(gloveJA,gloveLimits,AllegroJointLimits)

allegroJA=struct([]);

for i=1:length(gloveJA)
    
    allegroJA{i}=[];
    
    for ja=1:size(gloveJA{i},1)
    
            allegroJA{i}=[allegroJA{i};...
                                  AllegroJointLimits(2,ja)-((gloveJA{i}(ja,:)-gloveLimits(2,ja))/(gloveLimits(1,ja)-gloveLimits(2,ja)))*(AllegroJointLimits(1,ja)-AllegroJointLimits(2,ja))];
    
    end


end


end