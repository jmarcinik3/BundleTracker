classdef RegionVisibler < handle
    properties (Access = private)
        gui;
        activeRegion;
    end

    methods (Abstract, Access = protected)
        getAxis(obj);
    end

    methods
        function obj = RegionVisibler(regionGui)
            obj.gui = regionGui;
        end
    end

    %% Functions to retrieve state information
    methods
        function regions = getRegions(obj)
            ax = obj.getAxis();
            regions = RegionDrawer.getRegions(ax);
        end
        function activeRegion = getActiveRegion(obj)
            activeRegion = obj.activeRegion;
        end
    end
    methods (Access = protected)
        function index = getActiveIndex(obj)
            region = obj.getActiveRegion();
            index = getRegionIndices(region);
        end
        function indices = getRegionIndices(obj)
            regions = obj.getRegions();
            indices = getRegionIndices(regions);
        end
        function regionCount = getRegionCount(obj)
            regionCount = numel(obj.getRegions());
        end
        function exists = regionExists(obj)
            regionCount = obj.getRegionCount();
            exists = regionCount >= 1;
        end
        function exist = multipleRegionsExist(obj)
            regionCount = obj.getRegionCount();
            exist = regionCount >= 2;
        end
    end
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
        function bringRegionToFront(obj, ~, ~)
            if obj.regionExists()
                activeRegion = obj.getActiveRegion();
                regionOrderer = RegionOrderer(activeRegion);
                regionOrderer.bringToFront();
            end
        end
        function bringRegionForward(obj, ~, ~)
            if obj.regionExists()
                activeRegion = obj.getActiveRegion();
                regionOrderer = RegionOrderer(activeRegion);
                regionOrderer.bringForward();
            end
        end
        function sendRegionBackward(obj, ~, ~)
            if obj.regionExists()
                activeRegion = obj.getActiveRegion();
                regionOrderer = RegionOrderer(activeRegion);
                regionOrderer.sendBackward();
            end
        end
        function sendRegionToBack(obj, ~, ~)
            if obj.regionExists()
                activeRegion = obj.getActiveRegion();
                regionOrderer = RegionOrderer(activeRegion);
                regionOrderer.sendToBack();
            end
        end

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
            RegionUpdater.update(region);
        end
    end
    methods (Access = protected)
        function setActiveRegion(obj, region)
            obj.activeRegion = region;
        end
    end
    methods (Access = private)
        function setAdjacentRegionVisible(obj, distance)
            activeRegion = obj.getActiveRegion();
            if ~isempty(activeRegion) && isvalid(activeRegion)
                adjacentRegion = getAdjacentRegion(obj, distance);
                obj.previewRegion(adjacentRegion);
            elseif obj.regionExists()
                firstRegion = getRegionByIndex(obj, 1);
                obj.previewRegion(firstRegion);
            end
        end
    end
end



function region = getRegionByIndex(obj, index)
regions = obj.getRegions();
regionCount = numel(regions);
index = mod(index, regionCount);
if index == 0
    index = regionCount;
end
region = regions(index);
end

function indices = getRegionIndices(regions)
indices = str2double(get(regions, "Label"));
end

function adjacentRegion = getAdjacentRegion(obj, distance)
regions = obj.getRegions();
adjacentTag = obj.getAdjacentTag(distance);
adjacentRegion = findobj(regions, "Label", adjacentTag);
end
