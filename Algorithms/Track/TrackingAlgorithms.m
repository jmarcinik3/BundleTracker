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
            handle = TrackingAlgorithms.handleByKeyword(keyword);
            center = handle(im);
        end
        function handle = handleByKeyword(keyword)
            switch keyword
                case TrackingAlgorithms.centerOfMass
                    handle = @TrackingAlgorithms.byCenterOfMass;
                case TrackingAlgorithms.gaussianFit
                    handle = @TrackingAlgorithms.byGaussianFit;
            end
        end
    end

    methods (Access = private, Static)
        function center = byCenterOfMass(im)
            center = Centroid(im).withError();
        end
        function center = byGaussianFit(im)
            center = gaussian(im);
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
