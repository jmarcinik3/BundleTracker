classdef RegionPreviewGui < handle
    properties
        getAxis;
    end

    properties (Access = private)
        tagCounter = 0;
        tag2linker = dictionary;
        location;
        
        gridLayout;
        imageGui;

        getRawImage;
        changeImage;
    end    

    methods
        function obj = RegionPreviewGui(imageGui, regionGuiGridLayout, location)
            % inherited functions
            obj.getAxis = @imageGui.getAxis;
            obj.getRawImage = @imageGui.getRawImage;
            obj.changeImage = @imageGui.changeImage;

            obj.location = location;
            obj.gridLayout = regionGuiGridLayout;
            obj.imageGui = imageGui;
        end
    end

    %% Functions to generate GUI elements
    methods
        function regionGui = generateRegionGui(obj)
            gl = obj.getGridLayout();
            location = obj.location;
            regionGui = RegionGui(gl, location);
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function regions = getRegions(obj)
            ax =  obj.getAxis();
            regions = RegionDrawer.getRegions(ax);
        end
        function gui = getRegionGui(obj, region)
            tag = get(region, "Tag");
            gui = obj.tag2linker(tag);
        end
        function guis = getRegionGuis(obj)
            guis = values(obj.tag2linker);
        end
    end
    methods (Access = private)
        function gui = getImageGui(obj)
            gui = obj.imageGui;
        end
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
    end
    methods (Access = private)
        
    end

    %% Functions to update state of GUI
    methods
        function changeFullImage(obj, im)
            obj.clearRegions();
            obj.changeImage(im);
        end
    end
    methods (Access = private)
        function clearRegions(obj)
            % Removes currently drawn regions on image
            regions = obj.getRegions();
            fakeEvent = struct("EventName", "FakeEvent");
            arrayfun(@(region) obj.deletingRegion(region, fakeEvent), regions);
            delete(regions);
        end
    end

    %% Functions to update state information
    methods
        function addRegionEntry(obj, regionLinker)
            region = regionLinker.getRegion();
            tag = obj.iterateTag();
            set(region, "Tag", tag);
            obj.tag2linker(tag) = regionLinker;
        end
        function deletingRegion(obj, source, event)
            regionGui = obj.getRegionGui(source);
            obj.removeRegionEntry(source);
            regionGui.deletingRegion(source, event);
        end
    end
    methods (Access = private)
        function tag = iterateTag(obj)
            tagCounter = obj.tagCounter + 1;
            obj.tagCounter = tagCounter;
            tag = num2str(tagCounter);
        end
        function removeRegionEntry(obj, region)
            tag = get(region, "Tag");
            obj.tag2linker = remove(obj.tag2linker, tag);
        end
    end
end

