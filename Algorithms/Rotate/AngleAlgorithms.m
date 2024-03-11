classdef AngleAlgorithms
    properties (Constant)
        linearFit = "Linear Regression";
        ellipseFit = "Elliptical Regression";
        keywords = [ ...
            AngleAlgorithms.ellipseFit ...    
            AngleAlgorithms.linearFit, ...
            ];
    end

    methods (Static)
        function [angle, angleError, angleInfo] = byKeyword(x, y, keyword)
            switch keyword
                case AngleAlgorithms.linearFit
                    [angle, angleError, angleInfo] = AngleAlgorithms.byLinearFit(x, y);
                case AngleAlgorithms.ellipseFit
                    [angle, angleError, angleInfo] = AngleAlgorithms.byEllipseFit(x, y);
            end
        end

        function [angle, angleError, fitInfo] = byLinearFit(x, y)
            [angle, angleError, fitInfo] = byLinearFit(x, y);
        end
        function [angle, angleError, fitInfo] = byEllipseFit(x, y)
            [angle, angleError, fitInfo] = byEllipseFit(x, y);
        end
    end
end



function [angle, angleError, fitInfo] = byLinearFit(x, y)
fitInfo = fitlm(x, y);
slope = fitInfo.Coefficients.Estimate(2);
slopeError = fitInfo.Coefficients.SE(2);
angle = atan(slope);
angleError = slopeError / (1+slope^2);
end

function [angle, angleError, fitInfo] = byEllipseFit(x, y)
xy = [x; y];
fitter = EllipticalFitter(xy);
angle = deg2rad(fitter.angle);
majorRadius = fitter.majorDiam / 2;
minorRadius = fitter.minorDiam / 2;
center = fitter.center;
angleError = Inf;
fitInfo = struct( ...
    "MajorRadius", majorRadius, ...
    "MinorRadius", minorRadius, ...
    "Center", center, ...
    "Angle", angle ...
    );
end
