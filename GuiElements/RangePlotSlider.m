classdef RangePlotSlider < matlab.ui.componentcontainer.ComponentContainer
    properties
        Value (1, 2) {mustBeFloat, mustBeFloat} = [0, 1];
        Limits (1, 2) {mustBeFloat, mustBeFloat} = [0, 1];
        XData double = 0;
        YData double = 0;
    end

    events (HasCallbackProperty, NotifyAccess = protected)
        ValueChanging;
        ValueChanged;
    end

    properties (Access = private, Transient, NonCopyable)
        UIAxes matlab.ui.control.UIAxes;
        Line (1, 3);
        GridLayout matlab.ui.container.GridLayout;
    end

    methods (Access = protected)
        function setup(obj)
            gl = uigridlayout(obj, [1, 1], "Padding", 0);
            ax = generateEmptyAxis(gl);

            hold(ax, "on");
            primaryLine = plot( ...
                ax, ...
                0,  ...
                0,...
                "Color", "black" ...
                );
            lowerLine = generateLineX(ax, 0);
            upperLine = generateLineX(ax, 1);
            hold(ax, "off");
            set(ax, "YLim", [0, 1]);

            AxisDraggable( ...
                lowerLine, ...
                "ButtonMotionFcn", @obj.lowerLineMotion, ...
                "ButtonUpFcn", @obj.lowerLineUp ...
                );
            AxisDraggable( ...
                upperLine, ...
                "ButtonMotionFcn", @obj.upperLineMotion, ...
                "ButtonUpFcn", @obj.upperLineUp ...
                );

            obj.UIAxes = ax;
            obj.Line = [lowerLine, upperLine, primaryLine];
            obj.GridLayout = gl;
        end

        function update(obj)
            set(obj.Line(1), "Value", obj.Value(1));
            set(obj.Line(2), "Value", obj.Value(2));
            set(obj.UIAxes, "XLim", obj.Limits);
            set( ...
                obj.Line(3), ...
                "XData", obj.XData, ...
                "YData", mat2gray(obj.YData) ...
                );
        end
    end

    %% Functions to handle interactive click events
    methods (Access = private)
        function lowerLineMotion(obj, ~, currentPoint)
            notify(obj, "ValueChanging");
            xCurrent = max(currentPoint(1), obj.Limits(1));
            obj.Value(1) = xCurrent;
            if xCurrent > obj.Value(2)
                obj.Value(2) = xCurrent;
            end
        end
        function upperLineMotion(obj, ~, currentPoint)
            notify(obj, "ValueChanging");
            xCurrent = min(currentPoint(1), obj.Limits(2));
            obj.Value(2) = xCurrent;
            if xCurrent < obj.Value(1)
                obj.Value(1) = xCurrent;
            end
        end
        function lowerLineUp(obj)
            notify(obj, "ValueChanged");
        end
        function upperLineUp(obj)
            notify(obj, "ValueChanged");
        end
    end
end


function xLine = generateLineX(ax, x)
xLine = xline( ...
    ax, ...
    x, ...
    "Color", "black", ...
    "LineWidth", 2, ...
    "Alpha", 1 ...
    );
end