classdef RegionParser
    properties (Constant)
        labelKeyword = "Label";
        intensityKeyword = "IntensityRange";
        invertKeyword = "IsInverted";
    end

    properties (Access = private)
        region;
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
        function thresholds = getThresholds(obj)
            region = obj.getRegion();
            keyword = RegionParser.intensityKeyword;
            thresholds = region.UserData.(keyword);
        end
        function invert = getInvert(obj)
            region = obj.getRegion();
            keyword = RegionParser.invertKeyword;
            invert = region.UserData.(keyword);
        end
        function label = getLabel(obj)
            region = obj.getRegion();
            label = region.Label;
        end
    end

    %% Functions to set state information
    methods
        function setThresholds(obj, thresholds)
            region = obj.getRegion();
            keyword = RegionParser.intensityKeyword;
            region.UserData.(keyword) = thresholds;
        end
        function setInvert(obj, invert)
            region = obj.getRegion();
            keyword = RegionParser.invertKeyword;
            region.UserData.(keyword) = invert;
        end
        function results = appendMetadata(obj, results)
            results.(RegionParser.labelKeyword) = obj.getLabel();
            results.Region = obj.getRegion();
            results.(RegionParser.intensityKeyword) = obj.getThresholds();
            results.(RegionParser.invertKeyword) = obj.getInvert();
        end
    end
end
