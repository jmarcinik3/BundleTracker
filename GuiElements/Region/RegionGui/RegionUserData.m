classdef RegionUserData < handle
    properties (Constant)
        allKeyword = "All";
        keywords = [ ...
            RegionUserData.allKeyword, ...
            RegionUserData.angleModeKeyword, ...
            RegionUserData.invertKeyword, ...
            RegionUserData.positiveDirectionKeyword, ...
            RegionUserData.thresholdsKeyword, ...
            RegionUserData.trackingModeKeyword ...
            ];
    end
    properties (Constant, Access = private)
        angleModeKeyword = "Angle Mode";
        invertKeyword = "Invert";
        positiveDirectionKeyword = "Positive Direction";
        thresholdsKeyword = "Thresholds";
        trackingModeKeyword = "Tracking Mode";
    end

    properties (SetObservable, Access = private)
        IntensityRange;
        IsInverted;
        TrackingMode;
        AngleMode;
        Direction;
    end

    methods
        function obj = RegionUserData(arg)
            if nargin == 0
            elseif isa(arg, "images.roi.Rectangle") ...
                    || isa(arg, "images.roi.Ellipse") ...
                    || isa(arg, "images.roi.Polygon") ...
                    || isa(arg, "images.roi.Freehand")
                obj = arg.UserData;
            elseif isa(arg, "RegionPreviewer")
                obj = RegionUserData(arg.getActiveRegion());
            end
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

    %% Functions to retrieve state information
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
            if ~isa(regions, "images.roi.Rectangle") ...
                    && ~isa(regions, "images.roi.Ellipse") ...
                    && ~isa(regions, "images.roi.Polygon") ...
                    && ~isa(regions, "images.roi.Freehand")
                regions = regions.getRegions();
            end
            setRegionsThresholds(regions, thresholds);
        end
        function configureByResultsParser(region, parser, index)
            regionUserData = RegionUserData(region);
            regionUserData.setThresholds(parser.getIntensityRange(index));
            regionUserData.setInvert(parser.pixelsAreInverted(index));
            regionUserData.setTrackingMode(parser.getTrackingMode(index));
            regionUserData.setAngleMode(parser.getAngleMode(index));
            regionUserData.setPositiveDirection(parser.getPositiveDirection(index));
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
            obj.TrackingMode = string(trackingMode);
        end
        function setAngleMode(obj, angleMode)
            obj.AngleMode = string(angleMode);
        end
        function setPositiveDirection(obj, positiveDirection)
            obj.Direction = string(positiveDirection);
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
            defaultThresholds = [0, Inf];
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
    RegionUserData(region).setThresholds(newThreshold);
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
