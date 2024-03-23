classdef RegionPreviewer < RegionDrawer & RegionVisibler
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

    %% Functions to retrieve GUI elements
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
        function drawRectanglesByPositions(obj, positions)
            drawRectanglesByPositions(obj, positions);
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

function drawRectanglesByPositions(obj, positions)
taskName = 'Drawing Rectangles';

multiWaitbar(taskName, 0, 'CanCancel', 'on');
rectCount = size(positions, 1);
rects = {};

for index = 1:rectCount
    position = positions(index, :);
    rect = drawRectangleByPosition(obj, position);
    rects{index} = rect; %#ok<AGROW>

    proportionComplete = index / rectCount;
    if multiWaitbar(taskName, proportionComplete)
        deleteRegions(rects);
        break;
    end
end

multiWaitbar(taskName, 'Close');
end

function rect = drawRectangleByPosition(obj, position)
rect = obj.drawRectangleByPosition(position);
obj.generateRegionLinker(rect);
drawnow();
pause(0.1);
end

function is = isLeftClick(event)
name = event.EventName;
if name == "Hit"
    is = event.Button == 1;
end
end
