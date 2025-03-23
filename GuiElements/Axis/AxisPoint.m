classdef AxisPoint
    %% Functions to calculate information about points on axis
    methods (Static)
        function xyz = get(ax)
            xyz = get(ax, "CurrentPoint");
            xyz = xyz(1, :);
        end
        function xy = getXy(ax)
            xyz = AxisPoint.get(ax);
            xy = xyz(1:2);
        end
        function x = getX(ax)
            xyz = AxisPoint.get(ax);
            x = xyz(1);
        end
        function y = getY(ax)
            xyz = AxisPoint.get(ax);
            y = xyz(2);
        end
        function z = getZ(ax)
            xyz = AxisPoint.get(ax);
            z = xyz(3);
        end

        function is = mouseIsOver(ax)
            pointX = AxisPoint.getX(ax);
            pointY = AxisPoint.getY(ax);

            xlim = get(ax, "XLim");
            ylim = get(ax, "YLim");
            inX = xlim(1) <= pointX && pointX <= xlim(2);
            inY = ylim(1) <= pointY && pointY <= ylim(2);
            is = inX && inY;
        end

        function xyPixel = eventToPixel(ax, event)
            if isnumeric(event)
                axPosition = get(ax, "InnerPosition");
                xyPixel = event - axPosition(1:2);
                return;
            end
            xyMouse = event.IntersectionPoint;
            xyPixel = AxisPoint.toPixel(ax, xyMouse);
        end

        function xyPixel = toPixel(ax, point)
            xPixel = AxisPoint.toPixelX(ax, point(1));
            yPixel = AxisPoint.toPixelY(ax, point(2));
            xyPixel = [xPixel, yPixel];
        end
        function xPixel = toPixelX(ax, x)
            axUnits = get(ax, "Units");
            set(ax, "Units", "pixels");

            axPosition = get(ax, "InnerPosition");
            xLim = get(ax, "XLim");
            xMin = xLim(1);
            xMax = xLim(2);
            axLength = axPosition(3);

            xPixel = axLength .* (x - xMin) ./ (xMax - xMin);
            set(ax, "Units", axUnits);
        end
        function yPixel = toPixelY(ax, y)
            axUnits = get(ax, "Units");
            set(ax, "Units", "pixels");

            axPosition = get(ax, "InnerPosition");
            yLim = get(ax, "YLim");
            yMin = yLim(1);
            yMax = yLim(2);
            axLength = axPosition(4);

            yPixel = axLength .* (y - yMin) ./ (yMax - yMin);
            set(ax, "Units", axUnits);
        end
    end

    %% Functions to calculate information about lines on axis
    methods (Static)
        function x = fromLinesX(lineObjs)
            x = vertcat(lineObjs.XData);
        end
        function y = fromLinesY(lineObjs)
            y = vertcat(lineObjs.YData);
        end
    end
end

