classdef RegionGuiConfigurer
    methods (Static, Access = ?RegionLinker)
        function configure(linker, gui, parser)
            configureRegionGui(linker, gui, parser);
        end
    end
end



function configureRegionGui(linker, gui, parser)
directionGui = gui.getDirectionGui();
region = parser.getRegion();
changer = RegionChanger(linker);

configureRegion(linker, region);
configureThreshold(changer, gui, parser);
configureInvert(changer, gui, parser);
configureTrackingMode(changer, gui, parser);
configureAngleMode(changer, gui, parser);
configurePositiveDirection(changer, directionGui, parser);
end

function configureThreshold(changer, gui, parser)
thresholds = parser.getThresholds();
thresholdSlider = gui.getThresholdSlider();
set(thresholdSlider, ...
    "ValueChangedFcn", @changer.threshold, ...
    "Value", thresholds ...
    );
addlistener(parser, "Thresholds", "PostSet", @changer.threshold);
end

function configureInvert(changer, gui, parser)
invert = parser.getInvert();
invertCheckbox = gui.getInvertCheckbox();
set(invertCheckbox, ...
    "ValueChangedFcn", @changer.invert, ...
    "Value", invert ...
    );
addlistener(parser, "Invert", "PostSet", @changer.invert);
end

function configureTrackingMode(changer, gui, parser)
trackingMode = parser.getTrackingMode();
trackingSelection = gui.getTrackingSelectionElement();
set(trackingSelection, ...
    "ValueChangedFcn", @changer.trackingMode, ...
    "Value", trackingMode ...
    );
addlistener(parser, "TrackingMode", "PostSet", @changer.trackingMode);
end

function configureAngleMode(changer, gui, parser)
angleMode = parser.getAngleMode();
angleSelection = gui.getAngleSelectionElement();
set(angleSelection, ...
    "ValueChangedFcn", @changer.angleMode, ...
    "Value", angleMode ...
    );
addlistener(parser, "AngleMode", "PostSet", @changer.angleMode);
end

function configurePositiveDirection(changer, directionGui, parser)
direction = parser.getPositiveDirection();
directionElement = directionGui.getRadioGroup();
set(directionElement, "SelectionChangedFcn", @changer.positiveDirection);
directionGui.setLocation(direction);
addlistener(parser, "PositiveDirection", "PostSet", @changer.positiveDirection);
end

function configureRegion(obj, region)
addlistener(region, "MovingROI", @obj.regionMoving);
addlistener(region, "ROIMoved", @obj.regionMoving);
addlistener(region, "DeletingROI", @obj.deletingRegion);
end
