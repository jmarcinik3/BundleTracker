classdef RegionTracker
    properties (Access = private)
        trackingMode;
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

    %% Functions to perform tracking
    methods
        function [cancel, centers] = track(obj, ims)
            taskName = 'Tracking Region';
            trackingMode = obj.trackingMode;
            
            multiWaitbar(taskName, 0, 'CanCancel', 'on');
            frameCount = size(ims, 3);
            centers = PointStructurer.preallocate(frameCount);
            trackFrame = TrackingAlgorithms.handleByKeyword(trackingMode);

            cancel = false;
            proportionDelta = 1 / frameCount;
            for index = 1:frameCount
                centers(index) = trackFrame(ims(:, :, index));
                proportionComplete = index / frameCount;
                if mod(proportionComplete, 0.01) < proportionDelta
                    cancel = multiWaitbar(taskName, proportionComplete);
                end
                if cancel
                    break;
                end
            end

            centers = PointStructurer.mergePoints(centers);
            multiWaitbar(taskName, 'Close');
        end
    end
end
