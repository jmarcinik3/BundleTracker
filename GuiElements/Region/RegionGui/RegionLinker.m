classdef RegionLinker < PreprocessorLinker & AxisExporter
    properties (Access = private)
        fullRawImage;
        regionGui;
        arrowLength = 0.75;
    end

    methods
        function obj = RegionLinker(regionGui, fullRawImage)
            ax = regionGui.getAxis();

            obj@PreprocessorLinker(regionGui);
            obj@AxisExporter(ax);
            AxisResizer( ...
                regionGui.getInteractiveImage(), ...
                "FitToContent", true ...
                );

            obj.fullRawImage = fullRawImage;
            obj.regionGui = regionGui;
        end
    end

    %% Functions to retreive GUI elements
    methods
        function gui = getRegionGui(obj)
            gui = obj.regionGui;
        end
    end
    methods (Access = private)
        function arrow = getPositiveDirectionArrow(obj)
            arrow = obj.getRegionGui().getPositiveDirectionArrow();
        end
        function arrow = getArrow(obj)
            arrow = obj.getPositiveDirectionArrow().getArrow();
        end
    end

    %% Functions to update GUI and state information
    methods
        function updateRegionalRawImage(obj, region)
            if isa(region, "images.roi.Rectangle") ...
                    || isa(region, "images.roi.Ellipse") ...
                    || isa(region, "images.roi.Polygon") ...
                    || isa(region, "images.roi.Freehand")
                fullRawImage = obj.fullRawImage;
                regionRawImage = MatrixUnpadder.byRegion2d(region, fullRawImage);
            else
                regionRawImage = [];
            end
            obj.setRawImage(regionRawImage);
            obj.refreshArrow();
        end
    end
    methods (Access = protected)
        function changeImage(obj, im)
            obj.fullRawImage = im;
        end
    end
    methods (Access = private)
        function refreshArrow(obj)
            ax = obj.getAxis();
            arrow = obj.getPositiveDirectionArrow();

            xMid = mean(get(ax, "XLim"));
            yMid = mean(get(ax, "YLim"));
            xyMid = [xMid, yMid];

            newLength = obj.arrowLength * min(xyMid);
            arrow.setPosition(xyMid);
            arrow.setLength(newLength);
        end
    end

    %% Helper functions to call methods from properties
    methods (Access = private)
        function ax = getAxis(obj)
            ax = obj.regionGui.getAxis();
        end
    end
end
