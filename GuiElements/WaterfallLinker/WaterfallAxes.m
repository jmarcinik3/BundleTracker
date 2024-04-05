classdef WaterfallAxes < LinePreviewer & LineAccenter
    properties (Access = private)
        x; % 1D array of x values (defaults to 1:linePointCount)
        y; % 2D array (index, length) of y values
        xPixels; % 1D array of x values in pixels in pixels from inner axis position
        yPixels; % 2D array of y values in pixels from inner axis position
        lineCount; % number of lines
        linePointCount; % numbers of points per line
    end

    methods (Abstract, Access = protected)
        afterAxisHover(obj, closestLine, event); % call on mouse hover over axis
        afterAxisExit(obj, source, event); % call on mouse exit from axis
    end

    methods
        function obj = WaterfallAxes(ax, y, x)
            linePointCount = size(y, 2);
            if nargin < 3
                x = 1:linePointCount;
            end

            lineObjs = waterfallOnAxis(ax, y, x);

            obj@LineAccenter(lineObjs);
            obj@LinePreviewer(ax);
            configureAxis(obj, ax);

            x = dataFromLines(lineObjs, "x");
            y = dataFromLines(lineObjs, "y");

            obj.x = x;
            obj.y = y;
            obj.xPixels = limitsToPixels(ax, x, "x");
            obj.yPixels = limitsToPixels(ax, y, "y");
            obj.lineCount = numel(lineObjs);
            obj.linePointCount = linePointCount;
        end
    end

    %% Functions to retrieve state information
    methods (Access = private)
        function closestLine = getClosestLine(obj, xyMousePixels)
            x = obj.xPixels;
            y = obj.yPixels;
            closestIndex = getClosestIndex(xyMousePixels, x, y);
            closestLine = obj.getLineObjects(closestIndex);
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

    %% Function sto update state information
    methods (Access = private)
        function resetPreviewLines(obj)
            obj.previewIndices = [];
        end
    end

    %% Functions to update state of GUI
    methods (Access = protected)
        function updateAccentLines(obj, closestLine)
            if nargin < 2
                closestLine = [];
            end
            previewedLines = obj.getPreviewedLines();
            accentLines = [previewedLines, closestLine];
            obj.accentLineColor(accentLines);
            obj.accentLineWidth(closestLine);
        end
    end
    methods (Access = private)
        function mouseExited(obj, source, event)
            obj.updateAccentLines();
            obj.afterAxisExit(source, event);
        end
        function onAxisHover(obj, ~, event)
            ax = obj.getAxis();
            xyMousePixels = hoverEventToPixels(ax, event);
            closestLine = obj.getClosestLine(xyMousePixels);
            obj.updateAccentLines(closestLine);
            obj.afterAxisHover(closestLine, event);
        end
        function axisButtonDown(obj, ~, event)
            eventName = event.EventName;
            if eventName == "Hit"
                ax = obj.getAxis();
                xyMousePixels = hitEventToPixels(ax, event);
                closestLine = obj.getClosestLine(xyMousePixels);
                closestLine.ButtonDownFcn(closestLine, event);
                obj.updateAccentLines();
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



function xIndexMin = getClosestIndex(xyMouse, x, y)
xyDistance = (x - xyMouse(1)).^2 + (y - xyMouse(2)).^2;
[~, xyIndexMin] = min(xyDistance(:));
[xIndexMin, ~] = ind2sub(size(xyDistance), xyIndexMin);
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
