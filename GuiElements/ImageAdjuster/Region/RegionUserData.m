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
    methods (Static)
        function setRegionsThresholds(regions, thresholds)
            if ~RegionType.isRegion(regions)
                regions = regions.getRegions();
            end

            thresholdCount = size(thresholds, 1);
            for index = 1:thresholdCount
                region = regions(index);
                newThreshold = thresholds(index, :);
                regionUserData = RegionUserData.fromRegion(region);
                regionUserData.setThresholds(newThreshold);
            end
        end
    end
    methods
        function setThresholds(obj, thresholds)
            obj.IntensityRange = thresholds;
        end
        function setLowerThreshold(obj, threshold)
            obj.IntensityRange(1) = threshold;
        end
        function setUpperThreshold(obj, threshold)
            obj.IntensityRange(2) = threshold;
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

    %% Functions to reset to default state information
    methods
        function resetToDefaults(obj)
            obj.resetToDefaultAngleMode();
            obj.resetToDefaultInvert();
            obj.resetToDefaultPositiveDirection();
            obj.resetToDefaultThresholds();
            obj.resetToDefaultTrackingMode();
        end
        function resetToDefaultAngleMode(obj)
            defaultAngleMode = SettingsParser.getDefaultAngleMode();
            obj.setAngleMode(defaultAngleMode);
        end
        function resetToDefaultInvert(obj)
            defaultInvert = SettingsParser.getDefaultInvert();
            obj.setInvert(defaultInvert);
        end
        function resetToDefaultPositiveDirection(obj)
            defaultPositiveDirection = SettingsParser.getDefaultPositiveDirection();
            obj.setPositiveDirection(defaultPositiveDirection);
        end
        function resetToDefaultThresholds(obj)
            defaultThresholds = SettingsParser.getDefaultThresholds();
            obj.setThresholds(defaultThresholds);
        end
        function resetToDefaultTrackingMode(obj)
            defaultTrackingMode = SettingsParser.getDefaultTrackingMode();
            obj.setTrackingMode(defaultTrackingMode);
        end
    end
end
