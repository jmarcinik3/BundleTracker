classdef ArrowRotator < handle
    properties (Access = private)
        arrow;
    end
    properties (SetObservable = true)
        Angle;
    end

    methods
        function obj = ArrowRotator(arrow)
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
    methods
        function position = getTailPosition(obj)
            arrow = obj.getArrow();
            position = AxisArrow.getTailPosition(arrow);
        end
        function length = getLength(obj)
            arrow = obj.getArrow();
            length = AxisArrow.getLength(arrow);
        end
        function angle = getAngle(obj)
            arrow = obj.getArrow();
            angle = AxisArrow.getAngle(arrow);
        end
    end

    %% Functions to set aesthetics
    methods
        function setPosition(obj, xy)
            arrow = obj.getArrow();
            AxisArrow.setPosition(arrow, xy);
        end
        function setAngle(obj, angle)
            arrow = obj.getArrow();
            AxisArrow.setAngle(arrow, angle);
            obj.Angle = angle;
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
            arrowPoint = [obj.getTailPosition(), 0];
            
            positionDifference = currentPoint - arrowPoint;
            if AxisArrow.isInverted(arrow)
                positionDifference(2) = -positionDifference(2);
            end

            theta = atan2(positionDifference(2), positionDifference(1));
            obj.setAngle(theta);
        end
    end
end