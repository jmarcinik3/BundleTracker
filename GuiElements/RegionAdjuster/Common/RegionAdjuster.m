classdef RegionAdjuster
    properties (Constant)
        length = 48;
    end

    properties (Access = private)
        region;
    end

    methods
        function obj = RegionAdjuster(region)
            obj.region = region;
        end
    end

    methods (Access = protected)
        function region = getRegion(obj)
            region = obj.region;
        end
        function performAction(obj, action)
            region = obj.getRegion();
            action(region);
            region.notify("ROIMoved");
        end
    end
end



