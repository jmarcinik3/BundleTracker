classdef RegionLinker < PreprocessorLinker
    properties (Access = private)
        fullRawImage;
        gui;
        regionParser;
    end

    methods
        function obj = RegionLinker(regionGui, region, fullRawImage)
            regionMoverGui = regionGui.getRegionMoverGui();
            regionCompressorGui = regionGui.getRegionCompressorGui();
            regionExpanderGui = regionGui.getRegionExpanderGui();

            RegionMoverLinker(regionMoverGui, region);
            RegionCompressorLinker(regionCompressorGui, region);
            RegionExpanderLinker(regionExpanderGui, region);
            regionParser = RegionParser(region);
            obj@PreprocessorLinker(regionGui);

            iIm = regionGui.getInteractiveImage();
            AxisResizer(iIm, "FitToContent", true);

            addlistener(region, "UserData", "PostSet", @obj.regionUserDataChanged);

            % own properties
            obj.gui = regionGui;
            obj.regionParser = regionParser;
            obj.fullRawImage = fullRawImage;

            % configure GUI elements, must come last
            configureRegion(obj, region);
            configureThresholdSlider(obj, regionGui, regionParser);
            configureInvertCheckbox(obj, regionGui, regionParser);
            configureTrackingSelection(obj, regionGui, regionParser);
            configureAngleSelection(obj, regionGui, regionParser);
            configureDirection(obj, regionGui.getDirectionGui(), regionParser);
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
        function thresholdSliderChanged(obj, ~, event)
            thresholds = event.Value;
            obj.regionParser.setThresholds(thresholds);
        end
        function invertCheckboxChanged(obj, ~, event)
            invert = event.Value;
            obj.regionParser.setInvert(invert);
        end

        function trackingModeChanged(obj, ~, event)
            trackingMode = event.Value;
            obj.regionParser.setTrackingMode(trackingMode);
        end
        function angleModeChanged(obj, ~, event)
            angleMode = event.Value;
            obj.regionParser.setAngleMode(angleMode);
        end
        function directionChanged(obj, source, ~)
            selectedButton = get(source, "SelectedObject");
            direction = DirectionGui.buttonToLocation(selectedButton);
            obj.regionParser.setPositiveDirection(direction);
        end

        function regionUserDataChanged(obj, ~, ~)
            regionParser = obj.regionParser;
            gui = obj.gui;

            thresholds = regionParser.getThresholds();
            linkParserIntoGui(regionParser, gui);
            obj.updateFromRawImage(thresholds);
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



function linkParserIntoGui(regionParser, regionGui)
thresholds = regionParser.getThresholds();
invert = regionParser.getInvert();
set(regionGui.getThresholdSlider(), "Value", thresholds);
end


%% Functions to configure GUI elements
function configureThresholdSlider(obj, gui, regionParser)
thresholds = regionParser.getThresholds();
thresholdSlider = gui.getThresholdSlider();
set(thresholdSlider, ...
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
