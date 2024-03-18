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
            modifiers = event.Modifier;
            modKey = ModifierKey(modifiers);
            regionOrderer = RegionOrderer(region);

            if modKey.isCtrlShiftAlt
                if ArrowKey.isUp(key)
                    regionOrderer.bringToFront();
                elseif ArrowKey.isDown(key)
                    regionOrderer.sendToBack();
                end
            elseif modKey.isPureAlt
                if ArrowKey.isUp(key)
                    regionOrderer.bringForward();
                elseif ArrowKey.isDown(key)
                    regionOrderer.sendBackward();
                end
            end
        end
    end

    methods
        function bringToFront(obj, ~, ~)
            region = obj.region;
            bringToFront(region);
        end
        function bringForward(obj, ~, ~)
            region = obj.region;
            bringForward(region);
        end
        function sendBackward(obj, ~, ~)
            region = obj.region;
            sendBackward(region);
        end
        function sendToBack(obj, ~, ~)
            region = obj.region;
            sendToBack(region);
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



function children = getFigureChildren(region)
fig = ancestor(region, "figure");
children = findobj(fig);
end
function z = getRegionZ(region)
children = getFigureChildren(region);
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
