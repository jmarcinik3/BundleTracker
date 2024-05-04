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
                    handle = @TrackingAlgorithms.byCenterOfMass;
                case TrackingAlgorithms.crossCorrelation
                    handle = crossCorrelationTracker(ims(:, :, 1));
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
            center = GaussianFitter(im).withError();
        end
    end
end



function handle = crossCorrelationTracker(firstFrame)
tracker = CrossCorrelation(firstFrame);
handle = @tracker.offsetWithError;
end
