classdef TrackingAlgorithms
    properties (Constant)
        centerOfMass = "Centroid";
        crossCorrelation = "Maximum Cross-Correlation";
        gaussianFit = "2D Gaussian";
        keywords = sort([ ...
            TrackingAlgorithms.centerOfMass, ...
            TrackingAlgorithms.crossCorrelation, ...
            TrackingAlgorithms.gaussianFit ...
            ]);
    end

    methods (Static)
        function handle = handleByKeyword(keyword, ims)
            switch keyword
                case TrackingAlgorithms.centerOfMass
                    handle = centroidTracker(ims);
                case TrackingAlgorithms.crossCorrelation
                    handle = crossCorrelationTracker(ims(:, :, 1));
                case TrackingAlgorithms.gaussianFit
                    handle = @TrackingAlgorithms.byGaussianFit;
            end
        end
    end

    methods (Access = private, Static)
        function center = byGaussianFit(im)
            center = GaussianFitter(im).withError();
        end
    end
end


function handle = centroidTracker(ims)
tracker = Centroid(ims);
handle = @tracker.centerWithError;
end
function handle = crossCorrelationTracker(firstFrame)
tracker = CrossCorrelation(firstFrame);
handle = @tracker.offsetWithError;
end
