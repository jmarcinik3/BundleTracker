classdef RegionLinkerContainer < handle
    properties
        getAxis;
    end

    properties (Access = private)
        tagCounter = 0;
        tag2linker = dictionary;
        
        parent;
        changeImage;
    end    

    methods
        function obj = RegionLinkerContainer(imageLinker, regionGuiParent)
            imageGui = imageLinker.getGui();
            % inherited functions
            obj.getAxis = @imageGui.getAxis;
            obj.changeImage = @imageLinker.changeImage;

            obj.parent = regionGuiParent;
        end
    end

    %% Functions to generate GUI elements
    methods
        function regionGui = generateRegionGui(obj)
            parent = obj.getRegionGuiParent();
            gl = RegionGui.generateGridLayout(parent);
            regionGui = RegionGui(gl);
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function regions = getRegions(obj)
            ax =  obj.getAxis();
            regions = RegionDrawer.getRegions(ax);
        end
        function linker = getRegionLinker(obj, region)
            tag = get(region, "Tag");
            linker = obj.tag2linker(tag);
        end
        function linkers = getRegionLinkers(obj)
            if isConfigured(obj.tag2linker)
                linkers = values(obj.tag2linker);
            else
                linkers = [];
            end
        end
    end
    methods (Access = private)
        function parent = getRegionGuiParent(obj)
            parent = obj.parent;
        end
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
            arrayfun(@(region) region.notify("DeletingROI"), regions);
            delete(regions);
        end
    end

    %% Functions to update state information
    methods
        function addRegionEntry(obj, regionLinker)
            region = regionLinker.getRegion();
            addlistener(region, "DeletingROI", @obj.deletingRegion);
            
            tag = obj.iterateTag();
            set(region, "Tag", tag);
            obj.tag2linker(tag) = regionLinker;
        end
    end
    methods (Access = private)
        function tag = iterateTag(obj)
            tagCounter = obj.tagCounter + 1;
            obj.tagCounter = tagCounter;
            tag = num2str(tagCounter);
        end
        function deletingRegion(obj, source, ~)
            obj.removeRegionEntry(source);
        end
        function removeRegionEntry(obj, region)
            tag = get(region, "Tag");
            obj.tag2linker = remove(obj.tag2linker, tag);
        end
    end
end

