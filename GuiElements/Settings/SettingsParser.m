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

        function defaults = getTrackingFigureDefaults()
            defaults = getDefaults().TrackingFigure;
        end
        function defaults = getBlobDetectionFigureDefaults()
            defaults = getDefaults().BlobDetectionFigure;
        end
        function defaults = getAutothresholdFigureDefaults()
            defaults = getDefaults().AutothresholdFigure;
        end

        function label = getExportAxisLabel()
            label = getMenuLabels().ExportAxisImage;
        end
        function label = getImportRegionsLabel()
            label = getMenuLabels().ImportRegions;
        end
        function label = getImportVideoLabel()
            label = getMenuLabels().ImportVideo;
        end
        function label = getOpenDirectoryLabel()
            label = getMenuLabels().OpenDirectory;
        end
        function label = getResetRegionLabel()
            label = getMenuLabels().ResetRegion;
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

function labels = getMenuLabels()
info = toStruct();
labels = info.Menu.Labels;
end

function info = toStruct()
filepath = SettingsParser.filepath;
fileId = fopen(filepath);
fileContents = char(fread(fileId, inf)');
fclose(fileId);
info = jsondecode(fileContents);
end
