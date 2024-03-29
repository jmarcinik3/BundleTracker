classdef RegionAdjuster
    properties (Constant)
        length = 48;
    end

    properties (Access = private)
        previewer;
    end

    methods
        function obj = RegionAdjuster(previewer)
            obj.previewer = previewer;
        end
    end

    methods (Access = protected)
        function region = getRegion(obj)
            region = obj.previewer;
            if RegionType.isRegion(region)
            elseif isa(region, "RegionPreviewer")
                region = region.getActiveRegion();
            end
        end
        function performAction(obj, action)
            region = obj.getRegion();
            action(region);
            region.notify("ROIMoved");
        end
    end
end



