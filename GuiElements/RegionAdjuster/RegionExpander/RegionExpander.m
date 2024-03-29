classdef RegionExpander < RegionAdjuster
    methods
        function obj = RegionExpander(previewer)
            obj@RegionAdjuster(previewer);
        end
    end

    %% Functions to expand or delete region
    methods (Static)
        function byKey(region, event)
            key = event.Key;
            modKey = ModifierKey(event);
            if modKey.isPureCtrlShift
                RegionExpander.byKeyUnchecked(region, key)
            end
        end
    end
    methods (Access = private, Static)
        function byKeyUnchecked(region, key)
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
            obj.performAction(@expandUp);
        end
        function expandDown(obj, ~, ~)
            obj.performAction(@expandDown);
        end
        function expandLeft(obj, ~, ~)
            obj.performAction(@expandLeft);
        end
        function expandRight(obj, ~, ~)
            obj.performAction(@expandRight);
        end

        function expandOut(obj, ~, ~)
            obj.performAction(@expandOut);
        end

        function expandUpLeft(obj, ~, ~)
            obj.performAction(@expandUpLeft);
        end
        function expandUpRight(obj, ~, ~)
            obj.performAction(@expandUpRight);
        end
        function expandDownLeft(obj, ~, ~)
            obj.performAction(@expandDownLeft);
        end
        function expandDownRight(obj, ~, ~)
            obj.performAction(@expandDownRight);
        end
    end
end



function expandUp(region)
if RegionType.isRectangle(region)
    rectangleUp(region);
elseif RegionType.isEllipse(region)
    ellipseUp(region);
elseif RegionType.hasVertexPosition(region)
    vertexUp(region);
end
end

function expandDown(region)
if RegionType.isRectangle(region)
    rectangleDown(region);
elseif RegionType.isEllipse(region)
    ellipseDown(region);
elseif RegionType.hasVertexPosition(region)
    vertexDown(region);
end
end

function expandLeft(region)
if RegionType.isRectangle(region)
    rectangleLeft(region);
elseif RegionType.isEllipse(region)
    ellipseLeft(region);
elseif RegionType.hasVertexPosition(region)
    vertexLeft(region);
end
end

function expandRight(region)
if RegionType.isRectangle(region)
    rectangleRight(region);
elseif RegionType.isEllipse(region)
    ellipseRight(region);
elseif RegionType.hasVertexPosition(region)
    vertexRight(region);
end
end



function rectangleUp(rect)
rect.Position(2) = rect.Position(2) - 1;
rect.Position(4) = rect.Position(4) + 1;
end
function rectangleDown(rect)
rect.Position(4) = rect.Position(4) + 1;
end
function rectangleLeft(rect)
rect.Position(1) = rect.Position(1) - 1;
rect.Position(3) = rect.Position(3) + 1;
end
function rectangleRight(rect)
rect.Position(3) = rect.Position(3) + 1;
end

function ellipseUp(ellipse)
ellipse.SemiAxes(2) = ellipse.SemiAxes(2) + 1;
end
function ellipseDown(ellipse)
ellipse.SemiAxes(2) = ellipse.SemiAxes(2) + 1;
end
function ellipseLeft(ellipse)
ellipse.SemiAxes(1) = ellipse.SemiAxes(1) + 1;
end
function ellipseRight(ellipse)
ellipse.SemiAxes(1) = ellipse.SemiAxes(1) + 1;
end

function vertexUp(polygon)
y = polygon.Position(:, 2);
polygonHeight = range(y);
ymax = max(y);
scaleFactor = (polygonHeight + 1) / polygonHeight;
polygon.Position(:, 2) = ymax + scaleFactor * (y - ymax);
end
function vertexDown(polygon)
y = polygon.Position(:, 2);
polygonHeight = range(y);
ymin = min(y);
scaleFactor = (polygonHeight + 1) / polygonHeight;
polygon.Position(:, 2) = ymin + scaleFactor * (y - ymin);
end
function vertexLeft(polygon)
x = polygon.Position(:, 1);
polygonHeight = range(x);
xmax = max(x);
scaleFactor = (polygonHeight + 1) / polygonHeight;
polygon.Position(:, 1) = xmax + scaleFactor * (x - xmax);
end
function vertexRight(polygon)
x = polygon.Position(:, 1);
polygonHeight = range(x);
xmin = min(x);
scaleFactor = (polygonHeight + 1) / polygonHeight;
polygon.Position(:, 1) = xmin + scaleFactor * (x - xmin);
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