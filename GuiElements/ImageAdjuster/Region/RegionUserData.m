classdef RegionUserData < handle
    properties (Constant)
        allKeyword = "All",
        angleModeKeyword = "Angle Mode";
        invertKeyword = "Invert";
        positiveDirectionKeyword = "Positive Direction";
        thresholdsKeyword = "Thresholds";
        trackingModeKeyword = "Tracking Mode";
        keywords = [ ...
            RegionUserData.allKeyword, ...
            RegionUserData.angleModeKeyword, ...
            RegionUserData.invertKeyword, ...
            RegionUserData.positiveDirectionKeyword, ...
            RegionUserData.thresholdsKeyword, ...
            RegionUserData.trackingModeKeyword ...
            ];
    end

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
            setRegionsThresholds(regions, thresholds);
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
        function resetToDefaults(obj, keyword)
            if nargin == 1
                keyword = RegionUserData.allKeyword;
            end
            resetByKeyword(obj, keyword);
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


function setRegionsThresholds(regions, thresholds)
thresholdCount = size(thresholds, 1);
for index = 1:thresholdCount
    region = regions(index);
    newThreshold = thresholds(index, :);
    regionUserData = RegionUserData.fromRegion(region);
    regionUserData.setThresholds(newThreshold);
end
end

function resetByKeyword(obj, keyword)
switch keyword
    case RegionUserData.angleModeKeyword
        obj.resetToDefaultAngleMode();
    case RegionUserData.invertKeyword
        obj.resetToDefaultInvert();
    case RegionUserData.positiveDirectionKeyword
        obj.resetToDefaultPositiveDirection();
    case RegionUserData.thresholdsKeyword
        obj.resetToDefaultThresholds();
    case RegionUserData.trackingModeKeyword
        obj.resetToDefaultTrackingMode();
    case RegionUserData.allKeyword
        resetToDefaultAll(obj);
end
end

function resetToDefaultAll(obj)
obj.resetToDefaultAngleMode();
obj.resetToDefaultInvert();
obj.resetToDefaultPositiveDirection();
obj.resetToDefaultThresholds();
obj.resetToDefaultTrackingMode();
end
