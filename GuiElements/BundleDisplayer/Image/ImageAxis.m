classdef ImageAxis < AxisExporter & AxisPanZoomer
    methods
        function obj = ImageAxis(ax, iIm)            
            obj@AxisExporter(ax);
            obj@AxisPanZoomer(ax);
            AxisResizer(iIm);
            configureInteractiveImage(obj, iIm);
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



function configureInteractiveImage(obj, iIm)
addlistener(iIm, "CData", "PostSet", @obj.cDataChanged);
end
