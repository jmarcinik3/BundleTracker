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
            switch(keyword)
                case TrackingAlgorithms.centerOfMass
                    center = TrackingAlgorithms.byCenterOfMass(im);
                case TrackingAlgorithms.gaussianFit
                    center = TrackingAlgorithms.byGaussianFit(im);
            end
        end

        function center = byGaussianFit(im)
            center = gaussian(im);
        end

        function center = byCenterOfMass(im)
            center = centroid(im);
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

function center = centroid(im)
[rows, columns] = size(im);
x = ones(rows, 1) * (1:columns); % 2D matrix of x indicies
y = (1:rows)' * ones(1, columns); % 2D matrix of y indicies

intensity = double(im);
area = sum(intensity, "all");
weights = intensity / area;

xmean = sum(weights.*x, "all");
ymean = sum(weights.*y, "all");
[xerr, yerr] = bootstrapCentroid(x, y, weights);

center = PointStructurer.asPoint(xmean, ymean, xerr, yerr);
end

function [xerr, yerr] = bootstrapCentroid(x, y, weights)
[rows, columns] = size(x);

bootstrapCount = round(sqrt(rows * columns));
xmeans = 0 * ones(1, bootstrapCount);
ymeans = 0 * ones(1, bootstrapCount);
xstds = 0 * ones(1, bootstrapCount);
ystds = 0 * ones(1, bootstrapCount);

for index = 1:bootstrapCount
    newArea = 0;
    while newArea == 0
        randomMask = rand(rows, columns);
        newWeights = weights;
        newWeights(randomMask < weights) = 0;
        newArea = sum(newWeights, "all");
        newWeights = newWeights / newArea;
    end

    xnew = sum(newWeights.*x, "all");
    ynew = sum(newWeights.*y, "all");

    xmeans(index) = xnew;
    ymeans(index) = ynew;
    xstds(index) = sqrt(sum(newWeights.*x.^2, "all") - xnew^2);
    ystds(index) = sqrt(sum(newWeights.*y.^2, "all") - ynew^2);
end

xerr = std(xmeans, 1 ./ (xstds.^2));
yerr = std(ymeans, 1 ./ (ystds.^2));
end