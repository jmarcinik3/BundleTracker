classdef RegionVisibler < ActiveRegionOrderer & RegionLinkerContainer
    methods
        function obj = RegionVisibler(imageLinker, regionGuiParent)
            imageGui = imageLinker.getGui();
            ax = imageGui.getAxis();
            obj@ActiveRegionOrderer(ax);
            obj@RegionLinkerContainer(imageLinker, regionGuiParent)
        end
    end

    %% Functions to retrieve state information
    methods (Access = private)
        function adjacentTag = getAdjacentTag(obj, distance)
            regionIndices = obj.getRegionIndices();
            activeIndex = obj.getActiveIndex();
            adjacentIndex = getAdjacentFloatCyclic( ...
                regionIndices, ...
                activeIndex, ...
                distance ...
                );
            adjacentTag = num2str(adjacentIndex);
        end
    end

    %% Functions to update state of GUI
    methods
        function setPreviousRegionVisible(obj, ~, ~)
            obj.setAdjacentRegionVisible(-1);
        end
        function setNextRegionVisible(obj, ~, ~)
            obj.setAdjacentRegionVisible(1);
        end
    end
    methods (Access = protected)
        function clearRegions(obj)
            % Removes currently drawn regions on image
            regions = obj.getRegions();
            arrayfun(@(region) region.notify("DeletingROI"), regions);
            delete(regions);
        end
        function previewRegion(obj, region)
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
regionLinker = obj.getRegionLinker(activeRegion);
regionLinkers = obj.getRegionLinkers();
arrayfun(@(linker) linker.setVisible(false), regionLinkers);
regionLinker.setVisible(true);
end

function adjacentFloat = getAdjacentFloatCyclic(array, number, distance)
array = sort(array);
arraySize = numel(array);
numberIndex = find(array == number);
nextIndex = mod(numberIndex + distance, arraySize);
if nextIndex == 0
    nextIndex = arraySize;
end
adjacentFloat = array(nextIndex);
end
