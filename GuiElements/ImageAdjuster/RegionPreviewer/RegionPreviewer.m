classdef RegionPreviewer < RegionDrawer & RegionVisibler
    properties (Constant)
        resetTitle = "Reset to Default";
    end

    properties (Access = protected)
        imageLinker;
    end

    methods
        function obj = RegionPreviewer(imageLinker, regionGuiParent)
            imageGui = imageLinker.getGui();
            ax = imageGui.getAxis();
            obj@RegionVisibler(ax, regionGuiParent);
            obj@RegionDrawer(ax, @imageGui.getRegionUserData);

            configureInteractiveImage(obj, imageGui);
            obj.imageLinker = imageLinker;
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods
        function regions = getRegions(obj)
            regions  = getRegions@RegionVisibler(obj);
        end
    end
    methods (Access = protected)
        function ax = getAxis(obj)
            ax = getAxis@RegionDrawer(obj);
        end
    end
    methods (Access = private)
        function im = getRawImage(obj)
            im = obj.imageLinker.getRawImage();
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

        function drawRegionsByParameters(obj, parameters, blobShape)
            drawRegionsByParameters(obj, parameters, blobShape);
        end
        function changeFullImage(obj, im)
            obj.clearRegions();
            obj.imageLinker.changeImage(im);
        end
    end
    methods (Access = private)
        function buttonDownFcn(obj, source, event)
            if isLeftClick(event)
                region = obj.drawRegionOnClick(source, event);
                obj.generateRegionLinker(region);
            end
        end
        function generateRegionLinker(obj, region)
            regionLinker = generateRegionLinker(obj, region);
            obj.addRegionEntry(regionLinker);
            configureRegion(obj, region);
            obj.previewRegion(region);
        end

        function regionClicked(obj, source, event)
            if isDoubleClick(event)
                obj.resetRegionsToDefaults(source);
            end
            obj.previewRegion(source);
        end

        function deletingRegion(obj, source, ~)
            activeRegion = obj.getActiveRegion();
            if activeRegion == source
                obj.setPreviousRegionVisible();
            end
        end
    end
end



function configureInteractiveImage(obj, imageGui)
iIm = imageGui.getInteractiveImage();
set(iIm, "ButtonDownFcn", @obj.buttonDownFcn); % draw rectangles on image
end

function configureRegion(obj, region)
addlistener(region, "ROIClicked", @obj.regionClicked);
addlistener(region, "DeletingROI", @obj.deletingRegion);
end

function regionLinker = generateRegionLinker(obj, region)
fullRawImage = obj.getRawImage();
regionGui = obj.generateRegionGui();
regionLinker = RegionLinker(regionGui, region, fullRawImage);
end

function resetRegionToDefaults(region, keyword)
regionUserData = RegionUserData.fromRegion(region);
regionUserData.resetToDefaults(keyword);
end



function drawRegionsByParameters(obj, parameters, blobShape)
taskName = ['Drawing ', blobShape, 's'];
multiWaitbar(taskName, 0, 'CanCancel', 'on');
regionCount = size(parameters, 1);
regions = {};

for index = 1:regionCount
    parameter = parameters(index, :);
    region = drawRegionByParameters(obj, parameter, blobShape);
    regions{index} = region; %#ok<AGROW>

    proportionComplete = index / regionCount;
    if multiWaitbar(taskName, proportionComplete)
        deleteRegions(regions);
        break;
    end
end

multiWaitbar(taskName, 'Close');
end

function region = drawRegionByParameters(obj, parameters, blobShape)
region = obj.drawRegionByParameters(parameters, blobShape);
obj.generateRegionLinker(region);
drawnow();
pause(0.1);
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
