function [outputMatrix]=createTW(firstSample,finalSample,Signal,lenthgTW,SR,MuscleSet,overlap,featuresIDs)

% it discards the time windows that have smaller length than the desired
% length of the time window


output=struct([]);

%Signal=preprocessSignals(Signal(fistSample:end,:),SR,[50,400],20);

% Signal=preprocessSignals(Signal,SR,bandPassCuttOffFreq,lowPassCutOffFreq,normaLize,rectiFy,mvc);

l_TW=floor(lenthgTW*SR);
delay_TW=floor(l_TW-overlap*SR);
countTW=1;

for i=firstSample:delay_TW:finalSample
    
    if i+l_TW<finalSample
       
        output{countTW}=exctractFeatures(Signal(i:i+l_TW,MuscleSet),featuresIDs);
        countTW=countTW+1;
        
    end
    
   
end

outputMatrix=[];

for i=1:length(output)
    
    outputMatrix=[outputMatrix;output{i}];
    
end





end