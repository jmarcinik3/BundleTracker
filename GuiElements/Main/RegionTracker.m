classdef RegionTracker
    properties (Access = private)
        trackingMode;
        continueCalculation = true;
    end

    methods
        function obj = RegionTracker(varargin)
            p = inputParser;
            addOptional(p, "TrackingMode", TrackingAlgorithms.centerOfMass);
            parse(p, varargin{:});
            trackingMode = p.Results.TrackingMode;

            obj.trackingMode = trackingMode;
        end
    end

    %% Functions to retrieve state information
    methods (Access = protected)
        function was = trackingWasCompleted(obj)
            was = obj.continueCalculation;
        end
    end

    %% Functions to perform tracking
    methods
        function centers = track(obj, ims)
            frameCount = size(ims, 3);
            centers = PointStructurer.preallocate(frameCount);
            trackingMode = obj.trackingMode;
            
            progress = ProgressBar(frameCount, "Tracking Region");
            trackFrame = TrackingAlgorithms.handleByKeyword(trackingMode);
            for index = 1:frameCount
                centers(index) = trackFrame(ims(:, :, index));
                count(progress);
            end

            centers = PointStructurer.mergePoints(centers);
        end
    end
end
