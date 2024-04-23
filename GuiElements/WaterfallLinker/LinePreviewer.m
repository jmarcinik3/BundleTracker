classdef LinePreviewer < handle
    properties (Access = private)
        previewAxis;
        originalLines;
        previewedLines = [];
        previewLines = [];
    end

    methods
        function obj = LinePreviewer(originalLines)
            set(originalLines, "ButtonDownFcn", @obj.lineButtonDown);
            obj.originalLines = originalLines;
        end
    end

    %% Functions to retrieve GUI elements
    methods
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
    end

    %% Functions to retrieve state information
    methods (Access = private)
        function exists = existsPreviewLine(obj)
            exists = numel(obj.getPreviewLines()) >= 1;
        end
        function index = getLineIndex(obj, lineObj)
            previewLines = obj.getPreviewLines();
            previewedLines = obj.getPreviewedLines();
            if obj.isPreviewLine(lineObj)
                index = find(previewLines == lineObj);
            elseif obj.isPreviewedLine(lineObj)
                index = find(previewedLines == lineObj);
            end
        end

        function is = isPreviewedLine(obj, lineObj)
            previewedLines = obj.getPreviewedLines();
            is = ismember(lineObj, previewedLines);
        end
        function is = isPreviewLine(obj, lineObj)
            previewLines = obj.getPreviewLines();
            is = ismember(lineObj, previewLines);
        end
        function is = isOriginalLine(obj, lineObj)
            originalLines = obj.getOriginalLines();
            is = ismember(lineObj, originalLines);
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
        function deleteIndex = removeLine(obj, lineObj)
            deleteIndex = obj.getLineIndex(lineObj);
            previewLine = obj.getPreviewLines(deleteIndex);
            delete(previewLine);
            obj.previewedLines(deleteIndex) = [];
            obj.previewLines(deleteIndex) = [];
        end
    end

    %% Functions to update state of GUI
    methods (Access = protected)
        function toggleLinePreview(obj, lineObj)
            isOriginal = obj.isOriginalLine(lineObj);
            isPreviewed = obj.isPreviewedLine(lineObj);
            isPreview = obj.isPreviewLine(lineObj);

            if isPreview || (isOriginal && isPreviewed)
                obj.removeLine(lineObj);
            elseif isOriginal && ~isPreviewed
                obj.addPreviewedLine(lineObj);
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
                ClosestLineAxes.reOffsetLines(ax);
                relabelWaterfall(ax);
            end
        end
        function previewAxisDeleted(obj, ~, ~)
            obj.resetPreviewLines();
        end
        function addPreviewedLine(obj, originalLine)
            ax = obj.getPreviewAxis();
            previewLine = plotLineOnAxis(ax, originalLine);
            obj.addPreviewToArray(originalLine, previewLine);
            set(previewLine, "ButtonDownFcn", @obj.lineButtonDown);
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
yDatas = ClosestLineAxes.dataFromLines(lineObjs, 'y');

xText = interp1([0, 1], axXlim, 0.02) * ones(1, lineCount);
yText = mean(yDatas, 2);
labelText = get(lineObjs, "Tag");

previousLabels = findobj(ax.Children, "Type", "Text");
delete(previousLabels);
newLabels = text(ax, xText, yText, labelText);
end
