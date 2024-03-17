classdef RegionChanger
    properties (Access = private)
        linker;
    end

    methods
        function obj = RegionChanger(linker)
            obj.linker = linker;
        end
    end

    methods
        function threshold(obj, source, event)
            linker = obj.linker;
            thresholdChanged(linker, source, event);
        end
        function invert(obj, source, event)
            linker = obj.linker;
            invertChanged(linker, source, event);
        end
        function trackingMode(obj, source, event)
            linker = obj.linker;
            trackingModeChanged(linker, source, event);
        end
        function angleMode(obj, source, event)
            linker = obj.linker;
            angleModeChanged(linker, source, event);
        end
        function positiveDirection(obj, source, event)
            linker = obj.linker;
            positiveDirectionChanged(linker, source, event);
        end
    end
end



function thresholdChanged(linker, source, event)
switch event.EventName
    case "ValueChanged"
        thresholdSliderChanged(linker, source, event)
    case "PostSet"
        thresholdParserChanged(linker, source, event);
end
end
function thresholdSliderChanged(linker, ~, event)
thresholds = event.Value;
linker.setThresholds(thresholds);
end
function thresholdParserChanged(linker, ~, ~)
thresholds = linker.getThresholds();
thresholdSlider = linker.gui.getThresholdSlider();
set(thresholdSlider, "Value", thresholds);
end

function invertChanged(linker, source, event)
switch event.EventName
    case "ValueChanged"
        invertCheckboxChanged(linker, source, event);
    case "PostSet"
        invertParserChanged(linker, source, event);
end
end
function invertCheckboxChanged(linker, source, event)
invert = event.Value;
linker.setInvert(invert);
linker.invertCheckboxChanged(source, event);
end
function invertParserChanged(linker, ~, ~)
thresholds = linker.getInvert();
invertCheckbox = linker.gui.getInvertCheckbox();
set(invertCheckbox, "Value", thresholds);
end

function trackingModeChanged(linker, source, event)
switch event.EventName
    case "ValueChanged"
        trackingModeElementChanged(linker, source, event);
    case "PostSet"
        trackingModeParserChanged(linker, source, event);
end
end
function trackingModeElementChanged(linker, ~, event)
trackingMode = event.Value;
linker.setTrackingMode(trackingMode);
end
function trackingModeParserChanged(linker, ~, ~)
trackingMode = linker.getTrackingMode();
trackingSelection = linker.gui.getTrackingSelectionElement();
set(trackingSelection, "Value", trackingMode);
end

function angleModeChanged(linker, source, event)
switch event.EventName
    case "ValueChanged"
        angleModeElementChanged(linker, source, event);
    case "PostSet"
        angleModeParserChanged(linker, source, event);
end
end
function angleModeElementChanged(linker, ~, event)
angleMode = event.Value;
linker.setAngleMode(angleMode);
end
function angleModeParserChanged(linker, ~, ~)
angleMode = linker.getAngleMode();
angleSelection = linker.gui.getAngleSelectionElement();
set(angleSelection, "Value", angleMode);
end

function positiveDirectionChanged(linker, source, event)
switch event.EventName
    case "SelectionChanged"
        directionElementChanged(linker, source, event);
    case "PostSet"
        directionParserChanged(linker, source, event);
end
end
function directionElementChanged(linker, source, ~)
selectedButton = get(source, "SelectedObject");
direction = DirectionGui.buttonToLocation(selectedButton);
linker.setPositiveDirection(direction);
end
function directionParserChanged(linker, ~, ~)
direction = linker.getPositiveDirection();
directionGui = linker.gui.getDirectionGui();
directionGui.setLocation(direction);
end
