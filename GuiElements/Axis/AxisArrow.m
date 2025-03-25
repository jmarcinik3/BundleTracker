classdef AxisArrow
    %% Functions to set aesthetics of arrow
    methods (Static)
        function setPosition(arrow, xy)
            set(arrow, "XData", xy(1), "YData", xy(2));
        end
        function setAngle(arrow, angle)
            length = AxisArrow.getLength(arrow);
            AxisArrow.setVelocity(arrow, length, angle);
        end
        function setLength(arrow, length)
            angle = AxisArrow.getAngle(arrow);
            AxisArrow.setVelocity(arrow, length, angle)
        end
        function setVelocity(arrow, length, angle)
            if AxisArrow.isInverted(arrow)
                angle = -angle;
            end
            set( ...
                arrow, ...
                "UData", length * cos(angle), ...
                "VData", length * sin(angle) ...
                );
        end
    end

    %% Functions to get state information of arrow
    methods (Static)
        function position = getTailPosition(arrow)
            x = get(arrow, "XData");
            y = get(arrow, "YData");
            position = [x, y];
        end
        function length = getLength(arrow)
            u = get(arrow, "UData");
            v = get(arrow, "VData");
            length = sqrt(u^2 + v^2);
        end
        function angle = getAngle(arrow)
            u = get(arrow, "UData");
            v = get(arrow, "VData");
            angle = atan2(v, u);
            if AxisArrow.isInverted(arrow)
                angle = -angle;
            end
        end
        
        function is = isInverted(arrow)
            ax = ancestor(arrow, "axes");
            is = strcmpi(get(ax, "YDir"), "reverse");
        end
    end
end