function updateSensorValues(h, v, varargin)
    doAvg = 0;
    if numel(varargin) > 0 && strcmp(varargin{1}, 'average')
        doAvg = 1;
    end
    doImp = 0;
    if doAvg && numel(varargin) > 1 && strcmp(varargin{2}, 'importance')
        doImp = 1;
    end

    h.iterateSensors(@doUpdateVal);
    function doUpdateVal(s, varargin)
        pid = s.hLoc(1); lid = s.hLoc(2); patch = s.hLoc(3);
        tact = v{pid,lid,patch};
        s.raw = tact;            
        if doAvg
            s.avg = SensorPatch.avgTactileResponse(tact, 0);
            s.sum = sum(tact(:));
        end
    end

    if ~doImp, return; end

    s = [h.sensors{:}];
    m = max([s.sum]);
    h.iterateSensors(@doUpdateImportance)
    function doUpdateImportance(s, varargin)                
        s.importance = s.sum / m;
    end
end