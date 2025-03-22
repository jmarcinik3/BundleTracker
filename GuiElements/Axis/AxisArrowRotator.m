classdef AxisArrowRotator < handle
    properties (Access = private)
        arrow;
    end

    methods
        function obj = AxisArrowRotator(varargin)
            arrow = quiver(varargin{:});
            AxisDraggable( ...
                arrow, ...
                "ButtonDownFcn", @obj.buttonDown, ...
                "ButtonMotionFcn", @obj.buttonMotion ...
                );
            obj.arrow = arrow;
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods
        function arrow = getArrow(obj)
            arrow = obj.arrow;
        end
    end
    methods (Access = private)
        function position = getArrowTailPosition(obj)
            arrow = obj.getArrow();
            xPosition = get(arrow, "XData");
            yPosition = get(arrow, "YData");
            position = [xPosition, yPosition];
        end
        function length = getArrowLength(obj)
            arrow = obj.getArrow();
            xLength = get(arrow, "UData");
            yLength = get(arrow, "VData");
            length = sqrt(xLength^2 + yLength^2);
        end
    end

    %% Functions to handle interactive click events
    methods (Access = private)
        function buttonDown(obj)
            arrow = obj.getArrow();
            set(arrow, "UData", get(arrow, "UData"));
            set(arrow, "VData", get(arrow, "VData"));
        end
        function buttonMotion(obj, ~, currentPoint)
            arrow = obj.getArrow();
            arrowLength = obj.getArrowLength();
            arrowPoint = [obj.getArrowTailPosition(), 0];
            positionDifference = currentPoint - arrowPoint;
            theta = atan2(positionDifference(2), positionDifference(1));
            set( ...
                arrow, ...
                "UData", arrowLength * cos(theta), ...
                "VData", arrowLength * sin(theta) ...
                );
        end
    end
end