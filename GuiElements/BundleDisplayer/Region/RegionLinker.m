classdef RegionLinker < PreprocessorLinker
    properties (Access = private)
        fullRawImage;
        gui;
        regionParser;
    end

    methods
        function obj = RegionLinker(regionGui, region, fullRawImage)
            preprocessorGui = regionGui.getPreprocessorGui();
            regionMoverGui = regionGui.getRegionMoverGui();
            regionCompressorGui = regionGui.getRegionCompressorGui();
            regionExpanderGui = regionGui.getRegionExpanderGui();

            RegionMoverLinker(regionMoverGui, region);
            RegionCompressorLinker(regionCompressorGui, region);
            RegionExpanderLinker(regionExpanderGui, region);
            regionParser = RegionParser(region);
            obj@PreprocessorLinker(preprocessorGui);

            iIm = preprocessorGui.getInteractiveImage();
            AxisResizer(iIm, "FitToContent", true);

            % own properties
            obj.gui = regionGui;
            obj.regionParser = regionParser;
            obj.fullRawImage = fullRawImage;

            % configure GUI elements, must come last
            configureRegion(obj, region);
            configureThresholdSlider(obj, preprocessorGui, regionParser);
            configureInvertCheckbox(obj, preprocessorGui, regionParser);
            obj.updateRegionalRawImage();
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function region = getRegion(obj)
            region = obj.regionParser.getRegion();
        end
    end

    %% Functions to generate GUI elements
    methods (Access = private)
        function regionRawImage = generateRegionalRawImage(obj)
            fullRawImage = obj.fullRawImage;
            region = obj.regionParser.getRegion();
            regionRawImage = unpaddedMatrixInRegion(region, fullRawImage);
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
        function thresholdSliderChanging(obj, source, event)
            thresholds = event.Value;
            obj.regionParser.setThresholds(thresholds);
            thresholdSliderChanging@PreprocessorLinker(obj, source, event);
        end
        function thresholdSliderChanged(obj, source, event)
            thresholds = source.Value;
            obj.regionParser.setThresholds(thresholds);
            thresholdSliderChanged@PreprocessorLinker(obj, source, event);
        end
        function invertCheckboxChanged(obj, source, event)
            invert = source.Value;
            obj.regionParser.setInvert(invert);
            invertCheckboxChanged@PreprocessorLinker(obj, source, event);
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



%% Functions to configure GUI elements
function configureThresholdSlider(obj, gui, regionParser)
thresholds = regionParser.getThresholds();
thresholdSlider = gui.getThresholdSlider();
set(thresholdSlider, ...
    "ValueChangingFcn", @obj.thresholdSliderChanging, ...
    "ValueChangedFcn", @obj.thresholdSliderChanged, ...
    "Value", thresholds ...
    );
end

function configureInvertCheckbox(obj, gui, regionParser)
invert = regionParser.getInvert();
invertCheckbox = gui.getInvertCheckbox();
set(invertCheckbox, ...
    "ValueChangedFcn", @obj.invertCheckboxChanged, ...
    "Value", invert ...
    );
end

function configureRegion(obj, region)
addlistener(region, "MovingROI", @obj.regionMoving);
addlistener(region, "ROIMoved", @obj.regionMoving);
addlistener(region, "DeletingROI", @obj.deletingRegion);
end
