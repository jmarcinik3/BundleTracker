classdef TraceRotator
    methods (Static)
        function [xRotated, yRotated] = rotate2d(x, y, angle)
            xy = [x; y]';
            rotationMatrix = TraceRotator.rotationMatrix(angle);
            xyRotated = xy * rotationMatrix; % rotate xy about origin
            xRotated = xyRotated(:, 1)';
            yRotated = xyRotated(:, 2)';
        end

        function [xRotatedError, yRotatedError] ...
                = rotate2dError(x, y, xError, yError, angle, angleError)
            cas = cos(angle)^2;
            sas = sin(angle)^2;
            asError = angleError^2;

            xs = x.^2;
            ys = y.^2;
            xsError = xError.^2;
            ysError = yError.^2;

            xRotatedError = sqrt( ...
                cas*xsError + sas*ysError ...
                + asError*(sas*xs + cas*ys) ...
                );
            yRotatedError = sqrt( ...
                cas*ysError + sas*xsError ...
                + asError*(sas*ys + cas*xs) ...
                );
        end

        function matrix = rotationMatrix(angle)
            cosValue = cos(angle);
            sinValue = sin(angle);
            matrix = [
                cosValue, -sinValue;
                sinValue, cosValue
                ];
        end
    end
end