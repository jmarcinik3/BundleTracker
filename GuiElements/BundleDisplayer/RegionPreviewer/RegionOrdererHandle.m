classdef RegionOrdererHandle < handle
    properties (Access = private)
        region;
    end

    methods
        function obj = RegionOrdererHandle()
        end
    end

    %% Functions to retrieve GUI elements or state information
    methods
        function region = getCurrentRegion(obj)
            region = obj.region;
        end
    end
    methods (Access = private)
        function regions = getRegions(obj)
            region = obj.getCurrentRegion();
            ax =  ancestor(region, "axes");
            regions = RegionDrawer.getRegions(ax);
        end
        function exists = regionExists(obj)
            regions = obj.getRegions();
            count = numel(regions);
            exists = count >= 1;
        end
    end

    %% Functions to set state of GUI
    methods (Access = protected)
        function setCurrentRegion(obj, region)
            obj.region = region;
        end
    end

    %% Functions to update state of GUI
    methods
        function bringRegionToFront(obj, ~, ~)
            if obj.regionExists()
                currentRegion = obj.getCurrentRegion();
                regionOrderer = RegionOrderer(currentRegion);
                regionOrderer.bringToFront();
            end
        end
        function bringRegionForward(obj, ~, ~)
            if obj.regionExists()
                currentRegion = obj.getCurrentRegion();
                regionOrderer = RegionOrderer(currentRegion);
                regionOrderer.bringForward();
            end
        end
        function sendRegionBackward(obj, ~, ~)
            if obj.regionExists()
                currentRegion = obj.getCurrentRegion();
                regionOrderer = RegionOrderer(currentRegion);
                regionOrderer.sendBackward();
            end
        end
        function sendRegionToBack(obj, ~, ~)
            if obj.regionExists()
                currentRegion = obj.getCurrentRegion();
                regionOrderer = RegionOrderer(currentRegion);
                regionOrderer.sendToBack();
            end
        end
    end
end
