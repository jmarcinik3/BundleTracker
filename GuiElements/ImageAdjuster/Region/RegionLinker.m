classdef RegionLinker < PreprocessorLinker & RegionParser
    properties (Access = private)
        fullRawImage;
    end
    properties (Access = ?RegionChanged)
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
    methods (Access = protected)
        function thresholdChanged(obj, source, event)
            RegionChanger.threshold(obj, source, event);
        end
        function invertChanged(obj, source, event)
            RegionChanger.invert(obj, source, event);
        end
        function trackingModeChanged(obj, source, event)
            RegionChanger.trackingMode(obj, source, event);
        end
        function angleModeChanged(obj, source, event)
            RegionChanger.angleMode(obj, source, event);
        end
        function positiveDirectionChanged(obj, source, event)
            RegionChanger.positiveDirection(obj, source, event);
        end
    end
    methods (Access = private)
        function regionMoving(obj, ~, ~)
            obj.updateRegionalRawImage();
        end
        function updateRegionalRawImage(obj)
            regionRawImage = obj.generateRegionalRawImage();
            obj.setRawImage(regionRawImage);
        end
        function deletingRegion(obj, ~, ~)
            delete(obj.gui);
        end
    end
end
