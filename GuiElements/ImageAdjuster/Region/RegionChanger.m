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
regionUserData = RegionUserData.fromRegionLinker(linker);
regionUserData.setThresholds(thresholds);
end
function thresholdParserChanged(linker, ~, event)
regionUserData = RegionUserData.fromRegionLinker(linker);
thresholds = regionUserData.getThresholds();
thresholdSlider = linker.gui.getThresholdSlider();
set(thresholdSlider, "Value", thresholds);
linker.thresholdSliderChanged(thresholdSlider, event);
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
regionUserData = RegionUserData.fromRegionLinker(linker);
invert = event.Value;
regionUserData.setInvert(invert);
linker.invertCheckboxChanged(source, event);
end
function invertParserChanged(linker, ~, event)
regionUserData = RegionUserData.fromRegionLinker(linker);
invert = regionUserData.getInvert();
invertCheckbox = linker.gui.getInvertCheckbox();
set(invertCheckbox, "Value", invert);
linker.invertCheckboxChanged(invertCheckbox, event);
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
regionUserData = RegionUserData.fromRegionLinker(linker);
trackingMode = event.Value;
regionUserData.setTrackingMode(trackingMode);
end
function trackingModeParserChanged(linker, ~, ~)
regionUserData = RegionUserData.fromRegionLinker(linker);
trackingMode = regionUserData.getTrackingMode();
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
regionUserData = RegionUserData.fromRegionLinker(linker);
angleMode = event.Value;
regionUserData.setAngleMode(angleMode);
end
function angleModeParserChanged(linker, ~, ~)
regionUserData = RegionUserData.fromRegionLinker(linker);
angleMode = regionUserData.getAngleMode();
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
regionUserData = RegionUserData.fromRegionLinker(linker);
selectedButton = get(source, "SelectedObject");
direction = DirectionGui.buttonToLocation(selectedButton);
regionUserData.setPositiveDirection(direction);
end
function directionParserChanged(linker, ~, ~)
regionUserData = RegionUserData.fromRegionLinker(linker);
direction = regionUserData.getPositiveDirection();
directionGui = linker.gui.getDirectionGui();
directionGui.setLocation(direction);
end
