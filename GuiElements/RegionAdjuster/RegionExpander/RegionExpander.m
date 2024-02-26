classdef RegionExpander
    properties (Access = private)
        region;
    end

    methods
        function obj = RegionExpander(region)
            obj.region = region;
        end
    end

    %% Functions to expand or delete region
    methods (Static)
        function byKey(region, key)
            regionExpander = RegionExpander(region);
            if RegionAdjustKey.isUp(key)
                regionExpander.expandUp();
            elseif RegionAdjustKey.isLeft(key)
                regionExpander.expandLeft();
            elseif RegionAdjustKey.isDown(key)
                regionExpander.expandDown();
            elseif RegionAdjustKey.isRight(key)
                regionExpander.expandRight();
            elseif RegionAdjustKey.isSpace(key)
                regionExpander.expandOut();
            end
        end
    end

    methods
        function expandUp(obj, ~, ~)
            region = obj.region;
            expandUp(region);
            region.notify("ROIMoved");
        end
        function expandDown(obj, ~, ~)
            region = obj.region;
            expandDown(region);
            region.notify("ROIMoved");
        end
        function expandLeft(obj, ~, ~)
            region = obj.region;
            expandLeft(region);
            region.notify("ROIMoved");
        end
        function expandRight(obj, ~, ~)
            region = obj.region;
            expandRight(region);
            region.notify("ROIMoved");
        end

        function expandOut(obj, ~, ~)
            region = obj.region;
            expandOut(region);
            region.notify("ROIMoved");
        end

        function expandUpLeft(obj, ~, ~)
            region = obj.region;
            expandUpLeft(region);
            region.notify("ROIMoved");
        end
        function expandUpRight(obj, ~, ~)
            region = obj.region;
            expandUpRight(region);
            region.notify("ROIMoved");
        end
        function expandDownLeft(obj, ~, ~)
            region = obj.region;
            expandDownLeft(region);
            region.notify("ROIMoved");
        end
        function expandDownRight(obj, ~, ~)
            region = obj.region;
            expandDownRight(region);
            region.notify("ROIMoved");
        end
    end
end



function expandUp(region)
position = get(region, "Position");
position(2) = position(2) - 1;
position(4) = position(4) + 1;
set(region, "Position", position);
end
function expandDown(region)
position = get(region, "Position");
position(4) = position(4) + 1;
set(region, "Position", position);
end
function expandLeft(region)
position = get(region, "Position");
position(1) = position(1) - 1;
position(3) = position(3) + 1;
set(region, "Position", position);
end
function expandRight(region)
position = get(region, "Position");
position(3) = position(3) + 1;
set(region, "Position", position);
end

function expandUpLeft(region)
expandUp(region);
expandLeft(region);
end
function expandUpRight(region)
expandUp(region);
expandRight(region);
end
function expandDownLeft(region)
expandDown(region);
expandLeft(region);
end
function expandDownRight(region)
expandDown(region);
expandRight(region);
end

function expandOut(region)
expandUp(region);
expandDown(region);
expandLeft(region);
expandRight(region);
end