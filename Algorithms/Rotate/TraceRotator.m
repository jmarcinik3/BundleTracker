classdef TraceRotator
    methods (Static)
        function [xRotated, yRotated] = rotate2d(x, y, angle)
            xy = [x; y].';
            matrix = rotationMatrix(angle);
            xyRotated = (xy * matrix).'; % rotate xy about origin
            xRotated = xyRotated(1, :);
            yRotated = xyRotated(2, :);
        end
    end
end

function matrix = rotationMatrix(angle)
% rotates CCW by angle
cosValue = cos(angle);
sinValue = sin(angle);
matrix = [
    cosValue, -sinValue;
    sinValue, cosValue
    ];
end
