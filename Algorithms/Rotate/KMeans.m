classdef KMeans
    properties (Access = private)
        xy;
        k;
        bootstrapCount;
    end

    methods
        function obj = KMeans(x, y, k, varargin)
            p = inputParser;
            addOptional(p, "BootstrapCount", round(sqrt(numel(x))));
            parse(p, varargin{:});
            obj.bootstrapCount = p.Results.BootstrapCount;

            obj.k = k;
            obj.xy = [x; y]';
        end

        function [labels, centers] = calculateCenters(obj)
            k = obj.k;
            xy = obj.xy;
            [labels, centers] = kmeans(xy, k);
        end

        function [angle, angleError, angleInfo] = angleWithError(obj)
            [labels, xyCenter] = obj.centerWithError();
            angleWithError = calculateAngle(xyCenter);
            angle = angleWithError.Value;
            angleError = angleWithError.Error;
            angleInfo = struct( ...
                "Labels", labels, ...
                "Centers", xyCenter.Value ...
                );
        end

        function [labels, centerWithError] = centerWithError(obj)
            bootstrapCount = obj.bootstrapCount;
            [labels, xyCenter] = obj.calculateCenters();
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
            randomMatrix = rand(pointCount, 1);
            keepLevels = linspace(0, 1, bootstrapCount+1);
            for index = 1:bootstrapCount
                mask = (keepLevels(index) < randomMatrix) ...
                    & (randomMatrix <= keepLevels(index+1));
                [~, xyCenter] = kmeans(xy(mask, :), k);
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
angleWithError = ErrorPropagator.scalarFunction(ratio, @atan);
end