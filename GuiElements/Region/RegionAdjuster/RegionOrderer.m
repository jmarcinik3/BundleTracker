classdef RegionOrderer
    properties (Access = private)
        region;
    end

    methods
        function obj = RegionOrderer(region)
            obj.region = region;
        end
    end

    %% Functions to z-order of region
    methods (Static)
        function byKey(region, event)
            key = event.Key;
            modKey = ModifierKey(event);
            regionOrderer = RegionOrderer(region);

            if modKey.isPureCtrlShift
                if BracketKey.isRightBracket(key)
                    regionOrderer.bringToFront();
                elseif BracketKey.isLeftBracket(key)
                    regionOrderer.sendToBack();
                end
            elseif modKey.isPureCtrl
                if BracketKey.isRightBracket(key)
                    regionOrderer.bringForward();
                elseif BracketKey.isLeftBracket(key)
                    regionOrderer.sendBackward();
                end
            end
        end
    end

    methods
        function bringToFront(obj, ~, ~)
            obj.performAction(@bringToFront);
        end
        function bringForward(obj, ~, ~)
            obj.performAction(@bringForward);
        end
        function sendBackward(obj, ~, ~)
            obj.performAction(@sendBackward);
        end
        function sendToBack(obj, ~, ~)
            obj.performAction(@sendToBack);
        end
    end

    methods (Access = private)
        function performAction(obj, action)
            region = obj.region;
            action(region);
            RegionUpdater.update(region);
        end
    end
end



function bringToFront(region)
deltaZ = getTopRegionDelta(region);
uistack(region, "up", deltaZ);
end
function bringForward(region)
deltaZ = getNextRegionDelta(region);
uistack(region, "up", deltaZ);
end
function sendBackward(region)
deltaZ = getPreviousRegionDelta(region);
uistack(region, "down", deltaZ);
end
function sendToBack(region)
deltaZ = getBottomRegionDelta(region);
uistack(region, "down", deltaZ);
end



function z = getRegionZ(region)
fig = ancestor(region, "figure");
children = findobj(fig);
z = find(children==region);
end
function z = getRegionsZ(region)
regions = RegionDrawer.getRegions(region);
z = arrayfun(@getRegionZ, regions);
end



function deltaZ = getTopRegionDelta(region)
regionZ = getRegionZ(region);
regionsZ = getRegionsZ(region);
topRegionZ = min(regionsZ);
deltaZ = regionZ - topRegionZ;
end
function deltaZ = getNextRegionDelta(region)
regionZ = getRegionZ(region);
regionsZ = getRegionsZ(region);
nextRegionZ = AdjacentFloat.boundedPrevious(regionsZ, regionZ);
deltaZ = regionZ - nextRegionZ;
end
function deltaZ = getPreviousRegionDelta(region)
regionZ = getRegionZ(region);
regionsZ = getRegionsZ(region);
previousRegionZ = AdjacentFloat.boundedNext(regionsZ, regionZ);
deltaZ = previousRegionZ - regionZ;
end
function deltaZ = getBottomRegionDelta(region)
regionZ = getRegionZ(region);
regionsZ = getRegionsZ(region);
bottomRegionZ = max(regionsZ);
deltaZ = bottomRegionZ - regionZ;
end
