classdef TrackingAlgorithms
    properties (Constant)
        centerOfMass = "Centroid";
        gaussianFit = "2D Gaussian";
        keywords = sort([ ...
            TrackingAlgorithms.centerOfMass, ...
            TrackingAlgorithms.gaussianFit ...
            ]);
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
            center = GaussianFitter(im).withError();
        end
    end
end
