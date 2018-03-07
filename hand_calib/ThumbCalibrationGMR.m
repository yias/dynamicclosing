classdef ThumbCalibrationGMR < handle
    properties
        Priors
        Mu
        Cov
        error
        
        data
    end
    
    methods
        function tc = ThumbCalibrationGMR(data, varargin)
            tc.data = DataSet(data, 1:4, 5:9);
            
            % choose the number of gaussian components through cross-validation
            if numel(varargin) == 1
                k = varargin{1};
            else
                k = 4:16;
                [errorMean, ~] = tc.GMR_TestK_CrossValidate(k, 10, [85 15]);
                [~, kidx] = sort(mean(errorMean, 2));
                k = k(kidx(1));
            end
            
            disp(['Choosing ' int2str(k) ' gaussian components']);
            [training, validation] = DataSet.Sample(tc.data.n, 1, [85 15]);
            [~, ~, tc.error, tc.Priors, tc.Mu, tc.Cov] = tc.GMR_train(training{1}, validation{1}, k);
        end
        
        function [y, sigma] = GMR_query(tc, x)
            xN = tc.data.toN(x, tc.data.ipr);
            [yN, sigma] = GMR(tc.Priors, tc.Mu, tc.Cov,  xN', tc.data.ipr, tc.data.opr);
            yN = yN';
            y = tc.data.N2Raw(yN, tc.data.opr);
        end
        
        function b = uncertaintyBounds(tc, y, s)
            b = conf2axesboundary(0.9, s);
            b = reshape(b, size(b,1), size(b,2)*2)';
            
            yCN = tc.data.toN(y, tc.data.opr);
            bCN = repmat(yCN, size(b,1), 1) + b;
            b = tc.data.N2Raw(bCN, tc.data.opr);
        end
        
        function [y, sigma, mse, p, mu, cov] = GMR_train(tc, training, validation, ngaussians)
            [p, mu, cov] = EM_init_kmeans(training', ngaussians);
            [p, mu, cov] = EM(training', p, mu, cov);
            [y, sigma] = GMR(p, mu, cov, validation(:,tc.data.ipr)', tc.data.ipr, tc.data.opr);
            y = y';
            mse = sum((validation(:, tc.data.opr) - y).^2)/size(validation,1);
        end
        
        function [errorMean, errorStd] = GMR_TestK_CrossValidate(tc, k, nfolds, split)
            [training, validation] = DataSet.Sample(tc.data.n, nfolds, split);
            errorMean = zeros(length(k), length(tc.data.opr));
            errorStd = zeros(length(k), length(tc.data.opr));
            for i=1:length(k)
                nComp = k(i);
                e = zeros(nfolds, length(tc.data.opr));
                for j=1:numel(training)                    
                    [~, ~, e(j,:), ~, ~, ~] = tc.GMR_train(training{j}, validation{j}, nComp);
                end
                me = mean(e);
                errorMean(i, :) = me;
                errorStd(i, :) = sqrt( sum((e - ones(size(e))*diag(me)).^2) / size(e,1) );
                str = sprintf('%i components : error %s', nComp, mat2str(me));
                disp(str);
            end
        end        
    end
end