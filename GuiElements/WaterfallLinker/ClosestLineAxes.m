classdef ClosestLineAxes < handle
    properties (Access = private)
        x; % 1D array of x values (defaults to 1:linePointCount)
        y; % 2D array (index, length) of y values
        xPixels; % 1D array of x values in pixels in pixels from inner axis position
        yPixels; % 2D array of y values in pixels from inner axis position
        lineCount; % number of lines
        linePointCount; % number of points per line

        axis; % axis on which main lines are plotted
        lineObjs; % Line objects plotted on axis
    end

    properties (SetObservable)
        ClosestLine = []; % line closest to cursor
    end

    methods
        function obj = ClosestLineAxes(ax, y, x)
            linePointCount = size(y, 2);
            if nargin < 3
                x = 1:linePointCount;
            end

            lineObjs = waterfallOnAxis(ax, y, x);

            configureAxis(obj, ax);
            x = dataFromLines(lineObjs, "x");
            y = dataFromLines(lineObjs, "y");

            obj.x = x;
            obj.y = y;
            obj.xPixels = limitsToPixels(ax, x, "x");
            obj.yPixels = limitsToPixels(ax, y, "y");
            obj.lineCount = numel(lineObjs);
            obj.linePointCount = linePointCount;

            obj.lineObjs = lineObjs;
            obj.axis = ax;
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function lineObjs = getLineObjects(obj, index)
            if nargin == 1
                lineObjs = obj.lineObjs;
            else
                lineObjs = obj.lineObjs(index);
            end
        end
    end
    methods (Access = private)
        function ax = getAxis(obj)
            ax = obj.axis;
        end
    end

    %% Functions to retrieve state information
    methods (Access = private)
        function closestLine = getClosestLine(obj, xyMousePixels)
            x = obj.xPixels;
            y = obj.yPixels;
            closestIndex = getClosestIndex(xyMousePixels, x, y);
            closestLine = obj.getLineObjects(closestIndex);
            if obj.isNewClosestLine(closestLine)
                obj.ClosestLine = closestLine;
            end
        end
        function is = isNewClosestLine(obj, lineObj)
            closestLine = obj.ClosestLine;
            is = numel(closestLine) == 0 ...
                || ~strcmp(closestLine.Tag, lineObj.Tag);
        end
    end

    %% Functions to retrieve/update state of GUI
    methods (Static)
        function reOffsetLines(ax)
            lineObjs = findobj(ax.Children, "Type", "Line");
            reOffsetLines(lineObjs);
        end
        function xLines = dataFromLines(lineObjs, axisName)
            if nargin < 2
                axisName = 'y';
            end
            xLines = dataFromLines(lineObjs, axisName);
        end
    end

    %% Functions to update state of GUI
    methods (Access = private)
        function mouseExited(obj, ~, ~)
            obj.ClosestLine = [];
        end
        function onAxisHover(obj, ~, event)
            ax = obj.getAxis();
            xyMousePixels = hoverEventToPixels(ax, event);
            closestLine = obj.getClosestLine(xyMousePixels);
        end
        function axisButtonDown(obj, ~, event)
            eventName = event.EventName;
            if eventName == "Hit"
                ax = obj.getAxis();
                xyMousePixels = hitEventToPixels(ax, event);
                closestLine = obj.getClosestLine(xyMousePixels);
                closestLine.ButtonDownFcn(closestLine, event);
            end
        end
        function figureSizeChanged(obj, ~, ~)
            ax = obj.getAxis();
            obj.xPixels = limitsToPixels(ax, obj.x, "x");
            obj.yPixels = limitsToPixels(ax, obj.y, "y");
        end
    end
end



function configureAxis(obj, ax)
fig = ancestor(ax, "figure");

set(ax, "ButtonDownFcn", @obj.axisButtonDown);
set(fig, ...
    "AutoResizeChildren", false, ...
    "SizeChangedFcn", @obj.figureSizeChanged ...
    );

axPointerMananger = struct( ...
    "enterFcn" , @obj.figureSizeChanged, ...
    "exitFcn", @obj.mouseExited, ...
    "traverseFcn", @obj.onAxisHover ...
    );

iptSetPointerBehavior(ax, axPointerMananger)
iptPointerManager(fig, "Enable");
end

function xyMousePixels = hoverEventToPixels(ax, event)
xyMousePixels = event - ax.InnerPosition(1:2); % cursor location (pixels) relative to inner axis
end

function xyMousePixels = hitEventToPixels(ax, event)
xyMouseCoordinates = event.IntersectionPoint;
xyMousePixels(1) = limitsToPixels(ax, xyMouseCoordinates(1), "x");
xyMousePixels(2) = limitsToPixels(ax, xyMouseCoordinates(2), "y");
end



function closestIndexY = getClosestIndex(xyMouse, x, y)
% get nearest x-index relative to cursor
xMouse = xyMouse(1);
xCount = size(y, 2);
xDifference = x(1, 2) - x(1, 1); % calculate pixels between each point in x-direction
    function index = getIndexX(xPixels)
        index = round(xPixels / xDifference);
        index = min(xCount, index);
        index = max(1, index);
    end

yMouse = xyMouse(2);
yCount = size(y, 1);
closestIndexX = getIndexX(xMouse);

if yMouse <= y(1, closestIndexX) % bottom line is closest
    closestIndexY = 1;
    return;
elseif yMouse >= y(yCount, closestIndexX) % top line is closest
    closestIndexY = yCount;
    return;
end

% find change in y-position relative to cursor, above x-location of cursor
dyAtMinX = (y(:, closestIndexX) - yMouse).^2; % calculate change in y-position relative to cursor
[dyMinAtMinX, closestIndexY] = min(dyAtMinX); % determine line closest in y-direction

% calculate indices at which change in x-position is greater than
% minimum change in y-position
dyMinAtMinX = dyMinAtMinX + 1;
lowerIndexX = getIndexX(xMouse - dyMinAtMinX);
upperIndexX = getIndexX(xMouse + dyMinAtMinX);

% determine whether cursor is above or below closest line
yAtClosestX = y(closestIndexY, closestIndexX);
mouseBelowClosestY = yMouse < yAtClosestX;
mouseAboveClosestY = yMouse > yAtClosestX;

if yMouse == yAtClosestX
    return;
end

% get points and distances in vicinity (two nearest lines) of cursor
xSub = x(1, lowerIndexX:upperIndexX);
if mouseBelowClosestY
    ySub = y(closestIndexY-1:closestIndexY, lowerIndexX:upperIndexX);
elseif mouseAboveClosestY
    ySub = y(closestIndexY:closestIndexY+1, lowerIndexX:upperIndexX);
end
dx2 = (xSub - xMouse).^2;
dy2 = (ySub - yMouse).^2;
xyDistanceSub =  dx2 + dy2;

% set line closest to cursor as closer of two nearest lines
[~, closestIndexYSub] = min(xyDistanceSub(:)); % determine index closest to cursor
[closestIndexYSub, ~] = ind2sub(size(xyDistanceSub), closestIndexYSub); % reshape index
closestIndexY = closestIndexY + closestIndexYSub;
if mouseBelowClosestY
    closestIndexY = closestIndexY - 2;
elseif mouseAboveClosestY
    closestIndexY = closestIndexY - 1;
end
end

function arrayPixels = limitsToPixels(ax, array, axisName)
axPosition = get(ax, "InnerPosition");
switch upper(axisName)
    case "X"
        axLim = get(ax, "XLim");
        axLength = axPosition(3);
    case "Y"
        axLim = get(ax, "YLim");
        axLength = axPosition(4);
end
arrayPixels = axLength * (array - axLim(1)) / (axLim(2) - axLim(1));
end



function lineObjs = waterfallOnAxis(ax, y, x)
yCount = size(y, 2);
if nargin < 3
    x = 1:yCount;
end
yOffsets = calculateOffsets(y);
lineObjs = plotWaterfall(ax, x, y, yOffsets);
rerangeY(ax, 0.05 / yCount);
end

function lineObjs = plotWaterfall(ax, x, y, yOffsets)
yCount = size(y, 1);
lineObjs = matlab.graphics.chart.primitive.Line.empty(0, yCount);

hold(ax, "on");
for index = 1:yCount
    yWithOffset = y(index, :) + yOffsets(index);
    lineObj = plot(ax, ...
        x, yWithOffset, ...
        "Tag", num2str(index) ...
        );
    lineObjs(index) = lineObj;
end
hold(ax, "off");
end

function reOffsetLines(lineObjs)
yDatas = dataFromLines(lineObjs, 'y');
yOffsets = calculateOffsets(yDatas);

yCount = size(yDatas, 1);
for index = 1:yCount
    lineObj = lineObjs(index);
    yData = yDatas(index, :) + yOffsets(index);
    set(lineObj, "YData", yData)
end
end

function yOffsets = calculateOffsets(y, padding)
y = y';
yCount = size(y, 2);

yMins = min(y, [], 1);
% yMaxs = max(y, [], 1);
% yMinCumSum = cumsum(yMins);
% yMaxCumSum = cumsum(yMaxs);
% % (top of lower y) - (bottom of current y)
% yRangeShifted = yMaxCumSum(1:end-1) - yMinCumSum(2:end);
% yOffsets = [-yMins(1), yRangeShifted];

yDelta = y(:, 2:yCount) - y(:, 1:yCount-1);
yDeltaMinimum = min(yDelta, [], 1);
yOffsetsSingle = [yMins(1), yDeltaMinimum];
yOffsets = -cumsum(yOffsetsSingle);

if nargin < 2
    padding = 0.02 * mean(yOffsets);
end
yPaddings = (0:(yCount-1)) * padding;
yOffsets = yOffsets + yPaddings;
end

function rerangeY(ax, padding)
lineObjs = findobj(ax.Children, "Type", "Line");
yDatas = dataFromLines(lineObjs, 'y');
yDatas = yDatas(:);

yMin = min(yDatas);
yMax = max(yDatas);
yDiff = yMax - yMin;
yPadding = padding * yDiff;
yLimit = [yMin - yPadding, yMax + yPadding];
set(ax, "YLim", yLimit);
end

function xLines = dataFromLines(lineObjs, axisName)
axisName = upper(char(axisName));
fieldname = [axisName, 'Data'];
xLines = vertcat(lineObjs.(fieldname));
end
