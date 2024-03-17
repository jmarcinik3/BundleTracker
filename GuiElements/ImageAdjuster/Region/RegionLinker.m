classdef RegionLinker < PreprocessorLinker & RegionParser
    properties (Access = private)
        fullRawImage;
    end
    properties (Access = ?RegionChanger)
        gui;
    end

    methods
        function obj = RegionLinker(regionGui, region, fullRawImage)
            regionMoverGui = regionGui.getRegionMoverGui();
            regionCompressorGui = regionGui.getRegionCompressorGui();
            regionExpanderGui = regionGui.getRegionExpanderGui();

            RegionMoverLinker(regionMoverGui, region);
            RegionCompressorLinker(regionCompressorGui, region);
            RegionExpanderLinker(regionExpanderGui, region);
            obj@RegionParser(region);
            obj@PreprocessorLinker(regionGui);

            iIm = regionGui.getInteractiveImage();
            AxisResizer(iIm, "FitToContent", true);

            % own properties
            obj.gui = regionGui;
            obj.fullRawImage = fullRawImage;

            % configure GUI elements, must come last
            RegionGuiConfigurer.configure(obj, regionGui, obj);
            obj.updateRegionalRawImage();
        end
    end

    %% Functions to generate GUI elements
    methods (Access = private)
        function regionRawImage = generateRegionalRawImage(obj)
            fullRawImage = obj.fullRawImage;
            region = obj.getRegion();
            regionRawImage = MatrixUnpadder.byRegion2d(region, fullRawImage);
        end
    end

    %% Functions to set state of GUI
    methods
        function setVisible(obj, visible)
            gl = obj.gui.getGridLayout();
            set(gl, "Visible", visible);
        end
    end

    %% Functions to update GUI and state information
    methods (Access = ?RegionGuiConfigurer)
        function regionMoving(obj, ~, ~)
            obj.updateRegionalRawImage();
        end
        function deletingRegion(obj, ~, ~)
            delete(obj.gui);
        end
    end
    methods (Access = private)
        function updateRegionalRawImage(obj)
            regionRawImage = obj.generateRegionalRawImage();
            obj.setRawImage(regionRawImage);
        end
    end
end
