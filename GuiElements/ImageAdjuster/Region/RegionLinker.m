classdef RegionLinker < PreprocessorLinker & RegionParser
    properties (Access = private)
        fullRawImage;
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
            configureRegionGui(obj, regionGui, obj);
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
            thresholdChanged(obj, source, event);
        end
        function invertChanged(obj, source, event)
            invertChanged(obj, source, event);
        end
        function trackingModeChanged(obj, source, event)
            trackingModeChanged(obj, source, event);
        end
        function angleModeChanged(obj, source, event)
            angleModeChanged(obj, source, event);
        end
        function positiveDirectionChanged(obj, source, event)
            positiveDirectionChanged(obj, source, event);
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



function configureRegionGui(linker, gui, parser)
directionGui = gui.getDirectionGui();
region = parser.getRegion();

configureRegion(linker, region);
configureThreshold(linker, gui, parser);
configureInvert(linker, gui, parser);
configureTrackingMode(linker, gui, parser);
configureAngleMode(linker, gui, parser);
configurePositiveDirection(linker, directionGui, parser);
end

function configureThreshold(obj, gui, regionParser)
thresholds = regionParser.getThresholds();
thresholdSlider = gui.getThresholdSlider();
set(thresholdSlider, ...
    "ValueChangedFcn", @obj.thresholdChanged, ...
    "Value", thresholds ...
    );
addlistener(regionParser, "Thresholds", "PostSet", @obj.thresholdChanged);
end
function configureInvert(obj, gui, regionParser)
invert = regionParser.getInvert();
invertCheckbox = gui.getInvertCheckbox();
set(invertCheckbox, ...
    "ValueChangedFcn", @obj.invertChanged, ...
    "Value", invert ...
    );
addlistener(regionParser, "Invert", "PostSet", @obj.invertChanged);
end
function configureTrackingMode(obj, gui, regionParser)
trackingMode = regionParser.getTrackingMode();
trackingSelection = gui.getTrackingSelectionElement();
set(trackingSelection, ...
    "ValueChangedFcn", @obj.trackingModeChanged, ...
    "Value", trackingMode ...
    );
addlistener(regionParser, "TrackingMode", "PostSet", @obj.trackingModeChanged);
end
function configureAngleMode(obj, gui, regionParser)
angleMode = regionParser.getAngleMode();
angleSelection = gui.getAngleSelectionElement();
set(angleSelection, ...
    "ValueChangedFcn", @obj.angleModeChanged, ...
    "Value", angleMode ...
    );
addlistener(regionParser, "AngleMode", "PostSet", @obj.angleModeChanged);
end
function configurePositiveDirection(obj, directionGui, regionParser)
direction = regionParser.getPositiveDirection();
directionElement = directionGui.getRadioGroup();
set(directionElement, "SelectionChangedFcn", @obj.positiveDirectionChanged);
directionGui.setLocation(direction);
addlistener(regionParser, "PositiveDirection", "PostSet", @obj.positiveDirectionChanged);
end
function configureRegion(obj, region)
addlistener(region, "MovingROI", @obj.regionMoving);
addlistener(region, "ROIMoved", @obj.regionMoving);
addlistener(region, "DeletingROI", @obj.deletingRegion);
end



function thresholdChanged(obj, source, event)
switch event.EventName
    case "ValueChanged"
        thresholdSliderChanged(obj, source, event)
    case "PostSet"
        thresholdParserChanged(obj, source, event);
end
end
function thresholdSliderChanged(obj, ~, event)
thresholds = event.Value;
obj.setThresholds(thresholds);
end
function thresholdParserChanged(obj, ~, ~)
thresholds = obj.getThresholds();
thresholdSlider = obj.gui.getThresholdSlider();
set(thresholdSlider, "Value", thresholds);
end

function invertChanged(obj, source, event)
switch event.EventName
    case "ValueChanged"
        invertCheckboxChanged(obj, source, event);
    case "PostSet"
        invertParserChanged(obj, source, event);
end
end
function invertCheckboxChanged(obj, source, event)
invert = event.Value;
obj.setInvert(invert);
invertCheckboxChanged@PreprocessorLinker(obj, source, event);
end
function invertParserChanged(obj, ~, ~)
thresholds = obj.getInvert();
invertCheckbox = obj.gui.getInvertCheckbox();
set(invertCheckbox, "Value", thresholds);
end

function trackingModeChanged(obj, source, event)
switch event.EventName
    case "ValueChanged"
        trackingModeElementChanged(obj, source, event);
    case "PostSet"
        trackingModeParserChanged(obj, source, event);
end
end
function trackingModeElementChanged(obj, ~, event)
trackingMode = event.Value;
obj.setTrackingMode(trackingMode);
end
function trackingModeParserChanged(obj, ~, ~)
trackingMode = obj.getTrackingMode();
trackingSelection = obj.gui.getTrackingSelectionElement();
set(trackingSelection, "Value", trackingMode);
end

function angleModeChanged(obj, source, event)
switch event.EventName
    case "ValueChanged"
        angleModeElementChanged(obj, source, event);
    case "PostSet"
        angleModeParserChanged(obj, source, event);
end
end
function angleModeElementChanged(obj, ~, event)
angleMode = event.Value;
obj.setAngleMode(angleMode);
end
function angleModeParserChanged(obj, ~, ~)
angleMode = obj.getAngleMode();
angleSelection = obj.gui.getAngleSelectionElement();
set(angleSelection, "Value", angleMode);
end

function positiveDirectionChanged(obj, source, event)
switch event.EventName
    case "SelectionChanged"
        directionElementChanged(obj, source, event);
    case "PostSet"
        directionParserChanged(obj, source, event);
end
end
function directionElementChanged(obj, source, ~)
selectedButton = get(source, "SelectedObject");
direction = DirectionGui.buttonToLocation(selectedButton);
obj.setPositiveDirection(direction);
end
function directionParserChanged(obj, ~, ~)
direction = obj.getPositiveDirection();
directionGui = obj.gui.getDirectionGui();
directionGui.setLocation(direction);
end
