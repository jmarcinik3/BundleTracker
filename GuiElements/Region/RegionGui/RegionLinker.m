classdef RegionLinker < PreprocessorLinker & AxisExporter
    properties (Access = private)
        fullRawImage;
        regionGui;
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

    %% Functions to update GUI and state information
    methods
        function changeImage(obj, im)
            obj.fullRawImage = im;
        end
    end
    methods (Access = ?RegionPreviewer)
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
        end
    end

    %% Helper functions to call methods from properties
    methods (Access = private)
        function ax = getAxis(obj)
            ax = obj.regionGui.getAxis();
        end
    end
end
