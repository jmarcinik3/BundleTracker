classdef SettingsParser
    properties (Constant)
        filepath = "Settings/settings.json";
    end

    methods (Static)
        function angleMode = getAngleModeDefaults()
            angleMode = namedargs2cell(getDefaults().AngleDropdown);
        end
        function invert = getInvertCheckboxDefaults()
            invert = namedargs2cell(getDefaults().InvertCheckbox);
        end
        function positiveDirection = getDefaultPositiveDirection()
            positiveDirection = getDefaults().PositiveDirection;
        end
        function thresholds = getThresholdSliderDefaults()
            thresholds = namedargs2cell(getDefaults().ThresholdSlider);
            thresholds{2} = thresholds{2}';
        end
        function trackingMode = getTrackingModeDefaults()
            trackingMode = namedargs2cell(getDefaults().TrackingDropdown);
        end

        function angleMode = getDefaultAngleMode()
            angleMode = getDefaults().AngleDropdown.Value;
        end
        function invert = getDefaultInvert()
            invert = getDefaults().InvertCheckbox.Value;
        end
        function thresholds = getDefaultThresholds()
            thresholds = getDefaults().ThresholdSlider.Value';
        end
        function trackingMode = getDefaultTrackingMode()
            trackingMode = getDefaults().TrackingDropdown.Value;
        end

        function color = getRegionDefaults()
            color = namedargs2cell(getDefaults().Region);
        end
        function color = getRegionQueueColor()
            color = getAesthetics().Region.QueueColor;
        end
        function color = getRegionTrackedColor()
            color = getAesthetics().Region.TrackedColor;
        end
    end
end


function defaults = getDefaults()
info = toStruct();
defaults = info.Defaults;
end

function defaults = getAesthetics()
info = toStruct();
defaults = info.Aesthetics;
end

function info = toStruct()
filepath = SettingsParser.filepath;
fileId = fopen(filepath);
fileContents = char(fread(fileId, inf)');
fclose(fileId);
info = jsondecode(fileContents);
end
