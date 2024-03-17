classdef RegionChanger < RegionLinker
    methods (Static)
        function threshold(linker, source, event)
            thresholdChanged(linker, source, event);
        end
        function invert(linker, source, event)
            invertChanged(linker, source, event);
        end
        function trackingMode(linker, source, event)
            trackingModeChanged(linker, source, event);
        end
        function angleMode(linker, source, event)
            angleModeChanged(linker, source, event);
        end
        function positiveDirection(linker, source, event)
            positiveDirectionChanged(linker, source, event);
        end
    end
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
