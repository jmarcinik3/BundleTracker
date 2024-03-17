classdef RegionGuiConfigurer < RegionLinker
    methods (Static, Access = ?RegionLinker)
        function configure(linker, gui, parser)
            configureRegionGui(linker, gui, parser);
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
