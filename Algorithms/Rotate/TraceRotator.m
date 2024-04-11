classdef TraceRotator
    methods (Static)
        function [xRotated, yRotated] = rotate2d(x, y, angle)
            xy = [x; y]';
            matrix = rotationMatrix(angle);
            xyRotated = (xy * matrix).'; % rotate xy about origin
            xRotated = xyRotated(1, :);
            yRotated = xyRotated(2, :);
        end

        function [xRotated, yRotated] = rotate2dWithError(x, y, angle)
            xy = [x; y]';
            matrix = rotationMatrixWithError(angle);
            xyRotated = (xy * matrix).'; % rotate xy about origin
            xRotated = xyRotated(1, :);
            yRotated = xyRotated(2, :);
        end
    end
end

function matrix = rotationMatrix(angle)
cosValue = cos(angle);
sinValue = sin(angle);
matrix = [
    cosValue, -sinValue;
    sinValue, cosValue
    ];
end

function matrix = rotationMatrixWithError(angle)
cosValue = ErrorPropagator.cos(angle);
sinValue = ErrorPropagator.sin(angle);
matrix = [
    cosValue, -sinValue;
    sinValue, cosValue
    ];
end