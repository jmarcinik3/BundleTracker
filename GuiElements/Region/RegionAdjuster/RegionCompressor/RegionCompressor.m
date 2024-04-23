classdef RegionCompressor < RegionAdjuster
    methods
        function obj = RegionCompressor(previewer)
            obj@RegionAdjuster(previewer);
        end
    end

    %% Functions to compress or delete region
    methods (Static)
        function  byKey(region, event)
            key = event.Key;
            modKey = ModifierKey(event);
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
            obj.performAction(@compressUp);
        end
        function compressDown(obj, ~, ~)
            obj.performAction(@compressDown);
        end
        function compressLeft(obj, ~, ~)
            obj.performAction(@compressLeft);
        end
        function compressRight(obj, ~, ~)
            obj.performAction(@compressRight);
        end

        function compressIn(obj, ~, ~)
            obj.performAction(@compressIn);
        end

        function compressUpLeft(obj, ~, ~)
            obj.performAction(@compressUpLeft);
        end
        function compressUpRight(obj, ~, ~)
            obj.performAction(@compressUpRight);
        end
        function compressDownLeft(obj, ~, ~)
            obj.performAction(@compressDownLeft);
        end
        function compressDownRight(obj, ~, ~)
            obj.performAction(@compressDownRight);
        end
    end
end



function compressUp(region)
if isa(region, "images.roi.Rectangle")
    rectangleUp(region);
elseif isa(region, "images.roi.Ellipse")
    ellipseUp(region);
elseif isa(region, "images.roi.Polygon")
    vertexUp(region);
end
end

function compressDown(region)
if isa(region, "images.roi.Rectangle")
    rectangleDown(region);
elseif isa(region, "images.roi.Ellipse")
    ellipseDown(region);
elseif isa(region, "images.roi.Polygon") ...
        || isa(region, "images.roi.Freehand")
    vertexDown(region);
end
end

function compressLeft(region)
if isa(region, "images.roi.Rectangle")
    rectangleLeft(region);
elseif isa(region, "images.roi.Ellipse")
    ellipseLeft(region);
elseif isa(region, "images.roi.Polygon") ...
        || isa(region, "images.roi.Freehand")
    vertexLeft(region);
end
end

function compressRight(region)
if isa(region, "images.roi.Rectangle")
    rectangleRight(region);
elseif isa(region, "images.roi.Ellipse")
    ellipseRight(region);
elseif isa(region, "images.roi.Polygon") ...
        || isa(region, "images.roi.Freehand")
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