classdef RegionPreviewer < RegionDrawer & RegionVisibler
    properties (Access = protected)
        imageLinker;
    end

    methods
        function obj = RegionPreviewer(imageLinker, regionGuiParent)
            imageGui = imageLinker.getGui();
            ax = imageGui.getAxis();
            obj@RegionVisibler(imageLinker, regionGuiParent);
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
    methods (Access = private)
        function im = getRawImage(obj)
            im = obj.imageLinker.getRawImage();
        end
    end

    %% Functions to update state of GUI
    methods
        function appendRectanglesByPositions(obj, positions)
            rectCount = size(positions, 1);
            for index = 1:rectCount
                position = positions(index, :);
                rect = obj.rectangleByPosition(position);
                obj.generateRegionLinker(rect);
            end
        end
        function changeFullImage(obj, im)
            obj.clearRegions();
            obj.imageLinker.changeImage(im);
        end
    end
    methods (Access = private)
        function buttonDownFcn(obj, source, event)
            if isLeftClick(event)
                region = obj.generateRegion(source, event);
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
            if isLeftClick(event)
                obj.previewRegion(source);
            end
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

function is = isLeftClick(event)
name = event.EventName;
if name == "ROIClicked"
    is = event.SelectionType == "left";
elseif name == "Hit"
    is = event.Button == 1;
end
end
