classdef AxisWindow < handle
    properties (Access = private)
        windowLine;
        minWindowSize = 5;
        maxWindowSize = 0;
        dragSensitivity = 0.1;
        dragStartValue = [];
    end

    properties (SetObservable = true)
        WindowSize = 0;
        WindowName = "Hann";
    end

    methods
        function obj = AxisWindow(ax, maxWindowSize, windowName)
            if nargin < 3
                windowName = "Hann";
            end

            windowLine = area( ...
                ax, ...
                0, ...
                0, ...
                "EdgeColor", "black", ...
                "FaceColor", "black" ...
                );
            AxisDraggable( ...
                [ax, windowLine], ...
                "ButtonDownFcn", @obj.buttonDown, ...
                "ButtonMotionFcn", @obj.buttonMotion ...
                );
            set(ax, "XLim", 0.5 * maxWindowSize * [-1, 1]);

            fig = ancestor(ax, "figure");
            set(fig, "WindowScrollWheelFcn", @obj.windowScrollWheelFcn);

            obj.windowLine = windowLine;
            obj.WindowSize = maxWindowSize;
            obj.maxWindowSize = maxWindowSize;
            obj.dragSensitivity = 1 / nthroot(maxWindowSize, 3.5);
            obj.WindowName = windowName;
            obj.refreshWindow();
        end
    end

    methods (Static)
        function ax = generateAxis(gl)
            ax = uiaxes( ...
                gl, ...
                "Toolbar", [], ...
                "Interactions", [], ...
                "YLim", [0, 1], ...
                "Color", "none" ...
                );
            ax.XAxis.Visible = "off";
            ax.YAxis.Visible = "off";
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods
        function sz = getWindowSize(obj)
            sz = obj.WindowSize;
        end
        function sz = getMinWindowSize(obj)
            sz = obj.minWindowSize;
        end
        function sz = getMaxWindowSize(obj)
            sz = obj.maxWindowSize;
        end
        function name = getWindowName(obj)
            name = obj.WindowName;
        end
        function windowArray = getWindowArray(obj)
            windowSize = obj.getWindowSize();
            windowName = obj.getWindowName();
            windowArray = MovingAverage.windowByKeyword(windowSize, windowName);
        end
    end
    methods (Access = private)
        function fig = getFigure(obj)
            ax = obj.getAxis();
            fig = ancestor(ax, "figure");
        end
        function ax = getAxis(obj)
            windowLine = obj.getLine();
            ax = get(windowLine, "Parent");
        end
        function windowLine = getLine(obj)
            windowLine = obj.windowLine;
        end
    end

    methods (Access = private)
        function refreshWindow(obj)
            ax = obj.getAxis();
            windowLine = obj.getLine();
            maxWindowSize = obj.getMaxWindowSize();
            windowSize = obj.getWindowSize();
            windowName = obj.getWindowName();
            windowArray = obj.getWindowArray();

            x = linspace(-0.5*(windowSize-1), 0.5*(windowSize-1), windowSize);
            x = [-maxWindowSize, x(1), x, x(end), maxWindowSize];
            windowArray = [0, 0, windowArray.', 0, 0].';

            set(windowLine, "XData", x, "YData", windowArray);
            title(ax, windowName);
        end
        function setWindowSize(obj, windowSize)
            windowSize = min(windowSize, obj.getMaxWindowSize());
            windowSize = max(windowSize, obj.getMinWindowSize());
            obj.WindowSize = windowSize;
            obj.refreshWindow();
        end
        function setWindowName(obj, windowName)
            obj.WindowName = windowName;
            obj.refreshWindow();
        end
    end

    %% Functions to handle interactive click events
    methods (Access = private)
        function buttonDown(obj, ~, ~)
            obj.dragStartValue = obj.getWindowSize();
        end
        function buttonMotion(obj, previousPoint, currentPoint)
            dy = currentPoint(2) - previousPoint(2);
            windowChange = obj.dragSensitivity * dy * obj.getMaxWindowSize();
            newWindowSize = round(obj.dragStartValue + windowChange);
            obj.setWindowSize(newWindowSize);
        end

        function windowScrollWheelFcn(obj, ~, event)
            ax = obj.getAxis();
            if ~AxisPoint.mouseIsOver(ax)
                return;
            end

            scrollDirection = event.VerticalScrollCount;
            windowName = obj.getWindowName();
            newWindowName = MovingAverage.getAdjacentName(windowName, -scrollDirection);
            obj.setWindowName(newWindowName);
        end
    end
end