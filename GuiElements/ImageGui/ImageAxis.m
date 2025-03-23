classdef ImageAxis < AxisExporter & AxisPanZoomer
    methods
        function obj = ImageAxis(iIm)      
            ax = ancestor(iIm, "axes");
            obj@AxisExporter(ax);
            obj@AxisPanZoomer(ax);
            AxisResizer(iIm);
        end
    end

    %% Functions to update state of GUI
    methods (Access = protected)
        function fig = getFigure(obj)
            fig = getFigure@AxisPanZoomer(obj);
        end
        function ax = getAxis(obj)
            ax = getAxis@AxisPanZoomer(obj);
        end
    end
end
