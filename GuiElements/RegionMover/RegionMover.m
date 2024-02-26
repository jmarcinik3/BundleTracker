classdef RegionMover
    properties (Access = private)
        region;
    end

    methods
        function obj = RegionMover(region)
            obj.region = region;
        end
    end

    %% Functions to move or delete region
    methods
        function moveUp(obj, ~, ~)
            region = obj.region;
            moveUp(region);
            region.notify("ROIMoved");
        end
        function moveDown(obj, ~, ~)
            region = obj.region;
            moveDown(region);
            region.notify("ROIMoved");
        end
        function moveLeft(obj, ~, ~)
            region = obj.region;
            moveLeft(region);
            region.notify("ROIMoved");
        end
        function moveRight(obj, ~, ~)
            region = obj.region;
            moveRight(region);
            region.notify("ROIMoved");
        end

        function deleteRegion(obj, ~, ~)
            region = obj.region;
            deleteRegion(region)
        end

        function moveUpLeft(obj, ~, ~)
            region = obj.region;
            moveUpLeft(region);
            region.notify("ROIMoved");
        end
        function moveUpRight(obj, ~, ~)
            region = obj.region;
            moveUpRight(region);
            region.notify("ROIMoved");
        end
        function moveDownLeft(obj, ~, ~)
            region = obj.region;
            moveDownLeft(region);
            region.notify("ROIMoved");
        end
        function moveDownRight(obj, ~, ~)
            region = obj.region;
            moveDownRight(region);
            region.notify("ROIMoved");
        end
    end
end



function deleteRegion(region)
region.notify("DeletingROI");
delete(region);
end

function moveUp(region)
position = get(region, "Position");
position(2) = position(2) - 1;
set(region, "Position", position);
end
function moveDown(region)
position = get(region, "Position");
position(2) = position(2) + 1;
set(region, "Position", position);
end
function moveLeft(region)
position = get(region, "Position");
position(1) = position(1) - 1;
set(region, "Position", position);
end
function moveRight(region)
position = get(region, "Position");
position(1) = position(1) + 1;
set(region, "Position", position);
end

function moveUpLeft(region)
moveUp(region);
moveLeft(region);
end
function moveUpRight(region)
moveUp(region);
moveRight(region);
end
function moveDownLeft(region)
moveDown(region);
moveLeft(region);
end
function moveDownRight(region)
moveDown(region);
moveRight(region);
end