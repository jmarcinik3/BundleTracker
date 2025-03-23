classdef AxisDraggable
    properties (Access = private)
        element;
        buttonDownPoint;
        buttonDownFunction;
        buttonMotionFunction;
        buttonUpFunction;
    end

    methods
        function obj = AxisDraggable(element, varargin)
            p = inputParser();
            p.addOptional("ButtonDownFcn", @() 0);
            p.addOptional("ButtonMotionFcn", @(startPoint, currentPoint) 0);
            p.addOptional("ButtonUpFcn", @() 0);
            p.parse(varargin{:});

            obj.element = element;
            obj.buttonDownFunction = p.Results.ButtonDownFcn;
            obj.buttonMotionFunction = p.Results.ButtonMotionFcn;
            obj.buttonUpFunction = p.Results.ButtonUpFcn;
            set(element, "ButtonDownFcn", @obj.buttonDown);
        end
    end

    %% Functions to retrieve GUI elements
    methods (Access = private)
        function fig = getFigure(obj)
            ax = obj.getAxis();
            fig = ancestor(ax, "figure");
        end
        function ax = getAxis(obj)
            element = obj.element;
            ax = ancestor(element, "axes");
        end
    end

    %% Functions to handle interactive click events
    methods (Access = private)
        function buttonDown(obj, ~, ~)
            fig = obj.getFigure();
            ax = obj.getAxis();

            saveWindowFcn.Motion = get(fig, "WindowButtonMotionFcn");
            saveWindowFcn.Up = get(fig, "WindowButtonUpFcn");
            obj.buttonDownPoint = AxisPoint.get(ax);
            obj.buttonDownFunction();

            set(fig, ...
                "WindowButtonMotionFcn", @obj.buttonMotion, ...
                "WindowButtonUpFcn", @(src,ev) obj.buttonUp(src, ev, saveWindowFcn) ...
                );
        end
        function buttonMotion(obj, ~, ~)
            ax = obj.getAxis();
            previousPoint = obj.buttonDownPoint;
            currentPoint = AxisPoint.get(ax);
            obj.buttonMotionFunction(previousPoint, currentPoint);
        end
        function buttonUp(obj, ~, ~, previousWindowFcn)
            fig = obj.getFigure();
            set(fig, "pointer", "arrow");
            set(fig, "WindowButtonMotionFcn", previousWindowFcn.Motion);
            set(fig, "WindowButtonUpFcn", previousWindowFcn.Up);
            obj.buttonUpFunction();
        end
    end
end