classdef RegionVisibler < ActiveRegionOrderer & RegionLinkerContainer
    methods
        function obj = RegionVisibler(imageLinker, regionGuiParent)
            imageGui = imageLinker.getGui();
            ax = imageGui.getAxis();
            obj@ActiveRegionOrderer(ax);
            obj@RegionLinkerContainer(imageLinker, regionGuiParent)
        end
    end

    %% Functions to retrieve GUI elements
    methods (Access = private)
        function previousRegion = getPreviousRegion(obj)
            previousRegion = obj.getAdjacentRegion(-1);
        end
        function nextRegion = getNextRegion(obj)
            nextRegion = obj.getAdjacentRegion(1);
        end
        function adjacentRegion = getAdjacentRegion(obj, distance)
            regions = obj.getRegions();
            adjacentTag = obj.getAdjacentTag(distance);
            adjacentRegion = findobj(regions, "Tag", adjacentTag);
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
        function previewRegion(obj, region)
            obj.updateRegionGuiVisible(region);
            RegionDrawer.updateSelected(region);
        end
    end
    methods (Access = private)
        function setAdjacentRegionVisible(obj, distance)
            activeRegion = obj.getActiveRegion();
            if objectIsValid(activeRegion)
                adjacentRegion = obj.getAdjacentRegion(distance);
                obj.previewRegion(adjacentRegion);
            elseif obj.regionExists()
                obj.setFirstRegionVisible();
            end
        end

        function updateRegionGuiVisible(obj, activeRegion)
            regionLinker = obj.getRegionLinker(activeRegion);
            regionLinkers = obj.getRegionLinkers();
            arrayfun(@(gui) gui.setVisible(false), regionLinkers);
            regionLinker.setVisible(true);
        end
        function setFirstRegionVisible(obj)
            regions = obj.getRegions();
            firstRegion = regions(1);
            obj.previewRegion(firstRegion);
        end
    end
end



function isValid = objectIsValid(obj)
isValid = ~isempty(obj) && isvalid(obj);
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
