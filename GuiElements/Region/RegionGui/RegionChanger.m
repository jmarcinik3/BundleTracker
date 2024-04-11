classdef RegionChanger
    properties (Access = private)
        previewer;
    end

    methods
        function obj = RegionChanger(previewer)
            obj.previewer = previewer;
        end
    end

    methods
        function threshold(obj, source, event)
            previewer = obj.previewer;
            thresholdChanged(previewer, source, event);
        end
        function invert(obj, source, event)
            previewer = obj.previewer;
            invertChanged(previewer, source, event);
        end
        function trackingMode(obj, source, event)
            previewer = obj.previewer;
            trackingModeChanged(previewer, source, event);
        end
        function angleMode(obj, source, event)
            previewer = obj.previewer;
            angleModeChanged(previewer, source, event);
        end
        function positiveDirection(obj, source, event)
            previewer = obj.previewer;
            positiveDirectionChanged(previewer, source, event);
        end
    end

    methods (Static)
        function region(previewer)
            thresholdParserChanged(previewer);
            invertParserChanged(previewer);
            trackingModeParserChanged(previewer);
            angleModeParserChanged(previewer);
            directionParserChanged(previewer);
        end
    end
end



function thresholdChanged(previewer, source, event)
switch event.EventName
    case "ValueChanged"
        thresholdSliderChanged(previewer, source, event)
    case "PostSet"
        thresholdParserChanged(previewer, source, event);
end
end
function thresholdSliderChanged(previewer, ~, event)
thresholds = event.Value;
region = previewer.getActiveRegion();
if isvalid(region)
    regionUserData = RegionUserData.fromRegion(region);
    regionUserData.setThresholds(thresholds);
end
end
function thresholdParserChanged(previewer, ~, ~)
regionUserData = RegionUserData.fromRegionPreviewer(previewer);
regionGui = previewer.getRegionGui();
thresholdSlider = regionGui.getThresholdSlider();

thresholds = regionUserData.getThresholds();
thresholds(1) = max(thresholds(1), thresholdSlider.Limits(1));
thresholds(2) = min(thresholds(2), thresholdSlider.Limits(2));
set(thresholdSlider, "Value", thresholds);
previewer.thresholdSliderChanged(thresholdSlider, []);
end

function invertChanged(previewer, source, event)
switch event.EventName
    case "ValueChanged"
        invertCheckboxChanged(previewer, source, event);
    case "PostSet"
        invertParserChanged(previewer, source, event);
end
end
function invertCheckboxChanged(previewer, ~, event)
regionUserData = RegionUserData.fromRegionPreviewer(previewer);
invert = event.Value;
regionUserData.setInvert(invert);
end
function invertParserChanged(previewer, ~, ~)
regionUserData = RegionUserData.fromRegionPreviewer(previewer);
regionGui = previewer.getRegionGui();
invert = regionUserData.getInvert();
invertCheckbox = regionGui.getInvertCheckbox();
set(invertCheckbox, "Value", invert);
previewer.invertCheckboxChanged(invertCheckbox, []);
end

function trackingModeChanged(previewer, source, event)
switch event.EventName
    case "ValueChanged"
        trackingModeElementChanged(previewer, source, event);
    case "PostSet"
        trackingModeParserChanged(previewer, source, event);
end
end
function trackingModeElementChanged(previewer, ~, event)
regionUserData = RegionUserData.fromRegionPreviewer(previewer);
trackingMode = event.Value;
regionUserData.setTrackingMode(trackingMode);
end
function trackingModeParserChanged(previewer, ~, ~)
regionUserData = RegionUserData.fromRegionPreviewer(previewer);
regionGui = previewer.getRegionGui();
trackingMode = regionUserData.getTrackingMode();
trackingSelection = regionGui.getTrackingSelectionElement();
set(trackingSelection, "Value", trackingMode);
end

function angleModeChanged(previewer, source, event)
switch event.EventName
    case "ValueChanged"
        angleModeElementChanged(previewer, source, event);
    case "PostSet"
        angleModeParserChanged(previewer, source, event);
end
end
function angleModeElementChanged(previewer, ~, event)
regionUserData = RegionUserData.fromRegionPreviewer(previewer);
angleMode = event.Value;
regionUserData.setAngleMode(angleMode);
end
function angleModeParserChanged(previewer, ~, ~)
regionUserData = RegionUserData.fromRegionPreviewer(previewer);
regionGui = previewer.getRegionGui();
angleMode = regionUserData.getAngleMode();
angleSelection = regionGui.getAngleSelectionElement();
set(angleSelection, "Value", angleMode);
end

function positiveDirectionChanged(previewer, source, event)
switch event.EventName
    case "SelectionChanged"
        directionElementChanged(previewer, source, event);
    case "PostSet"
        directionParserChanged(previewer, source, event);
end
end
function directionElementChanged(previewer, source, ~)
regionUserData = RegionUserData.fromRegionPreviewer(previewer);
selectedButton = get(source, "SelectedObject");
direction = DirectionGui.buttonToLocation(selectedButton);
regionUserData.setPositiveDirection(direction);
end
function directionParserChanged(previewer, ~, ~)
regionUserData = RegionUserData.fromRegionPreviewer(previewer);
regionGui = previewer.getRegionGui();
direction = regionUserData.getPositiveDirection();
directionGui = regionGui.getDirectionGui();
directionGui.setLocation(direction);
end
