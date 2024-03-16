classdef RegionLinker < PreprocessorLinker
    properties (Access = private)
        fullRawImage;
        gui;
        regionParser;
    end

    methods
        function obj = RegionLinker(regionGui, region, fullRawImage)
            preprocessorGui = regionGui.getPreprocessorGui();
            postprocessorGui = regionGui.getPostprocessorGui();
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
            configureTrackingSelection(obj, postprocessorGui, regionParser);
            configureAngleSelection(obj, postprocessorGui, regionParser);
            configureDirection(obj, postprocessorGui.getDirectionGui(), regionParser);
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

        function trackingModeChanged(obj, source, ~)
            trackingMode = source.Value;
            obj.regionParser.setTrackingMode(trackingMode);
        end
        function angleModeChanged(obj, source, ~)
            angleMode = source.Value;
            obj.regionParser.setAngleMode(angleMode);
        end
        function directionChanged(obj, source, ~)
            direction = source.Value;
            obj.regionParser.setPositiveDirection(direction);
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

function configureTrackingSelection(obj, gui, regionParser)
trackingMode = regionParser.getTrackingMode();
trackingSelection = gui.getTrackingSelectionElement();
set(trackingSelection, ...
    "ValueChangedFcn", @obj.trackingModeChanged, ...
    "Value", trackingMode ...
    );
end

function configureAngleSelection(obj, gui, regionParser)
angleMode = regionParser.getAngleMode();
angleSelection = gui.getAngleSelectionElement();
set(angleSelection, ...
    "ValueChangedFcn", @obj.angleModeChanged, ...
    "Value", angleMode ...
    );
end

function configureDirection(obj, directionGui, regionParser)
direction = regionParser.getPositiveDirection();
directionElement = directionGui.getRadioGroup();
set(directionElement, "SelectionChangedFcn", @obj.directionChanged);
directionGui.setLocation(direction);
end

function configureRegion(obj, region)
addlistener(region, "MovingROI", @obj.regionMoving);
addlistener(region, "ROIMoved", @obj.regionMoving);
addlistener(region, "DeletingROI", @obj.deletingRegion);
end
