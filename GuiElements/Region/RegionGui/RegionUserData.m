classdef RegionUserData < handle
    properties (Constant)
        allKeyword = "All";
        keywords = [ ...
            RegionUserData.allKeyword, ...
            RegionUserData.angleModeKeyword, ...
            RegionUserData.detrendModeKeyword, ...
            RegionUserData.invertKeyword, ...
            RegionUserData.positiveDirectionKeyword, ...
            RegionUserData.smoothingKeyword, ...
            RegionUserData.thresholdsKeyword, ...
            RegionUserData.trackingModeKeyword ...
            ];
    end
    properties (Constant, Access = private)
        angleModeKeyword = "Angle Mode";
        detrendModeKeyword = "Detrend Mode";
        invertKeyword = "Invert";
        positiveDirectionKeyword = "Positive Direction";
        smoothingKeyword = "Smoothing";
        thresholdsKeyword = "Thresholds";
        trackingModeKeyword = "Tracking Mode";
    end

    properties (SetObservable)
        Smoothing;
        IntensityRange;
        IsInverted;

        TrackingMode;
        AngleMode;
        DetrendMode;
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
            elseif isa(arg, "RegionUserData")
                obj = arg;
            end
        end
    end

    %% Functions to generate state information
    methods
        function result = appendMetadata(obj, result)
            result.Smoothing = obj.Smoothing;
            result.IntensityRange = obj.IntensityRange;
            result.IsInverted = obj.IsInverted;
            result.TrackingMode = obj.TrackingMode;
            result.AngleMode = obj.AngleMode;
            result.DetrendMode = obj.DetrendMode;
            result.Direction = obj.Direction;
        end
    end

    %% Functions to retrieve state information
    methods
        function value = getByKeyword(obj, keyword)
            switch keyword
                case RegionUserData.angleModeKeyword
                    value = obj.getAngleMode();
                case RegionUserData.detrendModeKeyword
                    value = obj.getDetrendMode();
                case RegionUserData.invertKeyword
                    value = obj.getInvert();
                case RegionUserData.positiveDirectionKeyword
                    value = obj.getPositiveDirection();
                case RegionUserData.smoothingKeyword
                    value = obj.getSmoothing();
                case RegionUserData.thresholdsKeyword
                    value = obj.getThresholds();
                case RegionUserData.trackingModeKeyword
                    value = obj.getTrackingMode();
            end
        end

        function angleMode = getAngleMode(obj)
            angleMode = obj.AngleMode;
        end
        function detrendMode = getDetrendMode(obj)
            detrendMode = obj.DetrendMode;
        end
        function invert = getInvert(obj)
            invert = obj.IsInverted;
        end
        function positiveDirection = getPositiveDirection(obj)
            positiveDirection = obj.Direction;
        end
        function smoothing = getSmoothing(obj)
            smoothing = obj.Smoothing;
        end
        function thresholds = getThresholds(obj)
            thresholds = obj.IntensityRange;
        end
        function trackingMode = getTrackingMode(obj)
            trackingMode = obj.TrackingMode;
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
            regionUserData.setSmoothing(parser.getSmoothingWidth(index));
            regionUserData.setThresholds(parser.getIntensityRange(index));
            regionUserData.setInvert(parser.pixelsAreInverted(index));
            regionUserData.setTrackingMode(parser.getTrackingMode(index));
            regionUserData.setAngleMode(parser.getAngleMode(index));
            regionUserData.setDetrendMode(parser.getDetrendMode(index));
            regionUserData.setPositiveDirection(parser.getPositiveDirection(index));
        end
        function newUserData = configureByRegion(newRegion, oldRegion)
            newUserData = RegionUserData(newRegion);
            oldUserData = RegionUserData(oldRegion);
            keywords = RegionUserData.keywords(2:end);

            for keyword = keywords
                oldValue = oldUserData.getByKeyword(keyword);
                if numel(oldValue) >= 1
                    newUserData.setByKeyword(keyword, oldValue);
                end
            end
        end
    end
    methods
        function setByKeyword(obj, keyword, value)
            switch keyword
                case RegionUserData.angleModeKeyword
                    obj.setAngleMode(value);
                case RegionUserData.detrendModeKeyword
                    obj.setDetrendMode(value);
                case RegionUserData.invertKeyword
                    obj.setInvert(value);
                case RegionUserData.positiveDirectionKeyword
                    obj.setPositiveDirection(value);
                case RegionUserData.smoothingKeyword
                    obj.setSmoothing(value);
                case RegionUserData.thresholdsKeyword
                    obj.setThresholds(value);
                case RegionUserData.trackingModeKeyword
                    obj.setTrackingMode(value);
            end
        end

        function setThresholds(obj, thresholds)
            obj.IntensityRange = thresholds;
        end
        function setLowerThreshold(obj, threshold)
            obj.IntensityRange(1) = threshold;
        end
        function setUpperThreshold(obj, threshold)
            obj.IntensityRange(2) = threshold;
        end

        function setSmoothing(obj, smoothing)
            obj.Smoothing = smoothing;
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
        function setDetrendMode(obj, detrendMode)
            obj.DetrendMode = string(detrendMode);
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

function resetByKeyword(obj, keywords)
keywordCount = numel(keywords);
if keywordCount >= 2
    for keyword = keywords
        resetByKeyword(obj, keyword);
    end
    return;
end

switch keywords
    case RegionUserData.angleModeKeyword
        obj.setAngleMode(SettingsParser.getDefaultAngleMode());
    case RegionUserData.detrendModeKeyword
        obj.setDetrendMode(SettingsParser.getDefaultDetrendMode());
    case RegionUserData.invertKeyword
        obj.setInvert(SettingsParser.getDefaultInvert());
    case RegionUserData.positiveDirectionKeyword
        obj.setPositiveDirection(SettingsParser.getDefaultPositiveDirection());
    case RegionUserData.smoothingKeyword
        obj.setSmoothing(0);
    case RegionUserData.thresholdsKeyword
        obj.setThresholds(SettingsParser.getDefaultThresholds());
    case RegionUserData.trackingModeKeyword
        obj.setTrackingMode(SettingsParser.getDefaultTrackingMode());
    case RegionUserData.allKeyword
        resetByKeyword(obj, RegionUserData.keywords(2:end));
end
end
