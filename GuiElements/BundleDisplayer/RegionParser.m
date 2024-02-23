classdef RegionParser
    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>
        region;
    end
    methods
        function obj = RegionParser(region)
            obj.region = region;
        end
    end

    %% Function to retreive state infomration or generate objects
    methods
        function region = getRegion(obj)
            region = obj.region;
        end
        function thresholds = getThresholds(obj)
            region = obj.getRegion();
            thresholds = region.UserData.IntensityRange;
        end
        function invert = getInvert(obj)
            region = obj.getRegion();
            invert = region.UserData.IsInverted;
        end

        function processor = generatePreprocessor(obj)
            thresholds = obj.getThresholds();
            invert = obj.getInvert();
            processor = Preprocessor(thresholds, invert);
            processor = @processor.preprocess;
        end
    end

    %% Functions to set state information
    methods
        function setThresholds(obj, thresholds)
            region = obj.getRegion();
            region.UserData.IntensityRange = thresholds;
        end
        function setInvert(obj, invert)
            region = obj.getRegion();
            region.UserData.IsInverted = invert;
        end
    end
end

