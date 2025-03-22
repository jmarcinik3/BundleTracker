classdef AxisArrowRotator < handle
    properties (Access = private)
        arrow;
    end

    methods
        function obj = AxisArrowRotator(varargin)
            arrow = quiver(varargin{:});
            AxisDraggable(arrow, "ButtonMotionFcn", @obj.buttonMotion);
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
            length = sum(sqrt(xLength^2 + yLength^2));
        end
    end

    %% Functions to handle interactive click events
    methods (Access = private)
        function buttonMotion(obj, ~, currentPoint)
            arrow = obj.getArrow();
            arrowLength = obj.getArrowLength();

            arrowPoint = [get(arrow, "XData"), get(arrow, "YData"), 0];
            positionDifference = currentPoint - arrowPoint;
            [theta, ~] = cart2pol(positionDifference(1), positionDifference(2));

            set( ...
                arrow, ...
                "UData", arrowLength * cos(theta), ...
                "VData", arrowLength * sin(theta) ...
                );
        end
    end
end