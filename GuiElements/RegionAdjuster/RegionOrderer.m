classdef RegionOrderer
    properties (Access = private)
        region;
    end

    methods
        function obj = RegionOrderer(region)
            obj.region = region;
        end
    end

    %% Functions to move or delete region
    methods (Static)
        function byKey(region, key, modifiers)
            modifierAnalyzer = KeyModifierAnalyzer(modifiers);
            regionOrderer = RegionOrderer(region);

            if modifierAnalyzer.hasCtrlShiftAlt && ArrowKey.isUp(key)
                regionOrderer.bringToFront();
            elseif modifierAnalyzer.hasCtrlShiftAlt && ArrowKey.isDown(key)
                regionOrderer.sendToBack();
            elseif modifierAnalyzer.hasPureAlt && ArrowKey.isUp(key)
                regionOrderer.bringForward();
            elseif modifierAnalyzer.hasPureAlt && ArrowKey.isDown(key)
                regionOrderer.sendBackward();
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



function regions = getRegions(region)
ax = ancestor(region, "axes");
regions = RegionDrawer.getRegions(ax);
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
regions = getRegions(region);
z = arrayfun(@(region) getRegionZ(region), regions);
end

function deltaZ = getNextRegionDelta(region)
regionZ = getRegionZ(region);
regionsZ = getRegionsZ(region);
nextRegionZ = getPreviousFloatBounded(regionsZ, regionZ);
deltaZ = regionZ - nextRegionZ;
end
function deltaZ = getPreviousRegionDelta(region)
regionZ = getRegionZ(region);
regionsZ = getRegionsZ(region);
previousRegionZ = getNextFloatBounded(regionsZ, regionZ);
deltaZ = previousRegionZ - regionZ;
end
function deltaZ = getBottomRegionDelta(region)
regionZ = getRegionZ(region);
regionsZ = getRegionsZ(region);
bottomRegionZ = max(regionsZ);
deltaZ = bottomRegionZ - regionZ;
end

function nextFloat = getNextFloatBounded(array, number)
greaterFloats = array(array > number);
existsGreaterFloat = numel(greaterFloats) >= 1;
if existsGreaterFloat
    nextFloat = min(greaterFloats);
else
    nextFloat = number;
end
end
function previousFloat = getPreviousFloatBounded(array, number)
lesserFloats = array(array < number);
existsLesserFloat = numel(lesserFloats) >= 1;
if existsLesserFloat
    previousFloat = max(lesserFloats);
else
    previousFloat = number;
end
end