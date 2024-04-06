classdef WaterfallLinker < handle
    properties (Access = private)
        gui;
        mainAxis;
        lineAccenter;
        linePreviewer;
    end

    methods
        function obj = WaterfallLinker(gui, y, t)
            ax = gui.getAxis();
            mainAxis = ClosestLineAxes(ax, y, t);
            lineObjs = mainAxis.getLineObjects();
            alphaSlider = gui.getAlphaSlider();
            % colorPicker = gui.getColorPicker();

            set(alphaSlider, "ValueChangingFcn", @obj.alphaChanging);
            % set(colorPicker, "ValueChangedFcn", @obj.colorChanged);
            addlistener(mainAxis, "ClosestLine", "PostSet", @obj.closestLineChanged);

            obj.linePreviewer = LinePreviewer(lineObjs);
            obj.lineAccenter = LineAccenter(lineObjs);
            % obj.mainAxis = mainAxis;
            obj.gui = gui;

            alphaSlider.ValueChangingFcn(alphaSlider, struct("Value", alphaSlider.Value));
            % colorPicker.ValueChangedFcn(colorPicker, struct("Value", colorPicker.Value));
        end
    end

    %% Functions to generate GUI
    methods (Static)
        function openFigure(traces, time)
            fig = uifigure();
            gui = WaterfallGui(fig);
            WaterfallLinker(gui, traces, time);
        end
    end

    %% Functions to update state of GUI
    methods (Access = private)
        function closestLineChanged(obj, ~, event)
            closestLine = event.AffectedObject.ClosestLine;
            displayLineLabel(obj, closestLine);
            updateAccentLines(obj, closestLine);
        end
        % function colorChanged(obj, ~, event)
        %     color = event.Value;
        %     obj.setColor(color);
        %     obj.updateAccentLines();
        % end
        function alphaChanging(obj, ~, event)
            alpha = event.Value;
            obj.lineAccenter.setDefaultAlpha(alpha);
            updateAccentLines(obj);
        end
    end
end


function displayLineLabel(obj, lineObj)
labelElement = obj.gui.getLabelElement();
lineLabel = getLineLabel(lineObj);
set(labelElement, "Text", lineLabel);
end

function lineLabel = getLineLabel(lineObj)
lineLabel = "";
if numel(lineObj) == 1
    lineLabel = lineObj.Tag;
end
end

function updateAccentLines(obj, closestLine)
if nargin < 2
    closestLine = [];
end
lineAccenter = obj.lineAccenter;
accentLines = getAccentLines(obj, closestLine);
lineAccenter.accentLineColor(accentLines);
lineAccenter.accentLineWidth(closestLine);
end

function accentLines = getAccentLines(obj, closestLine)
accentLines = obj.linePreviewer.getPreviewedLines();
if ~ismember(closestLine, accentLines)
    accentLines = [accentLines, closestLine];
end
end
