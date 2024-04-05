classdef LinePreviewer < handle
    properties (Access = private)
        originalAxis;
        previewAxis;
        originalLines;
        previewedLines = [];
        previewLines = [];
        previewLabels = [];
    end

    methods
        function obj = LinePreviewer(ax)
            originalLines = findobj(ax.Children, "Type", "Line");
            set(originalLines, "ButtonDownFcn", @obj.lineButtonDown);
            obj.originalAxis = ax;
            obj.originalLines = originalLines;
        end
    end

    %% Functions to retrieve GUI elements
    methods (Access = protected)
        function lineObjs = getPreviewedLines(obj)
            lineObjs = obj.previewedLines;
        end
    end
    methods (Access = private)
        function ax = getPreviewAxis(obj)
            ax = obj.previewAxis;
            if isempty(ax) || ~isvalid(ax)
                ax = gca;
                set(ax, "DeleteFcn", @obj.previewAxisDeleted);
                obj.previewAxis = ax;
            end
        end
        function lineObjs = getOriginalLines(obj)
            lineObjs = obj.originalLines;
        end
        function lineObjs = getPreviewLines(obj, index)
            if nargin == 1
                lineObjs = obj.previewLines;
            else
                lineObjs = obj.previewLines(index);
            end
        end
        function labels = getPreviewLabels(obj, index)
            if nargin == 1
                labels = obj.getPreviewLabels;
            else
                labels = obj.getPreviewLabels(index);
            end
        end
    end

    %% Functions to retrieve state information
    methods (Access = private)
        function exists = existsPreviewLine(obj)
            previewLines = obj.getPreviewLines();
            previewCount = numel(previewLines);
            exists = previewCount >= 1;
        end
    end

    %% Functions to update state information
    methods (Access = private)
        function resetPreviewLines(obj)
            obj.previewedLines = [];
            obj.previewLines = [];
        end
        function addPreviewToArray(obj, originalLine, previewLine)
            obj.previewedLines = [obj.previewedLines, originalLine];
            obj.previewLines = [obj.previewLines, previewLine];
        end
        function deleteIndex = removePreviewFromArray(obj, originalLine)
            previewedLines = obj.getPreviewedLines();
            deleteIndex = find(previewedLines == originalLine);
            previewLine = obj.getPreviewLines(deleteIndex);
            delete(previewLine);
            obj.previewedLines(deleteIndex) = [];
            obj.previewLines(deleteIndex) = [];
        end
    end

    %% Functions to update state of GUI
    methods (Access = protected)
        function toggleLinePreview(obj, lineObj)
            previewLines = obj.getPreviewedLines();
            if ~ismember(lineObj, previewLines)
                obj.addPreviewLine(lineObj);
            else
                obj.removePreviewLine(lineObj);
            end
        end
    end
    methods (Access = private)
        function lineButtonDown(obj, source, event)
            eventName = event.EventName;
            if eventName == "Hit"
                obj.toggleLinePreview(source);
                obj.updatePreviewLines();
            end
        end

        function updatePreviewLines(obj)
            if obj.existsPreviewLine()
                ax = obj.getPreviewAxis();
                WaterfallAxes.reOffsetLines(ax);
                relabelWaterfall(ax);
            end
        end
        function previewAxisDeleted(obj, ~, ~)
            obj.resetPreviewLines();
        end
        function addPreviewLine(obj, originalLine)
            ax = obj.getPreviewAxis();
            previewLine = plotLineOnAxis(ax, originalLine);
            obj.addPreviewToArray(originalLine, previewLine);
        end
        function removePreviewLine(obj, originalLine)
            obj.removePreviewFromArray(originalLine);
        end
    end
end



function previewLine = plotLineOnAxis(ax, originalLine)
originalTag = get(originalLine, "Tag");
xData = get(originalLine, "XData");
yData = get(originalLine, "YData");
yData = yData - mean(yData);

hold(ax, "on");
previewLine = plot(ax, xData, yData);
hold(ax, "off");
set(previewLine, "Tag", originalTag);
end

function newLabels = relabelWaterfall(ax)
lineObjs = findobj(ax.Children, "Type", "Line");
lineCount = numel(lineObjs);
axXlim = get(ax, "Xlim");
yDatas = WaterfallAxes.dataFromLines(lineObjs, 'y');

xText = interp1([0, 1], axXlim, 0.02) * ones(1, lineCount);
yText = mean(yDatas, 2);
labelText = get(lineObjs, "Tag");

previousLabels = findobj(ax.Children, "Type", "Text");
delete(previousLabels);
newLabels = text(ax, xText, yText, labelText);
end
