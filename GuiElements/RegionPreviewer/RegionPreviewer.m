classdef RegionPreviewer < RegionDrawer & RegionVisibler
    properties (Access = private)
        axis;
        imageLinker;
        regionLinker;
    end

    methods
        function obj = RegionPreviewer(regionGui, imageGui)
            ax = imageGui.getAxis();
            obj@RegionVisibler(regionGui);
            obj@RegionDrawer;

            RegionMoverLinker(regionGui.getRegionMoverGui(), obj);
            RegionCompressorLinker(regionGui.getRegionCompressorGui(), obj);
            RegionExpanderLinker(regionGui.getRegionExpanderGui(), obj);

            set(imageGui.getInteractiveImage(), "ButtonDownFcn", @obj.buttonDownFcn);

            imageLinker = ImageLinker(imageGui);
            obj.imageLinker = imageLinker;
            obj.regionLinker = RegionLinker(regionGui, imageLinker.getRawImage());
            obj.axis = ax;

            obj.updateRegionalRawImage([]);
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function regions = getRegions(obj)
            regions = getRegions@RegionVisibler(obj);
        end
    end
    methods (Access = protected)
        function ax = getAxis(obj)
            ax = obj.axis;
        end
    end

    %% Functions to update state of GUI
    methods
        function resetRegionsToDefaults(obj, regions, keyword)
            if nargin == 2
                keyword = RegionUserData.allKeyword;
            end
            if obj.regionExists()
                arrayfun( ...
                    @(region) RegionUserData(region).resetToDefaults(keyword), ...
                    regions ...
                    );
            end
        end
        function importRegions(obj, filepath)
            resultsParser = ResultsParser(filepath);
            taskName = 'Importing Regions';
            multiWaitbar(taskName, 0, 'CanCancel', 'on');
            regionCount = resultsParser.getRegionCount();
            regions = images.roi.Rectangle.empty(0, regionCount);

            for index = 1:regionCount
                regionInfo = resultsParser.getRegion(index);
                region = obj.importRegion(regionInfo);
                configureRegionToGui(obj, region);
                RegionUserData.configureByResultsParser(region, resultsParser, index);
                regions(index) = region;

                proportionComplete = index / regionCount;
                if multiWaitbar(taskName, proportionComplete)
                    deleteRegions(regions);
                    break;
                end
            end

            multiWaitbar(taskName, 'Close');
        end
        function previewRegion(obj, region)
            previewRegion@RegionVisibler(obj, region);
            regionChanged(obj);
            obj.updateRegionalRawImage(region);
        end
    end
    methods (Access = protected)
        function setMaximumIntensity(obj, maxIntensity)
            obj.imageLinker.setMaximumIntensity(maxIntensity);
            obj.regionLinker.setMaximumIntensity(maxIntensity);
        end
        function changeImage(obj, im)
            obj.clearRegions();
            obj.imageLinker.changeImage(im);
            obj.regionLinker.changeImage(im);
        end

        function drawRegionsByParameters(obj, parameters, blobShape)
            taskName = ['Drawing ', blobShape, 's'];
            multiWaitbar(taskName, 0, 'CanCancel', 'on');
            regionCount = size(parameters, 1);
            regions = images.roi.Rectangle.empty(0, regionCount);

            for index = 1:regionCount
                parameter = parameters(index, :);
                region = obj.drawRegionByParameters(parameter, blobShape);
                configureRegionToGui(obj, region);
                regions(index) = region;

                proportionComplete = index / regionCount;
                if multiWaitbar(taskName, proportionComplete)
                    deleteRegions(regions);
                    break;
                end
            end

            multiWaitbar(taskName, 'Close');
        end
    end
    methods (Access = private)
        function buttonDownFcn(obj, source, event)
            if event.Button == 1 % is left click
                region = obj.drawRegionOnClick(source, event);
                configureRegionToGui(obj, region);
            end
        end
        function regionClicked(obj, source, event)
            if event.SelectionType == "double"
                obj.resetRegionsToDefaults(source);
            end
            obj.previewRegion(source);
        end
        function regionMoving(obj, source, ~)
            obj.updateRegionalRawImage(source);
        end
        function deletingRegion(obj, source, ~)
            activeRegion = obj.getActiveRegion();
            if ~obj.multipleRegionsExist()
                obj.updateRegionalRawImage([]);
            elseif activeRegion == source
                obj.setPreviousRegionVisible();
            end
        end

        function thresholdChanged(obj, source, event)
            switch event.EventName
                case "ValueChanged"
                    if obj.regionExists()
                        RegionUserData(obj).setThresholds(event.Value);
                    end
                case "PostSet"
                    thresholdParserChanged(obj, source, event);
            end
        end
        function invertChanged(obj, source, event)
            switch event.EventName
                case "ValueChanged"
                    RegionUserData(obj).setInvert(event.Value);
                case "PostSet"
                    invertParserChanged(obj, source, event);
            end
        end
        function trackingModeChanged(obj, source, event)
            switch event.EventName
                case "ValueChanged"
                    RegionUserData(obj).setTrackingMode(event.Value);
                case "PostSet"
                    trackingModeParserChanged(obj, source, event);
            end
        end
        function angleModeChanged(obj, source, event)
            switch event.EventName
                case "ValueChanged"
                    RegionUserData(obj).setAngleMode(event.Value);
                case "PostSet"
                    angleModeParserChanged(obj, source, event);
            end
        end
        function positiveDirectionChanged(obj, source, event)
            switch event.EventName
                case "SelectionChanged"
                    direction = DirectionGui.buttonToLocation(get(source, "SelectedObject"));
                    RegionUserData(obj).setPositiveDirection(direction);
                case "PostSet"
                    directionParserChanged(obj, source, event);
            end
        end
    end

    %% Helper functions to call methods from properties
    methods
        function exportImage(obj, path)
            obj.imageLinker.exportImage(path);
        end
        function gui = getRegionGui(obj)
            gui = obj.regionLinker.getRegionGui();
        end
        function updateRegionalRawImage(obj, region)
            obj.regionLinker.updateRegionalRawImage(region);
        end
        function thresholdSliderChanged(obj, source, event)
            obj.regionLinker.thresholdSliderChanged(source, event);
        end
        function invertCheckboxChanged(obj, source, event)
            obj.regionLinker.invertCheckboxChanged(source, event);
        end
    end
    methods (Access = protected)
        function userData = getRegionUserData(obj)
            imageGui = obj.imageLinker.getGui();
            userData = imageGui.getRegionUserData();
        end
    end
end



function configureRegionToGui(obj, region)
regionIs1d = ~sum(region.createMask(), "all");
if regionIs1d
    deleteRegions(region);
    return;
end

regionGui = obj.getRegionGui();
configureRegionGui(obj, regionGui, region);
obj.previewRegion(region);
end

function configureRegionGui(previewer, gui, region)
directionGui = gui.getDirectionGui();
regionUserData = RegionUserData(region);

configureRegion(previewer, region);
configureThreshold(previewer, gui, regionUserData);
configureInvert(previewer, gui, regionUserData);
configureTrackingMode(previewer, gui, regionUserData);
configureAngleMode(previewer, gui, regionUserData);
configurePositiveDirection(previewer, directionGui, regionUserData);
end
function configureThreshold(previewer, gui, regionUserData)
set(gui.getThresholdSlider(), ...
    "ValueChangedFcn", @previewer.thresholdChanged, ...
    "Value", regionUserData.getThresholds() ...
    );
addlistener(regionUserData, "IntensityRange", "PostSet", @previewer.thresholdChanged);
end
function configureInvert(previewer, gui, regionUserData)
set(gui.getInvertCheckbox(), ...
    "ValueChangedFcn", @previewer.invertChanged, ...
    "Value", regionUserData.getInvert() ...
    );
addlistener(regionUserData, "IsInverted", "PostSet", @previewer.invertChanged);
end
function configureTrackingMode(previewer, gui, regionUserData)
set(gui.getTrackingSelectionElement(), ...
    "ValueChangedFcn", @previewer.trackingModeChanged, ...
    "Value", regionUserData.getTrackingMode() ...
    );
addlistener(regionUserData, "TrackingMode", "PostSet", @previewer.trackingModeChanged);
end
function configureAngleMode(previewer, gui, regionUserData)
set(gui.getAngleSelectionElement(), ...
    "ValueChangedFcn", @previewer.angleModeChanged, ...
    "Value", regionUserData.getAngleMode() ...
    );
addlistener(regionUserData, "AngleMode", "PostSet", @previewer.angleModeChanged);
end
function configurePositiveDirection(previewer, directionGui, regionUserData)
changedFcn = @previewer.positiveDirectionChanged;
set(directionGui.getRadioGroup(), "SelectionChangedFcn", changedFcn);
directionGui.setLocation(regionUserData.getPositiveDirection());
addlistener(regionUserData, "Direction", "PostSet", changedFcn);
end
function configureRegion(previewer, region)
addlistener(region, "MovingROI", @previewer.regionMoving);
addlistener(region, "ROIMoved", @previewer.regionMoving);
addlistener(region, "ROIClicked", @previewer.regionClicked);
addlistener(region, "DeletingROI", @previewer.deletingRegion);
end



function regionChanged(previewer)
thresholdParserChanged(previewer);
invertParserChanged(previewer);
trackingModeParserChanged(previewer);
angleModeParserChanged(previewer);
directionParserChanged(previewer);
end

function thresholdParserChanged(previewer, ~, ~)
thresholdSlider = previewer.getRegionGui().getThresholdSlider();

thresholds = RegionUserData(previewer).getThresholds();
thresholds(1) = max(thresholds(1), thresholdSlider.Limits(1));
thresholds(2) = min(thresholds(2), thresholdSlider.Limits(2));
set(thresholdSlider, "Value", thresholds);
previewer.thresholdSliderChanged(thresholdSlider, []);
end

function invertParserChanged(previewer, ~, ~)
invertCheckbox = previewer.getRegionGui().getInvertCheckbox();
set(invertCheckbox, ...
    "Value", RegionUserData(previewer).getInvert() ...
    );
previewer.invertCheckboxChanged(invertCheckbox, [])
end
function trackingModeParserChanged(previewer, ~, ~)
set(previewer.getRegionGui().getTrackingSelectionElement(), ...
    "Value", RegionUserData(previewer).getTrackingMode() ...
    );
end
function angleModeParserChanged(previewer, ~, ~)
set(previewer.getRegionGui().getAngleSelectionElement(), ...
    "Value", RegionUserData(previewer).getAngleMode() ...
    );
end
function directionParserChanged(previewer, ~, ~)
direction = RegionUserData(previewer).getPositiveDirection();
directionGui = previewer.getRegionGui().getDirectionGui();
directionGui.setLocation(direction);
end
