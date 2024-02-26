classdef RegionAdjustKey < ArrowKey  
    properties (Access = private, Constant)
        space = "space";
    end
    
    methods (Static)
        function isRegionAdjustKey = is(key)
            isArrowKey = ArrowKey.is(key);
            isSpaceKey = RegionAdjustKey.isSpace(key);
            isRegionAdjustKey = isArrowKey || isSpaceKey;
        end

        function is = isSpace(key)
            is = strcmp(key, RegionAdjustKey.space);
        end
    end
end

