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
        function [cancel, centers] = track(obj, ims)
            taskName = 'Tracking Region';
            trackingMode = obj.trackingMode;
            
            multiWaitbar(taskName, 0, 'CanCancel', 'on');
            frameCount = size(ims, 3);
            centers = PointStructurer.preallocate(frameCount);
            trackFrame = TrackingAlgorithms.handleByKeyword(trackingMode);

            for index = 1:frameCount
                centers(index) = trackFrame(ims(:, :, index));
                proportionComplete = index / frameCount;
                cancel = multiWaitbar(taskName, proportionComplete);
                if cancel
                    break;
                end
            end

            centers = PointStructurer.mergePoints(centers);
            multiWaitbar(taskName, 'Close');
        end
    end
end
