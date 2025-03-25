classdef Waterfall
    methods (Static)
        function lineObjs = plotOnAxis(ax, y, x, yOffsets)
            if nargin < 3
                x = 1:size(y, 2);
            end
            if nargin < 4
                yOffsets = calculateOffsets(y);
            end
            lineObjs = plotOnAxis(ax, y, x, yOffsets);
        end

        function reOffsetLines(obj)
            if isgraphics(obj, "axes")
                ax = obj;
                lineObjs = findobj(obj.Children, "Type", "Line");
            elseif isgraphics(obj, "line")
                lineObjs = obj;
                ax = ancestor(lineObjs(1), "axes");
            elseif isgraphics(obj, "scatter")
                lineObjs = obj;
                ax = ancestor(lineObjs(1), "axes");
            end

            

            reOffsetLines(lineObjs);
            rerangeY(ax, 0.05 / numel(lineObjs));
        end
    end
end



function lineObjs = plotOnAxis(ax, y, x, yOffsets)
yCount = size(y, 1);
yWithOffsets = y + yOffsets;
lineObjs = plot(ax, x, yWithOffsets);
rerangeY(ax, 0.05 / yCount);
end

function yOffsets = calculateOffsets(y, paddings)
% 1. For each point in time, calculate differences between adjacent traces 
% 2. For each pair of adjacent traces, calculate minimum of these differences
% 3. Cumulative offset from bottom trace up to top trace
% No adjacent traces intersect, but they can share a y-limit

yCount = size(y, 1);

if yCount == 1
    yOffsets = min(y(1, :));
    return;
end

yOffsets = -cumsum([ ...
    min(y(1, :)); ... % set bottom of first trace at zero
    min(diff(y, 1), [], 2) ... % ensure that no adjacent traces intersect
    ]);

if nargin < 2
    paddings = 0.02 * range(yOffsets);
end
yPaddings = (0:(yCount-1)).' .* paddings;
yOffsets = yOffsets + yPaddings;
end

function reOffsetLines(lineObjs)
yDatas = AxisPoint.fromLinesY(lineObjs);
yWithOffsets = yDatas + calculateOffsets(yDatas);
set(lineObjs, {"YData"}, num2cell(yWithOffsets, 2));
end

function rerangeY(ax, padding)
lineObjs = ax.Children;
yDatas = AxisPoint.fromLinesY(lineObjs);

yMin = min(yDatas, [], "all");
yMax = max(yDatas, [], "all");
yDiff = yMax - yMin;
yPadding = padding * yDiff;
yLimit = [yMin - yPadding, yMax + yPadding];
if range(yLimit) > 0
    set(ax, "YLim", yLimit);
end
end
