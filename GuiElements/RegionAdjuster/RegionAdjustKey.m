classdef RegionAdjustKey < ArrowKey  
    properties (Access = private, Constant)
        space = "space";
        delete = "delete";
    end
    
    methods (Static)
        function isRegionAdjustKey = is(key)
            isRegionAdjustKey = ArrowKey.is(key) ...
                || RegionAdjustKey.isSpace(key) ...
                || RegionAdjustKey.isDelete(key);
        end
        function is = isStandard(key)
            is = ArrowKey.is(key) || RegionAdjustKey.isSpace(key);
        end

        function is = isSpace(key)
            is = strcmp(key, RegionAdjustKey.space);
        end
        function is = isDelete(key)
            is = strcmp(key, RegionAdjustKey.delete);
        end
    end
end

