classdef SettingsParser
    properties (Constant)
        filepath = "Settings/settings.json";
    end

    methods (Static)
        function defaults = getAngleModeDefaults()
            defaults = namedargs2cell(getDefaults().AngleDropdown);
        end
        function defaults = getDetrendModeDefaults()
            defaults = namedargs2cell(getDefaults().DetrendDropdown);
        end
        function defaults = getInvertCheckboxDefaults()
            defaults = namedargs2cell(getDefaults().InvertCheckbox);
        end
        function defaults = getSmoothingSliderDefaults()
            defaults = namedargs2cell(getDefaults().SmoothingSlider);
        end
        function defaults = getThresholdModeDropdownDefaults()
            defaults = namedargs2cell(getDefaults().ThresholdModeDropdown);
        end
        function defaults = getThresholdSliderDefaults()
            defaults = namedargs2cell(getDefaults().ThresholdSlider);
        end
        function defaults = getTrackingModeDefaults()
            defaults = namedargs2cell(getDefaults().TrackingDropdown);
        end

        function defaults = getScaleFactorDefaults()
            defaults = namedargs2cell(getDefaults().ScaleFactorField);
        end
        function defaults = getScaleFactorErrorDefaults()
            defaults = namedargs2cell(getDefaults().ScaleFactorErrorField);
        end

        function angleMode = getDefaultAngleMode()
            angleMode = getDefaults().AngleDropdown.Value;
        end
        function angleMode = getDefaultDetrendMode()
            angleMode = getDefaults().DetrendDropdown.Value;
        end
        function invert = getDefaultInvert()
            invert = getDefaults().InvertCheckbox.Value;
        end
        function defaults = getDefaultPositiveDirection()
            defaults = getDefaults().PositiveDirection;
        end
        function thresholds = getDefaultThresholds()
            thresholds = getDefaults().ThresholdSlider.Value;
        end
        function trackingMode = getDefaultTrackingMode()
            trackingMode = getDefaults().TrackingDropdown.Value;
        end

        function filename = getDefaultImageFilename()
            filename = getFilenames().Image;
        end
        function filename = getDefaultResultsFilename()
            filename = getFilenames().Results;
        end

        function color = getRegionDefaults()
            color = namedargs2cell(getDefaults().Region);
        end
        function color = getRegionDefaultColor()
            color = getDefaults().Region.Color;
        end
        function color = getRegionQueueColor()
            color = getAesthetics().Region.QueueColor;
        end
        function color = getRegionTrackedColor()
            color = getAesthetics().Region.TrackedColor;
        end

        function defaults = getColormapAesthetics()
            defaults = { ...
                SettingsParser.getColormapDarkColor(), ...
                SettingsParser.getColormapName(), ...
                SettingsParser.getColormapsBrightColor() ...
                };
        end
        function rgb = getColormapDarkColor()
            rgb = getAesthetics().Colormap.Dark;
        end
        function colormapName = getColormapName()
            colormapName = getAesthetics().Colormap.Middle;
        end
        function rgb = getColormapBrightColor()
            rgb = getAesthetics().Colormap.Bright.';
        end

        function defaults = getTrackingFigureDefaults()
            defaults = getDefaults().TrackingFigure;
        end
        function defaults = getTrackingCompletedFigureDefaults()
            defaults = getDefaults().TrackingCompletedFigure;
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

function filenames = getFilenames()
info = toStruct();
filenames = info.Filenames;
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
