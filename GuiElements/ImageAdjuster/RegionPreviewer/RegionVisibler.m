classdef RegionVisibler < ActiveRegionOrderer & RegionLinkerContainer
    methods
        function obj = RegionVisibler(ax, regionGuiParent)
            obj@ActiveRegionOrderer(ax);
            obj@RegionLinkerContainer(ax, regionGuiParent)
        end
    end

    %% Functions to retrieve state information
    methods (Access = private)
        function adjacentTag = getAdjacentTag(obj, distance)
            regionIndices = obj.getRegionIndices();
            activeIndex = obj.getActiveIndex();
            adjacentIndex = AdjacentFloat.cyclic(regionIndices, activeIndex, distance);
            adjacentTag = num2str(adjacentIndex);
        end
    end

    %% Functions to update state of GUI
    methods
        function clearRegions(obj, ~, ~)
            regions = obj.getRegions();
            deleteRegions(regions);
        end
        function setPreviousRegionVisible(obj, ~, ~)
            obj.setAdjacentRegionVisible(-1);
        end
        function setNextRegionVisible(obj, ~, ~)
            obj.setAdjacentRegionVisible(1);
        end
        function previewRegion(obj, region)
            obj.setActiveRegion(region);
            updateRegionGuiVisible(obj, region);
            RegionDrawer.updateSelected(region);
        end
    end
    methods (Access = private)
        function setAdjacentRegionVisible(obj, distance)
            activeRegion = obj.getActiveRegion();
            if objectIsValid(activeRegion)
                adjacentRegion = getAdjacentRegion(obj, distance);
                obj.previewRegion(adjacentRegion);
            elseif obj.regionExists()
                firstRegion = getRegionByIndex(obj, 1);
                obj.previewRegion(firstRegion);
            end
        end
    end
end



function isValid = objectIsValid(obj)
isValid = ~isempty(obj) && isvalid(obj);
end

function region = getRegionByIndex(obj, index)
regions = obj.getRegions();
count = numel(regions);
index = mod(index, count);
if index == 0
    index = count;
end
region = regions(index);
end

function adjacentRegion = getAdjacentRegion(obj, distance)
regions = obj.getRegions();
adjacentTag = obj.getAdjacentTag(distance);
adjacentRegion = findobj(regions, "Tag", adjacentTag);
end

function updateRegionGuiVisible(obj, activeRegion)
regionLinkers = obj.getRegionLinkers();
regionLinker = obj.getRegionLinker(activeRegion);
arrayfun(@(linker) linker.setVisible(false), regionLinkers);
regionLinker.setVisible(true);
end
