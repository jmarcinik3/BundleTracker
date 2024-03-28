classdef ActiveRegionOrderer < handle
    properties (Access = private)
        axis;
        activeRegion;
    end

    methods
        function obj = ActiveRegionOrderer(ax)
            obj.axis = ax;
        end
    end

    %% Functions to retrieve GUI elements or state information
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
        function exists = regionExists(obj)
            regions = obj.getRegions();
            count = numel(regions);
            exists = count >= 1;
        end
        function ax = getAxis(obj)
            ax = obj.axis;
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
    end
    methods (Access = protected)
        function setActiveRegion(obj, region)
            obj.activeRegion = region;
        end
    end
end



function indices = getRegionIndices(regions)
indices = str2double(get(regions, "Label"));
end
