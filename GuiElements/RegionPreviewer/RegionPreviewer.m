classdef RegionPreviewer < RegionDrawer & RegionVisibler
    properties (Constant)
        resetTitle = "Reset to Default";
    end

    properties (Access = private)
        imageLinker;
        regionLinker;
        regionCounter = 1;
    end

    methods
        function obj = RegionPreviewer(regionGui, imageGui)
            imageLinker = ImageLinker(imageGui);
            ax = imageGui.getAxis();
            fullRawImage = imageLinker.getRawImage();

            obj@RegionVisibler(ax, regionGui);
            obj@RegionDrawer(ax, @imageGui.getRegionUserData);

            RegionMoverLinker(regionGui.getRegionMoverGui(), obj);
            RegionCompressorLinker(regionGui.getRegionCompressorGui(), obj);
            RegionExpanderLinker(regionGui.getRegionExpanderGui(), obj);

            obj.imageLinker = ImageLinker(imageGui);
            obj.regionLinker = RegionLinker(regionGui, fullRawImage);

            configureInteractiveImage(obj, imageGui);
            obj.regionLinker.updateRegionalRawImage([]);
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function regions = getRegions(obj)
            regions = getRegions@RegionVisibler(obj);
        end
    end
    methods (Access = protected)
        function linker = getImageLinker(obj)
            linker = obj.imageLinker;
        end
        function linker = getRegionLinker(obj)
            linker = obj.regionLinker;
        end
        function ax = getAxis(obj)
            ax = getAxis@RegionDrawer(obj);
        end
    end
    methods (Access = ?RegionChanger)
        function gui = getRegionGui(obj)
            gui = obj.regionLinker.getRegionGui();
        end
    end

    %% Functions to update state of GUI
    methods
        function resetRegionsToDefaults(obj, regions, keyword)
            if nargin == 2
                keyword = RegionUserData.allKeyword;
            end
            if obj.regionExists()
                arrayfun(@(region) resetRegionToDefaults(region, keyword), regions);
            end
        end

        function importRegionsFromFile(obj, filepath)
            resultsParser = ResultsParser(filepath);
            importRegionsFromInfo(obj, resultsParser);
        end

        function drawRegionsByParameters(obj, parameters, blobShape)
            drawRegionsByParameters(obj, parameters, blobShape);
        end

        function changeImage(obj, im)
            obj.clearRegions();
            obj.imageLinker.changeImage(im);
            obj.regionLinker.changeImage(im);
        end
        function previewRegion(obj, region)
            previewRegion@RegionVisibler(obj, region);
            RegionChanger.region(obj);
            obj.regionLinker.updateRegionalRawImage(region);
        end
    end
    methods (Access = ?RegionGuiConfigurer)
        function buttonDownFcn(obj, source, event)
            if isLeftClick(event)
                region = obj.drawRegionOnClick(source, event);
                configureRegionToGui(obj, region);
            end
        end
        function regionClicked(obj, source, event)
            if isDoubleClick(event)
                obj.resetRegionsToDefaults(source);
            end
            obj.previewRegion(source);
        end
        function regionMoving(obj, source, ~)
            obj.regionLinker.updateRegionalRawImage(source);
        end
        function deletingRegion(obj, source, ~)
            activeRegion = obj.getActiveRegion();
            if ~obj.multipleRegionsExist()
                obj.regionLinker.updateRegionalRawImage([]);
            elseif activeRegion == source
                obj.setPreviousRegionVisible();
            end
        end
    end
    methods (Access = ?RegionChanger)
        function thresholdSliderChanged(obj, source, event)
            obj.regionLinker.thresholdSliderChanged(source, event)
        end
        function invertCheckboxChanged(obj, source, event)
            obj.regionLinker.invertCheckboxChanged(source, event)
        end
    end
end



function configureInteractiveImage(obj, imageGui)
iIm = imageGui.getInteractiveImage();
set(iIm, "ButtonDownFcn", @obj.buttonDownFcn);
end

function configureRegionToGui(obj, region)
regionGui = obj.getRegionGui();
RegionGuiConfigurer.configure(obj, regionGui, region);
obj.previewRegion(region);
end

function resetRegionToDefaults(region, keyword)
regionUserData = RegionUserData.fromRegion(region);
regionUserData.resetToDefaults(keyword);
end

function drawRegionsByParameters(obj, parameters, blobShape)
taskName = ['Drawing ', blobShape, 's'];
multiWaitbar(taskName, 0, 'CanCancel', 'on');
regionCount = size(parameters, 1);
regions = images.roi.Rectangle.empty(0, regionCount);

    function region = drawRegionByParameters(index)
        parameter = parameters(index, :);
        region = obj.drawRegionByParameters(parameter, blobShape);
        configureRegionToGui(obj, region);
    end

    function cancel = updateWaitbar(index)
        proportionComplete = index / regionCount;
        cancel = multiWaitbar(taskName, proportionComplete);
    end

for index = 1:regionCount
    region = drawRegionByParameters(index);
    regions(index) = region;
    if updateWaitbar(index)
        deleteRegions(regions);
        break;
    end
end

multiWaitbar(taskName, 'Close');
end

function importRegionsFromInfo(obj, resultsParser)
taskName = 'Importing Regions';
multiWaitbar(taskName, 0, 'CanCancel', 'on');
regionCount = resultsParser.getRegionCount();
regions = images.roi.Rectangle.empty(0, regionCount);

    function region = importRegionFromInfo(index)
        regionInfo = resultsParser.getRegion(index);
        region = obj.importRegion(regionInfo);
        configureRegionToGui(obj, region);
        RegionUserData.configureByResultsParser(region, resultsParser, index);
    end

    function cancel = updateWaitbar(index)
        proportionComplete = index / regionCount;
        cancel = multiWaitbar(taskName, proportionComplete);
    end

for index = 1:regionCount
    region = importRegionFromInfo(index);
    regions(index) = region;
    if updateWaitbar(index)
        deleteRegions(regions);
        break;
    end
end

multiWaitbar(taskName, 'Close');
end

function is = isDoubleClick(event)
selectionType = event.SelectionType;
is = selectionType == "double";
end
function is = isLeftClick(event)
name = event.EventName;
switch name
    case "ROIClicked"
        selectionType = event.SelectionType;
        is = selectionType == "left" ...
            || selectionType == "shift" ...
            || selectionType == "ctrl";
    case "Hit"
        is = event.Button == 1;
end
end
