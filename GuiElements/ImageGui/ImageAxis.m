classdef ImageAxis < AxisExporter & AxisZoomer
    methods
        function obj = ImageAxis(iIm)      
            ax = ancestor(iIm, "axes");
            obj@AxisExporter(ax);
            obj@AxisZoomer(ax);
            AxisResizer(iIm);
        end
    end

    %% Functions to update state of GUI
    methods (Access = protected)
        function fig = getFigure(obj)
            fig = getFigure@AxisZoomer(obj);
        end
        function ax = getAxis(obj)
            ax = getAxis@AxisZoomer(obj);
        end
    end
end
