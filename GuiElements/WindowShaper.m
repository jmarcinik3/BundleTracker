classdef WindowShaper < matlab.ui.componentcontainer.ComponentContainer
    properties
        MinWindowSize {mustBeNonnegative} = 0;
        MaxWindowSize {mustBeNonnegative} = 512;
        DragSensitivity double = 1;
        DragStartValue;
        IncludeTitle = true;
    end

    properties (SetObservable = true)
        WindowSize {mustBeFinite} = 1;
        WindowName string = "Hann";
    end

    events (HasCallbackProperty, NotifyAccess = protected)
        ValueChanging;
        ValueChanged;
    end

    properties (Dependent)
        Title;
    end

    properties (Access = private, Transient, NonCopyable)
        UIAxes matlab.ui.control.UIAxes;
        Line;
    end

    methods (Access = protected)
        function setup(obj)
            gl = uigridlayout(obj, [1, 1], "Padding", 0);
            
            ax = uiaxes( ...
                gl, ...
                "Toolbar", [], ...
                "Interactions", [], ...
                "YLim", [0, 1], ...
                "Color", "none", ...
                "XTickLabel", [], ...
                "YTickLabel", [] ...
                );
            ax.XAxis.Visible = "off";
            ax.YAxis.Visible = "off";

            windowLine = area( ...
                ax, 0, 0, ...
                "EdgeColor", "black", ...
                "FaceColor", "black" ...
                );
            AxisDraggable( ...
                [ax, windowLine], ...
                "ButtonDownFcn", @obj.buttonDown, ...
                "ButtonMotionFcn", @obj.buttonMotion, ...
                "ButtonUpFcn", @obj.buttonUp ...
                );

            fig = ancestor(ax, "figure");
            set(fig, "WindowScrollWheelFcn", @obj.windowScrollWheelFcn);

            obj.UIAxes = ax;
            obj.Line = windowLine;
        end

        function update(obj)
            ax = obj.UIAxes;
            maxWindowSize = obj.MaxWindowSize;
            windowSize = obj.WindowSize;            

            set(ax, "XLim", 0.5 * (maxWindowSize-1) * [-1, 1]);
            title(ax, obj.Title);
            obj.DragSensitivity = 1 / nthroot(maxWindowSize, 3.5);
            
            if windowSize < 0
                return;
            elseif windowSize == 0
                x = [-maxWindowSize, 0, 0, 0, maxWindowSize];
                windowArray = [0, 0, 1, 0, 0];
                set(obj.Line, "XData", x, "YData", windowArray);
                return;
            end

            windowArray = obj.getWindowArray();
            xMax = 0.5 * (windowSize - 1);
            x = linspace(-xMax, xMax, windowSize);
            x = [-maxWindowSize, x(1), x, x(end), maxWindowSize];
            windowArray = [0, 0, windowArray.', 0, 0];
            set(obj.Line, "XData", x, "YData", windowArray);
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods
        function t = get.Title(obj)
            t = "";
            if obj.IncludeTitle
                t = obj.WindowName;
            end
        end
        function windowArray = getWindowArray(obj)
            windowSize = obj.WindowSize;
            windowName = obj.WindowName;
            windowArray = MovingAverage.windowByKeyword(windowSize, windowName);
        end
    end

    %% Functions to set properties
    methods
        function set.WindowSize(obj, windowSize)
            windowSize = max(windowSize, obj.MinWindowSize);
            windowSize = min(windowSize, obj.MaxWindowSize);
            obj.WindowSize = windowSize;
        end
    end

    %% Functions to handle interactive click events
    methods (Access = private)
        function buttonDown(obj, ~, ~)
            obj.DragStartValue = obj.WindowSize;
        end
        function buttonMotion(obj, previousPoint, currentPoint)
            dy = currentPoint(2) - previousPoint(2);
            windowChange = obj.DragSensitivity * dy * obj.MaxWindowSize();
            newWindowSize = round(obj.DragStartValue + windowChange);
            obj.WindowSize = newWindowSize;
            notify(obj, "ValueChanging");
        end
        function buttonUp(obj)
            notify(obj, "ValueChanged");
        end

        function windowScrollWheelFcn(obj, ~, event)
            ax = obj.UIAxes;
            if ~AxisPoint.mouseIsOver(ax)
                return;
            end

            scrollDirection = event.VerticalScrollCount;
            windowName = obj.WindowName;
            newWindowName = MovingAverage.getAdjacentName(windowName, -scrollDirection);
            obj.WindowName = newWindowName;
        end
    end
end