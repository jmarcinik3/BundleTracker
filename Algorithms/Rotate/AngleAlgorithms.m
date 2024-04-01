classdef AngleAlgorithms
    properties (Constant)
        ellipseFit = "Elliptical Regression";
        kmeansKeyword = "K-Means Clustering";
        linearFit = "Linear Regression";
        keywords = sort([ ...
            AngleAlgorithms.ellipseFit, ...
            AngleAlgorithms.kmeansKeyword, ...
            AngleAlgorithms.linearFit, ...
            ]);
    end

    methods (Static)
        function [angle, angleError, angleInfo] = byKeyword(x, y, keyword)
            switch keyword
                case AngleAlgorithms.ellipseFit
                    [angle, angleError, angleInfo] = AngleAlgorithms.byEllipseFit(x, y);
                case AngleAlgorithms.kmeansKeyword
                    [angle, angleError, angleInfo] = AngleAlgorithms.byKMeansClustering(x, y);
                case AngleAlgorithms.linearFit
                    [angle, angleError, angleInfo] = AngleAlgorithms.byLinearFit(x, y);
            end
        end

        function [angle, angleError, fitInfo] = byEllipseFit(x, y)
            [angle, angleError, fitInfo] = byEllipseFit(x, y);
        end
        function [angle, angleError, fitInfo] = byLinearFit(x, y)
            [angle, angleError, fitInfo] = byLinearFit(x, y);
        end
        function [angle, angleError, fitInfo] = byKMeansClustering(x, y)
            [angle, angleError, fitInfo] = byKMeansClustering(x, y);
        end
    end
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

function [angle, angleError, fitInfo] = byKMeansClustering(x, y)
xy = [x', y'];
[labels, centers] = kmeans(xy, 2);
xcenters = centers(:, 1);
ycenters = centers(:, 2);
deltaX = diff(xcenters);
deltaY = diff(ycenters);
angle = atan(deltaY / deltaX);
angleError = Inf;
fitInfo = struct( ...
    "Labels", labels, ...
    "Centers", centers ...
    );
end

function [angle, angleError, fitInfo] = byLinearFit(x, y)
fitInfo = fitlm(x, y);
slope = fitInfo.Coefficients.Estimate(2);
slopeError = fitInfo.Coefficients.SE(2);
angle = atan(slope);
angleError = slopeError / (1+slope^2);
end


