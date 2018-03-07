classdef DataSet < handle
    %DATASET Encapsulates a dataset (MxN) composed of M rows of N
    %dimensional data points. Provides basic transformations on data.
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        raw
        ipr
        opr
        
        cn        
        mn
        scale
        
        n
        mind        
        maxd               
    end
    
    properties (Dependent)
        iraw
        oraw

        icn
        ocn
        
        in
        on
    end
    
    methods
        function d = DataSet(data, ipr, opr)
            d.ipr = 1:length(ipr);
            d.opr = length(ipr)+1:length(ipr)+length(opr);
            d.raw = [data(:,ipr) data(:,opr)];
            [d.cn, d.mn, d.scale] = DataSet.CenterAndNormalize(d.raw);
            [d.n, d.mind, d.maxd] = DataSet.Normalize(d.raw);
        end
        
        function xCN = toCN(d, x, range)
            xC = x - repmat(d.mn(1,range), size(x,1), 1);
            xCN = xC./repmat(d.scale(1,range), size(x,1), 1);
        end        
        function x = CN2Raw(d, xCN, range)
            xC = xCN.*repmat(d.scale(1,range), size(xCN,1), 1);
            x = xC + repmat(d.mn(1,range), size(xCN,1), 1);
        end
        
        function xN = toN(d, x, range)
            rnge = ones(size(x))*diag(d.maxd(1,range) - d.mind(1,range));
            dmin = ones(size(x))*diag(d.mind(1,range));
            dmax = ones(size(x))*diag(d.maxd(1,range));
            %x = max(x, dmin);
            %x = min(x, dmax);
            xN = (x - dmin) ./ rnge;
        end
        function x = N2Raw(d, xN, range)
            x = xN.*(ones(size(xN))*diag(d.maxd(1,range)-d.mind(1,range))) + ones(size(xN))*diag(d.mind(1,range));
        end
        
        function v = get.iraw(d)
            v = d.raw(:,d.ipr);
        end
        function v = get.oraw(d)
            v = d.raw(:,d.opr);
        end
        function v = get.icn(d)
            v = d.cn(:,d.ipr);
        end
        function v = get.ocn(d)
            v = d.cn(:,d.opr);
        end        
        function v = get.in(d)
            v = d.n(:,d.ipr);
        end
        function v = get.on(d)
            v = d.n(:,d.opr);
        end                
    end
    
    methods (Static)
        function [xN, mind, maxd] = Normalize(x)
            mind = min(x);
            maxd = max(x);
            range = ones(size(x))*diag(maxd - mind);
            xN = (x - ones(size(x))*diag(mind)) ./ range;
        end
        
        function [dataCN, dmean, scale] = CenterAndNormalize(data)
            dmean = mean(data);
            dataC = data - repmat(dmean, size(data,1), 1);            
            scale = max([abs(max(dataC)); abs(min(dataC))]);
            dataCN = dataC./repmat(scale, size(data,1), 1);
        end
                    
        function [training, validation] = Sample(data, nfolds, split)                                    
            ntraining = floor(split(1) / 100 * size(data,1));
            nvalidation = size(data,1) - ntraining;            
            if nvalidation*nfolds > size(data,1)
                disp(['validation size ' num2str(nvalidation) ' * nfolds ' num2str(nfolds) ' > data size ' num2str(size(data,1))]);
                nfolds = floor(size(data,1) / nvalidation);
                disp(['choosing nfolds = ' num2str(nfolds)]);
            end           
            
            training = cell(nfolds, 1);
            validation = cell(nfolds, 1);
            
            % choose the nfolds validation sets
            d = data;
            nv = nvalidation;
            for i = 1:nfolds
                validationidx = zeros(1, size(d,1));
               %idx = unique(randi(size(d,1), 1, nv*10), 'stable');
%               [~,I,~] = unique(randi(size(d,1), 1, nv*10));               
%               idx = I(1:nv);
                idx = randperm(size(d,1));
                idx = idx(1:nv);
                validationidx(1, idx) = 1;
                validationidx = logical(validationidx);
                remainderidx = ~validationidx;
                
                validation{i} = d(validationidx, :);
                d = d(remainderidx, :);
            end
            
            % fill in the training data based on the validation choice
            for i = 1:nfolds
                training{i} = d;
                for j = 1:nfolds
                    if i == j, continue; end
                    training{i} = [training{i}; validation{j}];
                end
            end            
        end
        
        function [training, validation] = Sample1(data, nfolds, split)                                    
            ntraining = floor(split(1) / 100 * size(data,1));
            nvalidation = size(data,1) - ntraining;            
            if nvalidation*nfolds > size(data,1)
                disp(['validation size ' num2str(nvalidation) ' * nfolds ' num2str(nfolds) ' > data size ' num2str(size(data,1))]);
                assert(0);
            end
            training = cell(nfolds, 1);
            validation = cell(nfolds, 1);
            
            % choose the nfolds validation sets
            d = data;
            for i = 1:nfolds
                trainidx = zeros(1, size(data,1));
                idx = unique(randi(size(data,1), 1, ntraining*10), 'stable');
                idx = idx(1:ntraining);                
                trainidx(1, idx) = 1;
                trainidx = logical(trainidx);
                validationidx = ~trainidx;
            
                training(:,:,i) = data(trainidx, :);
                validation(:,:,i) = data(validationidx, :);
            end
        end        
    end
end