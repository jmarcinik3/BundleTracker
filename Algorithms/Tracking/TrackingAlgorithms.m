classdef TrackingAlgorithms
    properties (Constant)
        centerOfMass = "Centroid";
        gaussianFit = "2D Gaussian";
        keywords = [ ...
            TrackingAlgorithms.centerOfMass, ...
            TrackingAlgorithms.gaussianFit ...
            ];
    end

    methods (Static)
        function center = byKeyword(im, keyword)
            switch keyword
                case TrackingAlgorithms.centerOfMass
                    center = Centroid(im).withError();
                case TrackingAlgorithms.gaussianFit
                    center = gaussian(im);
            end
        end
    end
end

function center = gaussian(im)
[rows, columns] = size(im);
x = 1:columns;
y = (1:rows)';

[fitParameters, ~, fitErrors, ~, ~, ~] = fmgaussfit(x, y, im);
xmean = fitParameters(5);
ymean = fitParameters(6);
xerr = fitErrors(5);
yerr = fitErrors(6);

center = PointStructurer.asPoint(xmean, ymean, xerr, yerr);
end
