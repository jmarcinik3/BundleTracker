classdef RegionPreviewer < RectangleDrawer
    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>
        imageGui;
        regionGui;
    end

    methods
        function obj = RegionPreviewer(imageGui, regionGui)
            ax = imageGui.getAxis();
            obj@RectangleDrawer(ax, @imageGui.getRegionUserData);
            
            iIm = imageGui.getInteractiveImage();
            set(iIm, "ButtonDownFcn", @obj.buttonDownFcn); % draw rectangles on image
            obj.imageGui = imageGui;
            obj.regionGui = regionGui;
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods (Access = protected)
        function gui = getImageGui(obj)
            gui = obj.imageGui;
        end
        function gui = getRegionGui(obj)
            gui = obj.regionGui;
        end
        function rects = getRegions(obj)
            % Retrieves currently drawn regions on image
            imageGui = obj.getImageGui();
            ax =  imageGui.getAxis();
            rects = getRegions(ax);
        end
    end

    %% Functions to update state of GUI
    methods (Access = protected)
        function changeFullImage(obj, im)
            imageGui = obj.getImageGui();
            regionGui = obj.getRegionGui();
            imageGui.changeImage(im);
            regionGui.setRawImage([]);
        end
        function clearRegions(obj)
            % Removes currently drawn regions on image
            regions = obj.getRegions();
            delete(regions);
        end
    end
    methods (Access = private)
        function buttonDownFcn(obj, source, event)
            if isLeftClick(event)
                rect = obj.generateRectangle(source, event);
                obj.previewGeneratedRegion(rect);
            end
        end
        function previewGeneratedRegion(obj, region)
            obj.addListeners(region);
            obj.setPreviewRegion(region);
        end

        function addListeners(obj, region)
            addlistener(region, "ROIClicked", @obj.regionClicked);
            addlistener(region, "MovingROI", @obj.regionMoving);
        end
        function regionMoving(obj, source, ~)
            obj.setPreviewRegion(source);
        end
        function regionClicked(obj, source, event)
            if isLeftClick(event)
                obj.setPreviewRegion(source);
            end
        end

        function setPreviewRegion(obj, region)
            regionGui = obj.getRegionGui();
            regionRawImage = obj.getRegionalRawImage(region);
            regionGui.setRegion(region, regionRawImage);
            obj.updateRegionColors(region);
        end
        function regionRawImage = getRegionalRawImage(obj, region)
            imageGui = obj.getImageGui();
            im = imageGui.getRawImage();
            regionRawImage = unpaddedMatrixInRegion(region, im);
        end

        function updateRegionColors(obj, activeRegion)
            regions = obj.getRegions();
            updateRegionColors(activeRegion, regions);
        end
    end
end



function is = isLeftClick(event)
name = event.EventName;
if name == "ROIClicked"
    is = event.SelectionType == "left";
elseif name == "Hit"
    is = event.Button == 1;
end
end

function rects = getRegions(ax)
children = ax.Children;
rects = findobj(children, "Type", "images.roi.rectangle");
rects = flip(rects);
end
function updateRegionColors(activeRegion, regions)
set(regions, "Color", RegionColor.unprocessedColor);
set(activeRegion, "Color", RegionColor.workingColor);
end
