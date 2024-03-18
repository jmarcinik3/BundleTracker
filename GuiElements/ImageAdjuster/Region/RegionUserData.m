classdef RegionUserData < handle
    properties (SetObservable)
        IntensityRange;
        IsInverted;
        TrackingMode;
        AngleMode;
        Direction;
    end

    methods
        function obj = RegionUserData()
        end
    end

    methods (Static)
        function obj = fromRegion(region)
            obj = region.UserData;
        end
        function obj = fromRegionLinker(regionLinker)
            region = regionLinker.getRegion();
            obj = RegionUserData.fromRegion(region);
        end
    end

    %% Functions to generate state information
    methods
        function result = appendMetadata(obj, result)
            result.IntensityRange = obj.IntensityRange;
            result.IsInverted = obj.IsInverted;
            result.TrackingMode = obj.TrackingMode;
            result.AngleMode = obj.AngleMode;
            result.Direction = obj.Direction;
        end
    end

    %% Functions to retrive state information
    methods
        function thresholds = getThresholds(obj)
            thresholds = obj.IntensityRange;
        end
        function invert = getInvert(obj)
            invert = obj.IsInverted;
        end
        function trackingMode = getTrackingMode(obj)
            trackingMode = obj.TrackingMode;
        end
        function angleMode = getAngleMode(obj)
            angleMode = obj.AngleMode;
        end
        function positiveDirection = getPositiveDirection(obj)
            positiveDirection = obj.Direction;
        end
    end

    %% Functions to set state information
    methods
        function setThresholds(obj, thresholds)
            obj.IntensityRange = thresholds;
        end
        function setInvert(obj, invert)
            obj.IsInverted = invert;
        end
        function setTrackingMode(obj, trackingMode)
            obj.TrackingMode = trackingMode;
        end
        function setAngleMode(obj, angleMode)
            obj.AngleMode = angleMode;
        end
        function setPositiveDirection(obj, positiveDirection)
            obj.Direction = positiveDirection;
        end
    end
end
