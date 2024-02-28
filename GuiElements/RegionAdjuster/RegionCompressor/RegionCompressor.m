classdef RegionCompressor
    properties (Access = private)
        region;
    end

    methods
        function obj = RegionCompressor(region)
            obj.region = region;
        end
    end

    %% Functions to compress or delete region
    methods (Static)
        function  byKey(region, event)
            key = event.Key;
            modifiers = event.Modifier;
            modKey = ModifierKey(modifiers);
            if modKey.isPureCtrl
                RegionCompressor.byKeyUnchecked(region, key)
            end
        end
    end
    methods (Access = private, Static)
        function byKeyUnchecked(region, key)
            regionCompressor = RegionCompressor(region);
            if RegionAdjustKey.isUp(key)
                regionCompressor.compressUp();
            elseif RegionAdjustKey.isLeft(key)
                regionCompressor.compressLeft();
            elseif RegionAdjustKey.isDown(key)
                regionCompressor.compressDown();
            elseif RegionAdjustKey.isRight(key)
                regionCompressor.compressRight();
            elseif RegionAdjustKey.isSpace(key)
                regionCompressor.compressIn();
            end
        end
    end

    methods
        function compressUp(obj, ~, ~)
            region = obj.region;
            compressUp(region);
            region.notify("ROIMoved");
        end
        function compressDown(obj, ~, ~)
            region = obj.region;
            compressDown(region);
            region.notify("ROIMoved");
        end
        function compressLeft(obj, ~, ~)
            region = obj.region;
            compressLeft(region);
            region.notify("ROIMoved");
        end
        function compressRight(obj, ~, ~)
            region = obj.region;
            compressRight(region);
            region.notify("ROIMoved");
        end

        function compressIn(obj, ~, ~)
            region = obj.region;
            compressIn(region);
            region.notify("ROIMoved");
        end

        function compressUpLeft(obj, ~, ~)
            region = obj.region;
            compressUpLeft(region);
            region.notify("ROIMoved");
        end
        function compressUpRight(obj, ~, ~)
            region = obj.region;
            compressUpRight(region);
            region.notify("ROIMoved");
        end
        function compressDownLeft(obj, ~, ~)
            region = obj.region;
            compressDownLeft(region);
            region.notify("ROIMoved");
        end
        function compressDownRight(obj, ~, ~)
            region = obj.region;
            compressDownRight(region);
            region.notify("ROIMoved");
        end
    end
end



function compressUp(region)
if RegionType.isRectangle(region)
    rectangleUp(region);
elseif RegionType.isEllipse(region)
    ellipseUp(region);
elseif RegionType.hasVertexPosition(region)
    vertexUp(region);
end
end

function compressDown(region)
if RegionType.isRectangle(region)
    rectangleDown(region);
elseif RegionType.isEllipse(region)
    ellipseDown(region);
elseif RegionType.hasVertexPosition(region)
    vertexDown(region);
end
end

function compressLeft(region)
if RegionType.isRectangle(region)
    rectangleLeft(region);
elseif RegionType.isEllipse(region)
    ellipseLeft(region);
elseif RegionType.hasVertexPosition(region)
    vertexLeft(region);
end
end

function compressRight(region)
if RegionType.isRectangle(region)
    rectangleRight(region);
elseif RegionType.isEllipse(region)
    ellipseRight(region);
elseif RegionType.hasVertexPosition(region)
    vertexRight(region);
end
end



function rectangleUp(rect)
rect.Position(4) = rect.Position(4) - 1;
end
function rectangleDown(rect)
rect.Position(2) = rect.Position(2) + 1;
rect.Position(4) = rect.Position(4) - 1;
end
function rectangleLeft(rect)
rect.Position(3) = rect.Position(3) - 1;
end
function rectangleRight(rect)
rect.Position(1) = rect.Position(1) + 1;
rect.Position(3) = rect.Position(3) - 1;
end

function ellipseUp(ellipse)
ellipse.SemiAxes(2) = ellipse.SemiAxes(2) - 1;
end
function ellipseDown(ellipse)
ellipse.SemiAxes(2) = ellipse.SemiAxes(2) - 1;
end
function ellipseLeft(ellipse)
ellipse.SemiAxes(1) = ellipse.SemiAxes(1) - 1;
end
function ellipseRight(ellipse)
ellipse.SemiAxes(1) = ellipse.SemiAxes(1) - 1;
end

function vertexUp(polygon)
y = polygon.Position(:, 2);
polygonHeight = range(y);
ymin = min(y);
scaleFactor = (polygonHeight - 1) / polygonHeight;
polygon.Position(:, 2) = ymin + scaleFactor * (y - ymin);
end
function vertexDown(polygon)
y = polygon.Position(:, 2);
polygonHeight = range(y);
ymax = max(y);
scaleFactor = (polygonHeight - 1) / polygonHeight;
polygon.Position(:, 2) = ymax + scaleFactor * (y - ymax);
end
function vertexLeft(polygon)
x = polygon.Position(:, 1);
polygonHeight = range(x);
xmin = min(x);
scaleFactor = (polygonHeight - 1) / polygonHeight;
polygon.Position(:, 1) = xmin + scaleFactor * (x - xmin);
end
function vertexRight(polygon)
x = polygon.Position(:, 1);
polygonHeight = range(x);
xmax = max(x);
scaleFactor = (polygonHeight - 1) / polygonHeight;
polygon.Position(:, 1) = xmax + scaleFactor * (x - xmax);
end



function compressUpLeft(region)
compressUp(region);
compressLeft(region);
end
function compressUpRight(region)
compressUp(region);
compressRight(region);
end
function compressDownLeft(region)
compressDown(region);
compressLeft(region);
end
function compressDownRight(region)
compressDown(region);
compressRight(region);
end

function compressIn(region)
compressUp(region);
compressDown(region);
compressLeft(region);
compressRight(region);
end