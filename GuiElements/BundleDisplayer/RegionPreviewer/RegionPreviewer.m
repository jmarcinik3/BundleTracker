classdef RegionPreviewer < RegionDrawer & RegionVisibler

    properties (Access = private)
        getRawImage;
    end

    methods
        function obj = RegionPreviewer(imageGui, regionGuiParent)
            ax = imageGui.getAxis();
            iIm = imageGui.getInteractiveImage();

            obj@RegionVisibler(imageGui, regionGuiParent);
            obj@RegionDrawer(ax, @imageGui.getRegionUserData);

            % inherited functions
            obj.getRawImage = @imageGui.getRawImage;

            set(iIm, "ButtonDownFcn", @obj.buttonDownFcn); % draw rectangles on image
        end
    end

    methods
        function regions = getRegions(obj)
            regions  = getRegions@RegionLinkerContainer(obj);
        end
    end

    %% Functions to generate GUI elements
    methods (Access = private)
        function regionLinker = generateRegionLinker(obj, region)
            fullRawImage = obj.getRawImage();
            regionGui = obj.generateRegionGui();
            regionLinker = RegionLinker(regionGui, region, fullRawImage);
            obj.addRegionEntry(regionLinker);
        end
    end

    %% Functions to update state of GUI
    methods (Access = private)
        function buttonDownFcn(obj, source, event)
            if isLeftClick(event)
                region = obj.generateRegion(source, event);
                obj.generateRegionLinker(region);
                obj.addListeners(region);
                obj.previewRegion(region);
            end
        end
        function addListeners(obj, region)
            addlistener(region, "ROIClicked", @obj.regionClicked);
        end

        function regionClicked(obj, source, event)
            if isLeftClick(event)
                obj.previewRegion(source);
            end
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
