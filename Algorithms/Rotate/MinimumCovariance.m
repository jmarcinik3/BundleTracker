classdef MinimumCovariance
    properties (Access = private)
        x;
        y;
        bootstrapCount;
    end

    methods
        function obj = MinimumCovariance(x, y, varargin)
            p = inputParser;
            addOptional(p, "BootstrapCount", 4);
            parse(p, varargin{:});
            obj.bootstrapCount = p.Results.BootstrapCount;

            obj.x = x;
            obj.y = y;
        end

        function angle = calculateAngle(obj)
            x = obj.x;
            y = obj.y;

            covMatrix = cov(x, y);
            absRotCovFunc = @(theta) abs(rotateCovariance(covMatrix, theta));
            angle = fminsearch(absRotCovFunc, 0);
        end

        function [angle, angleError, angleInfo] = angleWithError(obj)
            angle = calculateAngle(obj.x, obj.y);
            angleError = obj.bootstrapError(obj.bootstrapCount);
            angleInfo = [];
        end
    end

    methods (Access = private)
        function angleError = bootstrapError(obj, bootstrapCount)
            x = obj.x;
            y = obj.y;

            pointCount = numel(x);
            angles = zeros(1, bootstrapCount);
            partition = cvpartition(pointCount, "KFold", bootstrapCount);

            for index = 1:bootstrapCount
                mask = test(partition, index);
                angle = calculateAngle(x(mask), y(mask));
                angles(:, index) = angle;
            end

            angleError = std(angles);
        end
    end
end


function angle = calculateAngle(x, y)
covMatrix = cov(x, y);
absRotCovFunc = @(theta) abs(rotateCovariance(covMatrix, theta));
angle = fminsearch(absRotCovFunc, 0);
end

function rotatedCovariance = rotateCovariance(covMatrix, angle)
rotMatrix = [
    cos(angle), -sin(angle);
    sin(angle), cos(angle)
    ];
rotCovMatrix = rotMatrix.' * covMatrix * rotMatrix;
rotatedCovariance = rotCovMatrix(1, 2);
end
