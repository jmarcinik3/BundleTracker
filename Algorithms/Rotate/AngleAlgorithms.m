classdef AngleAlgorithms
    properties (Constant)
        keywords = [ ...
            AngleAlgorithms.noneKeyword, ...
            sort([ ...
            AngleAlgorithms.ellipseKeyword, ...
            AngleAlgorithms.gaussianMixtureKeyword, ...
            AngleAlgorithms.kmeansKeyword, ...
            AngleAlgorithms.linearKeyword, ...
            ]) ...
            ];
    end
    properties (Constant, Access = private)
        noneKeyword = "None";
        ellipseKeyword = "Elliptical Regression";
        gaussianMixtureKeyword = "Two Gaussian Mixtures";
        kmeansKeyword = "2-Means Clustering";
        linearKeyword = "Linear Regression";
    end
    

    methods (Static)
        function [angle, angleError, angleInfo] = byKeyword(x, y, keyword)
            switch keyword
                case AngleAlgorithms.noneKeyword
                    [angle, angleError, angleInfo] = AngleAlgorithms.byNone(x, y);
                case AngleAlgorithms.ellipseKeyword
                    [angle, angleError, angleInfo] = AngleAlgorithms.byEllipseFit(x, y);
                case AngleAlgorithms.gaussianMixtureKeyword
                    [angle, angleError, angleInfo] = AngleAlgorithms.byGaussianMixture(x, y);
                case AngleAlgorithms.kmeansKeyword
                    [angle, angleError, angleInfo] = AngleAlgorithms.byKMeansClustering(x, y);
                case AngleAlgorithms.linearKeyword
                    [angle, angleError, angleInfo] = AngleAlgorithms.byLinearFit(x, y);
            end
        end

        function [angle, angleError, fitInfo] = byNone(~, ~)
            angle = 0;
            angleError = 0;
            fitInfo = [];
        end
        function [angle, angleError, fitInfo] = byEllipseFit(x, y)
            [angle, angleError, fitInfo] = byEllipseFit(x, y);
        end
        function [angle, angleError, fitInfo] = byGaussianMixture(x, y)
            [angle, angleError, fitInfo] = GaussianMixture(x, y, 2).angleWithError();
        end
        function [angle, angleError, fitInfo] = byKMeansClustering(x, y)
            [angle, angleError, fitInfo] = KMeans(x, y, 2).angleWithError();
        end
        function [angle, angleError, fitInfo] = byLinearFit(x, y)
            [angle, angleError, fitInfo] = byLinearFit(x, y);
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

function [angle, angleError, fitInfo] = byLinearFit(x, y)
fitInfo = fitlm(x, y);
slope = fitInfo.Coefficients.Estimate(2);
slopeError = fitInfo.Coefficients.SE(2);
angle = atan(slope);
angleError = slopeError / (1+slope^2);
end
