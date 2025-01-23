classdef DetrenderLinker < handle
    properties (Access = ?DetrenderOpener)
        detrendedTraces = [];
    end
    properties (Access = private)
        windowWidth;
        windowShape;
        gui;
        lineObjs;
        traces;
        time;
    end

    methods
        function obj = DetrenderLinker(gui, traces, dt)
            if nargin < 3
                dt = 1;
            end
            time = (0:size(traces, 2)-1) * dt;

            slider = gui.getWindowWidthSlider();
            dropdown = gui.getWindowShapeDropdown();
            set(slider, "ValueChangingFcn", @obj.sliderChanging);
            set(dropdown, "ValueChangedFcn", @obj.dropdownChanged);
            set(gui.getActionButtons(), "ButtonPushedFcn", @obj.actionButtonPushed);

            obj.gui = gui;
            obj.windowWidth = get(slider, "Value");
            obj.windowShape = get(dropdown, "Value");
            obj.traces = traces;
            obj.time = time;

            obj.lineObjs = Waterfall.plotOnAxis(gui.getAxis(), traces, time);
            obj.updateDisplay();
        end
    end

    %% Function to update display of GUI
    methods (Access = private)
        function updateDisplay(obj)
            lineObjs = obj.lineObjs;
            tracesDetrended = obj.getDetrendedTraces();
            set(lineObjs, {"YData"}, num2cell(tracesDetrended, 2));
            Waterfall.reOffsetLines(lineObjs);
        end

        function sliderChanging(obj, ~, event)
            newWindowWidth = round(event.Value);
            if newWindowWidth ~= obj.windowWidth
                obj.windowWidth = newWindowWidth;
                obj.updateDisplay();
            end
        end
        function dropdownChanged(obj, ~, event)
            newWindowShape = event.Value;
            if ~strcmp(newWindowShape, obj.windowShape)
                obj.windowShape = newWindowShape;
                obj.updateDisplay();
            end
        end
        function actionButtonPushed(obj, source, ~)
            gui = obj.getGui();
            fig = gui.getFigure();
            if source == gui.getApplyButton()
                obj.detrendedTraces = obj.getDetrendedTraces();
            end
            close(fig);
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function gui = getGui(obj)
            gui = obj.gui;
        end
    end

    %% Helper functions to retrieve GUI elements and state information
    methods (Access = private)
        function axis = getAxis(obj)
            axis = obj.getGui().getAxis();
        end
        function traces = getTraces(obj)
            traces = obj.traces;
        end
        function tracesDetrended = getDetrendedTraces(obj)
            tracesDetrended = detrendTraces( ...
                obj.getTraces(), ...
                obj.windowWidth, ...
                obj.windowShape ...
                );
        end
        function time = getTime(obj)
            time = obj.time;
        end
    end
end



function xCorrected = detrendTraces(x, windowWidth, windowShape)
xCorrected = zeros(size(x));
traceCount = size(x, 1);

for xIndex = 1:traceCount
    xi = x(xIndex, :);
    xCorrected(xIndex, :) = detrendTrace(xi, windowWidth, windowShape);
end
end
function xCorrected = detrendTrace(x, windowWidth, windowShape)
x = detrend(x, 1);
ma = MovingAverage.averageByKeyword(x, windowWidth, windowShape);
xCorrected = x - ma;
end
