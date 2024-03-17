classdef RegionParser < handle
    properties (Constant)
        labelKeyword = "Label";
        intensityKeyword = "IntensityRange";
        invertKeyword = "IsInverted";
        trackingKeyword = "TrackingMode";
        angleKeyword = "AngleMode";
        directionKeyword = "Direction";
        keywords = [ ...
            RegionParser.labelKeyword, ...
            RegionParser.intensityKeyword, ...
            RegionParser.invertKeyword, ...
            RegionParser.trackingKeyword, ...
            RegionParser.angleKeyword, ...
            RegionParser.directionKeyword, ...
            ]
    end

    properties (Access = private)
        region;
    end
    properties (SetObservable, Access = protected)
        Thresholds;
        Invert;
        TrackingMode;
        AngleMode;
        PositiveDirection;
    end

    methods
        function obj = RegionParser(region)
            obj.region = region;
        end
    end

    %% Functions to generate objects
    methods
        function processor = toPreprocessor(obj)
            thresholds = obj.getThresholds();
            invert = obj.getInvert();
            processor = Preprocessor(thresholds, invert);
        end
    end

    %% Functions to retrieve state information
    methods
        function region = getRegion(obj)
            region = obj.region;
        end
        function val = getByKeyword(obj, keyword)
            region = obj.getRegion();
            if keyword == RegionParser.labelKeyword
                val = obj.getLabel();
            else
                val = region.UserData.(keyword);
            end
        end

        function thresholds = getThresholds(obj)
            keyword = RegionParser.intensityKeyword;
            thresholds = obj.getByKeyword(keyword);
        end
        function invert = getInvert(obj)
            keyword = RegionParser.invertKeyword;
            invert = obj.getByKeyword(keyword);
        end
        function trackingMode = getTrackingMode(obj)
            keyword = RegionParser.trackingKeyword;
            trackingMode = obj.getByKeyword(keyword);
        end
        function angleMode = getAngleMode(obj)
            keyword = RegionParser.angleKeyword;
            angleMode = obj.getByKeyword(keyword);
        end
        function direction = getPositiveDirection(obj)
            keyword = RegionParser.directionKeyword;
            direction = obj.getByKeyword(keyword);
        end
        function label = getLabel(obj)
            region = obj.getRegion();
            label = region.Label;
        end
    end

    %% Functions to set state information
    methods
        function setByKeyword(obj, val, keyword)
            region = obj.getRegion();
            region.UserData.(keyword) = val;
        end

        function setThresholds(obj, thresholds)
            keyword = RegionParser.intensityKeyword;
            obj.setByKeyword(thresholds, keyword);
            obj.Thresholds = thresholds;
        end
        function setInvert(obj, invert)
            keyword = RegionParser.invertKeyword;
            obj.setByKeyword(invert, keyword);
            obj.Invert = invert;
        end
        function setTrackingMode(obj, trackingMode)
            keyword = RegionParser.trackingKeyword;
            obj.setByKeyword(trackingMode, keyword);
            obj.TrackingMode = trackingMode;
        end
        function setAngleMode(obj, angleMode)
            keyword = RegionParser.angleKeyword;
            obj.setByKeyword(angleMode, keyword);
            obj.AngleMode = angleMode;
        end
        function setPositiveDirection(obj, positiveDirection)
            keyword = RegionParser.directionKeyword;
            obj.setByKeyword(positiveDirection, keyword);
            obj.PositiveDirection = positiveDirection;
        end

        function results = appendMetadata(obj, results)
            keywords = RegionParser.keywords;
            for index = 1:numel(keywords)
                keyword = keywords(index);
                results.(keyword) = obj.getByKeyword(keyword);
            end
            results.Region = obj.getRegion();
        end
    end
end
