classdef LineScalebar < handle
    properties (Access = private)
        border = 'LL'; % 'LL', 'LR', 'UL', 'UR'
        axis;
        scalebarLine;
        hitRectangle;
        buttonDownPoint = [0, 0];
        dragStartValue = [];
    end

    properties (SetObservable = true, Access = private)
        Position = [0, 0, 1, 1];
    end

    methods
        function obj = LineScalebar(ax)
            scalebarLine = plot(ax, [0, 0, 1], [1, 0, 0]);
            hitRectangle = rectangle("PickableParts", "all", "Visible", "off");
            menu = uicontextmenu();
            uimenu(menu, ...
                "Label", "Rotate Scalebar", ...
                "Callback", @(src,ev) obj.uiRotateScalebar() ...
                );
            uimenu(menu, ...
                "Label", "Toggle Axis Visibility", ...
                "Callback", @(src,ev) obj.uiToggleAxisVisibility() ...
                );
            set( ...
                [scalebarLine, hitRectangle], ...
                "Parent", ax, ...
                "ContextMenu", menu, ...
                "ButtonDownFcn", @obj.buttonDownLine ...
                );

            axisXLim = get(ax, "XLim");
            axisYLim = get(ax, "YLim");
            axisXWidth = diff(axisXLim);
            axisYWidth = diff(axisYLim);
            obj.Position(1:2) = [ ...
                axisXLim(1) + 0.05*axisXWidth, ...
                axisYLim(1) + 0.05*axisYWidth ...
                ];

            obj.axis = ax;
            obj.scalebarLine = scalebarLine;
            obj.hitRectangle = hitRectangle;
            obj.refreshPosition();
        end
    end

    methods
        function fig = getFigure(obj)
            ax = obj.getAxis();
            fig = ancestor(ax, "figure");
        end
        function ax = getAxis(obj)
            ax = obj.axis;
        end
        function scalebarLine = getLine(obj)
            scalebarLine = obj.scalebarLine;
        end
        function color = getColor(obj)
            color = get(obj.getLine(), "Color");
        end
        function border = getBorder(obj)
            border = obj.border;
        end

        function position = getPosition(obj)
            position = obj.Position;
        end
        function position = getPositionXy(obj)
            position = obj.getPosition();
            position = position(1:2);
        end
        function x = getPositionX(obj)
            position = obj.getPosition();
            x = position(1);
        end
        function y = getPositionY(obj)
            position = obj.getPosition();
            y = position(2);
        end
        function w = getWidth(obj)
            position = obj.getPosition();
            w = position(3);
        end
        function h = getHeight(obj)
            position = obj.getPosition();
            h = position(4);
        end
    end

    %% Functions to set state through GUI
    methods (Access = private)
        function uiRotateScalebar(obj, ~, ~)
            border = obj.getBorder();
            switch border
                case 'LL'; newBorder = 'UL';
                case 'LR'; newBorder = 'LL';
                case 'UR'; newBorder = 'LR';
                case 'UL'; newBorder = 'UR';
            end
            obj.setBorder(newBorder);
        end
        function uiToggleAxisVisibility(obj, ~, ~)
            ax = obj.getAxis();
            visiblePre = get(ax, "Visible");
            if strcmpi(visiblePre, "on")
                visiblePost = "off";
            else
                visiblePost = "on";
            end
            set(ax, "Visible", visiblePost);
        end
    end

    %% Functiosn to update aesthetics of scalebar
    methods (Access = private)
        function refreshPosition(obj)
            scalebarLine = obj.getLine();
            border = obj.getBorder();

            switch upper(border)
                case 'LL'
                    dx = [0, 0, 1];
                    dy = [1, 0, 0];
                case 'LR'
                    dx = [0, 1, 1];
                    dy = [0, 0, 1];
                case 'UR'
                    dx = [1, 1, 0];
                    dy = [0, 1, 1];
                case 'UL'
                    dx = [1, 0, 0];
                    dy = [1, 1, 0];
            end

            x = obj.getPositionX();
            y = obj.getPositionY();
            w = obj.getWidth();
            h = obj.getHeight();
            set(scalebarLine, ...
                "XData", x + w * dx, ...
                "YData", y + h * dy ...
                );
            set(obj.hitRectangle, "Position", [x, y, w, h]);
        end
    end

    %% Functions to set position and aesthetics of scalebar
    methods
        function setPosition(obj, position)
            obj.Position(1:numel(position)) = position;
            obj.refreshPosition();
        end
        function setPositionX(obj, x)
            position = obj.getPosition();
            position(1) = x;
            obj.setPosition(position);
        end
        function setPositionY(obj, y)
            position = obj.getPosition();
            position(2) = y;
            obj.setPosition(position);
        end
        function setWidth(obj, w)
            position = obj.getPosition();
            position(3) = w;
            obj.setPosition(position);
        end
        function setHeight(obj, h)
            position = obj.getPosition();
            position(4) = h;
            obj.setPosition(position);
        end
        function setBorder(obj, border)
            obj.border = border;
            obj.refreshPosition();
        end
    end

    %% Functions to calculate realtime state information
    methods (Access = private)
        function isCloser = isCloserToCorner(obj, event)
            ax = obj.getAxis();

            cornerPosition = AxisPoint.toPixel(ax, obj.getCornerPosition());
            prePosition = AxisPoint.toPixel(ax, obj.getPreCornerPosition());
            postPosition = AxisPoint.toPixel(ax, obj.getPostCornerPosition());
            eventPosition = AxisPoint.toPixel(ax, event.IntersectionPoint(1, 1:2));

            cornerDistance = sqrt(sum((eventPosition - cornerPosition).^2));
            preDistance = sqrt(sum((eventPosition - prePosition).^2));
            postDistance = sqrt(sum((eventPosition - postPosition).^2));
            isCloser = cornerDistance <= preDistance && cornerDistance <= postDistance;
        end
        function point = getCornerPosition(obj)
            scalebarLine = obj.getLine();
            x = get(scalebarLine, "XData");
            y = get(scalebarLine, "YData");
            point = [x(2), y(2)];
        end
        function point = getPreCornerPosition(obj)
            scalebarLine = obj.getLine();
            x = get(scalebarLine, "XData");
            y = get(scalebarLine, "YData");
            point = [x(1), y(1)];
        end
        function point = getPostCornerPosition(obj)
            scalebarLine = obj.getLine();
            x = get(scalebarLine, "XData");
            y = get(scalebarLine, "YData");
            point = [x(3), y(3)];
        end
        function point = getAntiCornerPosition(obj)
            scalebarLine = obj.getLine();
            x = get(scalebarLine, "XData");
            y = get(scalebarLine, "YData");
            point = [x(3), y(1)];
        end

        function is = isCloserToHorizontalLine(obj, event)
            ax = obj.getAxis();

            verticalLineX = AxisPoint.toPixelX(ax, obj.getVerticalLineX());
            horizontalLineY = AxisPoint.toPixelY(ax, obj.getHorizontalLineY());
            eventPosition = AxisPoint.toPixel(ax, event.IntersectionPoint(1, 1:2));

            distanceToVertical = abs(eventPosition(1) - verticalLineX);
            distanceToHorizontal = abs(eventPosition(2) - horizontalLineY);
            is = distanceToHorizontal <= distanceToVertical;
        end
        function is = isCloserToVerticalLine(obj, event)
            is = ~obj.isCloserToHorizontalLine(event);
        end
        function x = getVerticalLineX(obj)
            scalebarLine = obj.getLine();
            xLine = get(scalebarLine, "XData");
            x = xLine(2);
        end
        function y = getHorizontalLineY(obj)
            scalebarLine = obj.getLine();
            yLine = get(scalebarLine, "YData");
            y = yLine(2);
        end
    end

    %% Functions to handle interactive click events
    methods (Access = private)
        function buttonDownLine(obj, source, event)
            fig = obj.getFigure();
            ax = obj.getAxis();

            previousWindowFcn.Motion = get(fig, "WindowButtonMotionFcn");
            previousWindowFcn.Up = get(fig, "WindowButtonUpFcn");
            obj.buttonDownPoint = AxisPoint.getXy(ax);

            if obj.isCloserToCorner(event)
                obj.dragStartValue = obj.getPositionXy();
                motionFcn = @obj.moveScalebar;
            elseif obj.isCloserToHorizontalLine(event)
                obj.dragStartValue = obj.getWidth();
                motionFcn = @obj.stretchScalebar;
            elseif obj.isCloserToVerticalLine(event)
                obj.dragStartValue = obj.getHeight();
                motionFcn = @obj.stretchScalebar;
            end

            set(fig, ...
                "WindowButtonMotionFcn", @(src,ev) motionFcn(source, event), ...
                "WindowButtonUpFcn", @(src,ev) obj.buttonUp(source, event, previousWindowFcn) ...
                );
        end

        function moveScalebar(obj, ~, ~)
            ax = obj.getAxis();
            currentPoint = AxisPoint.getXy(ax);
            previousPoint = obj.buttonDownPoint;
            position = obj.dragStartValue + (currentPoint - previousPoint);
            obj.setPosition(position);
        end
        function stretchScalebar(obj, ~, event)
            ax = obj.getAxis();
            currentPoint = AxisPoint.getXy(ax);
            previousPoint = obj.buttonDownPoint;
            dxyPoint = currentPoint - previousPoint;

            if obj.isCloserToHorizontalLine(event)
                newLength = roundToNice(obj.dragStartValue + dxyPoint(1));
                obj.setWidth(newLength);
            elseif obj.isCloserToVerticalLine(event)
                newLength = roundToNice(obj.dragStartValue + dxyPoint(2));
                obj.setHeight(newLength);
            end
        end

        function buttonUp(obj, ~, ~, previousWindowFcn)
            fig = obj.getFigure();
            set(fig, "pointer", "arrow");
            set(fig, "WindowButtonMotionFcn", previousWindowFcn.Motion);
            set(fig, "WindowButtonUpFcn", previousWindowFcn.Up);
        end
    end
end



function xNear = roundToNice(x)
if x < 0
    xNear = 10;
    return;
end

scale = [1, 2, 2.5, 5, 7.5];
order = 10.^floor(log10(x));
xDiff = abs(scale - x/order);
[~, ind] = min(xDiff);
xNear = scale(ind) * order;
end
