classdef RegionMover < RegionAdjuster
    methods
        function obj = RegionMover(previewer)
            obj@RegionAdjuster(previewer);
        end
    end

    %% Functions to move or delete region
    methods (Static)
        function byKey(region, event)
            key = event.Key;
            modKey = ModifierKey(event);
            if modKey.hasZeroModifiers
                RegionMover.byKeyUnmodified(region, key)
            elseif modKey.isPureCtrl && RegionAdjustKey.isDelete(key)
                regionMover = RegionMover(region);
                regionMover.deleteRegion();
            end
        end
    end
    methods (Access = private, Static)
        function byKeyUnmodified(region, key)
            regionMover = RegionMover(region);
            if RegionAdjustKey.isUp(key)
                regionMover.moveUp();
            elseif RegionAdjustKey.isLeft(key)
                regionMover.moveLeft();
            elseif RegionAdjustKey.isDown(key)
                regionMover.moveDown();
            elseif RegionAdjustKey.isRight(key)
                regionMover.moveRight();
            end
        end
    end

    methods
        function moveUp(obj, ~, ~)
            obj.performAction(@moveUp);
        end
        function moveDown(obj, ~, ~)
            obj.performAction(@moveDown);
        end
        function moveLeft(obj, ~, ~)
            obj.performAction(@moveLeft);
        end
        function moveRight(obj, ~, ~)
            obj.performAction(@moveRight);
        end

        function deleteRegion(obj, ~, ~)
            region = obj.getRegion();
            deleteRegions(region);
        end

        function moveUpLeft(obj, ~, ~)
            obj.performAction(@moveUpLeft);
        end
        function moveUpRight(obj, ~, ~)
            obj.performAction(@moveUpRight);
        end
        function moveDownLeft(obj, ~, ~)
            obj.performAction(@moveDownLeft);
        end
        function moveDownRight(obj, ~, ~)
            obj.performAction(@moveDownRight);
        end
    end
end



function moveUp(region)
if isa(region, "images.roi.Rectangle") ...
        || isa(region, "images.roi.Ellipse")
    positionUp(region);
elseif isa(region, "images.roi.Polygon") ...
        || isa(region, "images.roi.Freehand")
    vertexUp(region);
end
end
function moveDown(region)
if isa(region, "images.roi.Rectangle") ...
        || isa(region, "images.roi.Ellipse")
    positionDown(region);
elseif isa(region, "images.roi.Polygon") ...
        || isa(region, "images.roi.Freehand")
    vertexDown(region);
end
end
function moveLeft(region)
if isa(region, "images.roi.Rectangle") ...
        || isa(region, "images.roi.Ellipse")
    positionLeft(region);
elseif isa(region, "images.roi.Polygon") ...
        || isa(region, "images.roi.Freehand")
    vertexLeft(region);
end
end
function moveRight(region)
if isa(region, "images.roi.Rectangle") ...
        || isa(region, "images.roi.Ellipse")
    positionRight(region);
elseif isa(region, "images.roi.Polygon") ...
        || isa(region, "images.roi.Freehand")
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
