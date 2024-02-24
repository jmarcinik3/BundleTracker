classdef RegionPreviewer < RectangleDrawer
    properties (Access = private)
        %#ok<*PROPLC>
        imageGui;
        regionGui;
    end

    methods
        function obj = RegionPreviewer(fullGui, regionGui)
            ax = fullGui.getAxis();
            obj@RectangleDrawer(ax, @fullGui.getRegionUserData);
            
            iIm = fullGui.getInteractiveImage();
            set(iIm, "ButtonDownFcn", @obj.buttonDownFcn); % draw rectangles on image
            obj.imageGui = fullGui;
            obj.regionGui = regionGui;
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function gui = getImageGui(obj)
            gui = obj.imageGui;
        end
        function gui = getRegionGui(obj)
            gui = obj.regionGui;
        end
    end

    %% Function to update state of GUI
    methods
        function changeFullImage(obj, im)
            imageGui = obj.getImageGui();
            regionGui = obj.getRegionGui();
            imageGui.changeImage(im);
            regionGui.setRawImage([]);
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
            addlistener(region, "MovingROI", @obj.regionMoving);
            addlistener(region, "ROIClicked", @obj.regionClicked);
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
        end
        function regionRawImage = getRegionalRawImage(obj, region)
            imageGui = obj.getImageGui();
            im = imageGui.getRawImage();
            regionRawImage = unpaddedMatrixInRegion(region, im);
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
