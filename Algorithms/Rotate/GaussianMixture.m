classdef GaussianMixture
    properties (Access = private)
        xy;
        k;
        bootstrapCount;
    end

    methods
        function obj = GaussianMixture(x, y, k, varargin)
            p = inputParser;
            addOptional(p, "BootstrapCount", 4);
            parse(p, varargin{:});
            obj.bootstrapCount = p.Results.BootstrapCount;

            obj.k = k;
            obj.xy = [x; y]';
        end

        function [centers, fitInfo] = calculateCenters(obj)
            k = obj.k;
            xy = obj.xy;
            fitInfo = fitGaussianMixtures(xy, k);
            centers = sort(fitInfo.mu, 1);
        end

        function [angle, angleError, angleInfo] = angleWithError(obj)
            [xyCenter, angleInfo] = obj.centerWithError();
            angleWithError = calculateAngle(xyCenter);
            angle = angleWithError.Value;
            angleError = angleWithError.Error;
        end

        function [centerWithError, angleInfo] = centerWithError(obj)
            bootstrapCount = obj.bootstrapCount;
            [xyCenter, angleInfo] = obj.calculateCenters();
            xyCenterError = obj.bootstrapError(bootstrapCount);
            centerWithError = ErrorPropagator(xyCenter, xyCenterError);
        end
    end

    methods (Access = private)
        function xyCenterError = bootstrapError(obj, bootstrapCount)
            xy = obj.xy;
            k = obj.k;

            pointCount = size(xy, 1);
            xyCenters = zeros(k, 2, bootstrapCount);
            partition = cvpartition(pointCount, "KFold", bootstrapCount);

            for index = 1:bootstrapCount
                mask = test(partition, index);
                fitInfo = fitGaussianMixtures(xy(mask, :), k);
                xyCenter = fitInfo.mu;
                xyCenter = sort(xyCenter, 1);
                xyCenters(:, :, index) = xyCenter;
            end

            xyCenterError = std(xyCenters, [], 3);
        end
    end
end


function angleWithError = calculateAngle(xyCenter)
dx = xyCenter(2, 1) - xyCenter(1, 1);
dy = xyCenter(2, 2) - xyCenter(1, 2);
ratio = dy ./ dx;
angleWithError = atan(ratio);
end

function fitInfo = fitGaussianMixtures(xy, k)
fitInfo = fitgmdist(xy, k, ...
    "CovarianceType", "full", ...
    "SharedCovariance", false ...
    );
end
