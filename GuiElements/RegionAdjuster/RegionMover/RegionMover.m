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
    methods (Static)
        function byKey(region, key)
            regionMover = RegionMover(region);
            if RegionAdjustKey.isUp(key)
                regionMover.moveUp();
            elseif RegionAdjustKey.isLeft(key)
                regionMover.moveLeft();
            elseif RegionAdjustKey.isDown(key)
                regionMover.moveDown();
            elseif RegionAdjustKey.isRight(key)
                regionMover.moveRight();
            elseif RegionAdjustKey.isSpace(key)
                regionMover.deleteRegion();
            end
        end
    end
    
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
if RegionType.hasPointPosition(region)
    positionUp(region);
elseif RegionType.hasVertexPosition(region)
    vertexUp(region);
end
end
function moveDown(region)
if RegionType.hasPointPosition(region)
    positionDown(region);
elseif RegionType.hasVertexPosition(region)
    vertexDown(region);
end
end
function moveLeft(region)
if RegionType.hasPointPosition(region)
    positionLeft(region);
elseif RegionType.hasVertexPosition(region)
    vertexLeft(region);
end
end
function moveRight(region)
if RegionType.hasPointPosition(region)
    positionRight(region);
elseif RegionType.hasVertexPosition(region)
    vertexRight(region);
end
end



function positionUp(rect)
rect.Position(2) = rect.Position(2) - 1;
end
function positionDown(rect)
rect.Position(2) = rect.Position(2) + 1;
end
function positionLeft(rect)
rect.Position(1) = rect.Position(1) - 1;
end
function positionRight(rect)
rect.Position(1) = rect.Position(1) + 1;
end


function vertexUp(polygon)
polygon.Position(:, 2) = polygon.Position(:, 2) - 1;
end
function vertexDown(polygon)
polygon.Position(:, 2) = polygon.Position(:, 2) + 1;
end
function vertexLeft(polygon)
polygon.Position(:, 1) = polygon.Position(:, 1) - 1;
end
function vertexRight(polygon)
polygon.Position(:, 1) = polygon.Position(:, 1) + 1;
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