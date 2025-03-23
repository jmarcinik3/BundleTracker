classdef AxisPanZoomer < AxisPanner & AxisZoomer
    methods
        function obj = AxisPanZoomer(ax)
            obj@AxisPanner(ax);
            obj@AxisZoomer(ax);
        end
    end
end



