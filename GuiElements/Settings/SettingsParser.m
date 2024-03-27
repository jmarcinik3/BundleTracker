classdef SettingsParser
    properties (Constant)
        filepath = "Settings/settings.json";
    end

    methods (Static)
        function angleMode = getDefaultAngleMode()
            angleMode = getDefaults().AngleMode;
        end
        function invert = getDefaultInvert()
            invert = getDefaults().InvertCheckbox;
        end
        function positiveDirection = getDefaultPositiveDirection()
            positiveDirection = getDefaults().PositiveDirection;
        end
        function thresholds = getDefaultThresholds()
            thresholds = getDefaults().Thresholds';
        end
        function trackingMode = getDefaultTrackingMode()
            trackingMode = getDefaults().TrackingMode;
        end

        function color = getRegionLabelColor()
            color = getAesthetics().Region.LabelColor;
        end
        function color = getRegionActiveColor()
            color = getAesthetics().Region.ActiveColor;
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
