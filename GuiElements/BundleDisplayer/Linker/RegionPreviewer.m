classdef RegionPreviewer < RegionDrawer
    properties (Access = private, Constant)
        regionGuiLocation = {2, 1};
    end

    properties (Access = private)
        gridLayout;

        getRawImage;
        getRegionGui
        getRegionGuis;
        
        generateRegionGui;
        addRegionEntry;
    end

    properties
        getRegions;
        changeFullImage;
    end

    methods
        function obj = RegionPreviewer(imageGui, regionGuiGridLayout, regionGuiLocation)
            regionPreviewGui = RegionPreviewGui( ...
                imageGui, ...
                regionGuiGridLayout, ...
                regionGuiLocation ...
                );
            
            ax = imageGui.getAxis();
            iIm = imageGui.getInteractiveImage();

            obj@RegionDrawer(ax, @imageGui.getRegionUserData);

            % inherited functions
            obj.getRawImage = @imageGui.getRawImage;
            obj.getRegions = @regionPreviewGui.getRegions;
            obj.getRegionGui = @regionPreviewGui.getRegionGui;
            obj.getRegionGuis = @regionPreviewGui.getRegionGuis;

            obj.changeFullImage = @regionPreviewGui.changeFullImage;
            obj.generateRegionGui = @regionPreviewGui.generateRegionGui;
            obj.addRegionEntry = @regionPreviewGui.addRegionEntry;

            set(iIm, "ButtonDownFcn", @obj.buttonDownFcn); % draw rectangles on image
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
            addlistener(region, "DeletingROI", @obj.deletingRegion);
        end
        function regionClicked(obj, source, event)
            if isLeftClick(event)
                obj.previewRegion(source);
            end
        end

        function previewRegion(obj, region)
            obj.updateRegionGuiVisible(region);
            updateRegionColors(region);
        end
        function updateRegionGuiVisible(obj, activeRegion)
            regionGui = obj.getRegionGui(activeRegion);
            regionGuis = obj.getRegionGuis();
            arrayfun(@(gui) gui.setVisible(false), regionGuis);
            regionGui.setVisible(true);
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

function updateRegionColors(activeRegion)
ax = ancestor(activeRegion, "axes");
regions = RegionDrawer.getRegions(ax);
set(regions, "Color", RegionColor.unprocessedColor);
set(activeRegion, "Color", RegionColor.workingColor);
end
