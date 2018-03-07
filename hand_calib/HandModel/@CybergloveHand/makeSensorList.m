function sensorList = makeSensorList(h)
    sensorList = [
        h.sensors{1,1,1}
        h.sensors{1,2,1}
        h.sensors{1,3,1}
        
        h.sensors{2,1,1}
        h.sensors{2,2,1}
        h.sensors{2,3,1}        
        h.sensors{2,1,2}        
        h.sensors{2,2,2}
        h.sensors{2,3,2}
        
        h.sensors{3,1,1}        
        h.sensors{3,2,1}        
        h.sensors{3,3,1}        
        h.sensors{3,1,2}        
        h.sensors{3,2,2}        
        h.sensors{3,3,2}
        
        h.sensors{4,1,1}        
        h.sensors{4,2,1}        
        h.sensors{4,3,1}        
        h.sensors{4,1,2}        
        h.sensors{4,2,2}        
        h.sensors{4,3,2}

        h.sensors{5,1,1}        
        h.sensors{5,2,1}        
        h.sensors{5,3,1}        
        h.sensors{5,1,2}        
        h.sensors{5,2,2}        
        h.sensors{5,3,2}

        h.sensors{6,1,1}        
        h.sensors{6,2,1}        
        h.sensors{6,3,1}        
        h.sensors{6,4,1}        
        h.sensors{6,5,1}        
        h.sensors{6,6,1}        
        h.sensors{6,6,2}        
    ]';
end