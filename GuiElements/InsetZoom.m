classdef InsetZoom < handle
    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>

        figure;
        primaryAx;
        insetAx;
        insetCursor;

        insetPresent = false;
        magnification;
        scale;

        magnificationFactor = 2^(1/12);
        scaleFactor = 2^(1/12);
        increaseScaleChars = '+=';
        decreaseScaleChars = '-_';
    end

    methods
        function obj = InsetZoom(ax, insetMagnification, scale)
            %
            % magnify(f1)
            %
            %  Figure creates a magnification box when under the mouse
            %  position when a button is pressed.  Press "+"/"-" while
            %  button pressed to increase/decrease magnification. Press
            %  ">"/"<" while button pressed to increase/decrease box size.
            %  Hold "Ctrl" while clicking to leave magnification on figure.
            %
            %  Example:
            %     plot(1:100,randn(1,100),(1:300)/3,rand(1,300)), grid on,
            %     magnify;

            % Rick Hindman - 7/29/04

            if (nargin == 0)
                ax = gca;
                insetMagnification = 2;
                scale = 0.2;
            end

            fig = ancestor(ax, "figure");
            obj.prepareFigure(ax);

            obj.figure = fig;
            obj.primaryAx = ax;
            obj.magnification = insetMagnification;
            obj.scale = scale;
        end

        function prepareFigure(obj, ax)
            fig = ancestor(ax, "figure");

            set(fig, ...
                "Units", "pixels", ...
                "WindowButtonMotionFcn", @obj.updateInset, ...
                "WindowScrollWheelFcn", @obj.updateMagnification, ...
                "KeyPressFcn", @obj.updateInsetSize ...
                );

            pointerBehaviour = struct( ...
                "enterFcn", @obj.prepareInset, ...
                "exitFcn", @obj.removeInset, ...
                "traverseFcn", @obj.updateInset ...
                );
            iptPointerManager(fig);
            iptSetPointerBehavior(ax, pointerBehaviour);
        end

        function prepareInset(obj, ~, ~)
            obj.prepareInsetAxis();
            obj.updateInset();
        end
        function updateInset(obj, ~, ~)
            if obj.insetIsVisible()
                obj.updateInsetPosition();
                obj.updateInsetCursor();
                obj.updateInsetXLim();
                obj.updateInsetYLim();
            end
        end
        function removeInset(obj, ~, ~)
            obj.deleteInsetAxis();
        end

        function prepareInsetAxis(obj)
            ax = obj.getPrimaryAxis();
            iAx = generateInsetAxis(ax);

            obj.insetAx = iAx;
            obj.prepareInsetCursor();
            obj.insetPresent = true;
        end
        function prepareInsetCursor(obj)
            cursorLocation = obj.getPrimaryCursorPoint();
            cursorPoint = obj.addPointToInset(cursorLocation);
            obj.insetCursor = cursorPoint;
        end
        function point = addPointToInset(obj, xy)
            iAx = obj.getInsetAxis();
            x = xy(1);
            y = xy(2);

            hold(iAx, "on");
            point = scatter( ...
                iAx, x, y, 30, ...
                "MarkerEdgeColor", "white", ...
                "MarkerFaceColor", "black" ...
                );
            hold(iAx, "off");
        end
        function deleteInsetAxis(obj)
            delete(obj.insetAx);
            obj.insetPresent = false;
        end

        function updateMagnification(obj, ~, event)
            scrollDirection = event.VerticalScrollCount;
            scrollAmount = event.VerticalScrollAmount;

            if scrollDirection == -1
                obj.increaseMagnification(scrollAmount);
            elseif scrollDirection == 1
                obj.decreaseMagnification(scrollAmount);
            end

            obj.updateInset();
        end
        function increaseMagnification(obj, scrollAmount)
            mag = obj.getInsetMagnification();
            factor = obj.magnificationFactor^scrollAmount;
            mag = mag * factor;
            obj.setInsetMagnification(mag);
        end
        function decreaseMagnification(obj, scrollAmount)
            mag = obj.getInsetMagnification();
            factor = obj.magnificationFactor^scrollAmount;
            mag = mag / factor;
            obj.setInsetMagnification(mag);
        end

        function updateInsetSize(obj, ~, event)
            pressedChar = event.Character;

            if obj.isIncreaseSize(pressedChar)
                obj.increaseScale();
            elseif obj.isDecreaseSize(pressedChar)
                obj.decreaseScale();
            end
            
            obj.updateInset();
        end
        function increaseScale(obj)
            scale = obj.getInsetScale();
            factor = obj.scaleFactor;
            scale = scale * factor;
            obj.setInsetScale(scale);
        end
        function decreaseScale(obj)
            scale = obj.getInsetScale();
            factor = obj.scaleFactor;
            scale = scale / factor;
            obj.setInsetScale(scale);
        end
        function isValid = isIncreaseSize(obj, char)
            validChars = obj.increaseScaleChars;
            charCount = numel(validChars);

            isValid = false;
            for index = 1:charCount
                validChar = validChars(index);
                if strcmp(char, validChar)
                    isValid = true;
                    return;
                end
            end
        end
        function isValid = isDecreaseSize(obj, char)
            validChars = obj.decreaseScaleChars;
            charCount = numel(validChars);

            isValid = false;
            for index = 1:charCount
                validChar = validChars(index);
                if strcmp(char, validChar)
                    isValid = true;
                    return;
                end
            end
        end


    end

    methods (Access = private)
        function updateInsetCursor(obj)
            cursorLocation = obj.getPrimaryCursorPoint();
            obj.setInsetCursorLocation(cursorLocation);
        end
        function setInsetCursorLocation(obj, location)
            x = location(1);
            y = location(2);
            set(obj.insetCursor, "XData", x, "YData", y);
        end

        function updateInsetXLim(obj)
            xlim = obj.calculateInsetXLim();
            obj.setInsetXLim(xlim);
        end
        function xlim = calculateInsetXLim(obj)
            ax = obj.getPrimaryAxis();
            insetXdev = obj.calculateInsetDeviationRangeX();
            primaryCursorX = getAxisCursorX(ax);
            xlim = primaryCursorX + insetXdev;
        end
        function setInsetXLim(obj, xlim)
            iAx = obj.getInsetAxis();
            set(iAx, "XLim", xlim);
        end

        function updateInsetYLim(obj)
            ylim = obj.calculateInsetYLim();
            obj.setInsetYLim(ylim);
        end
        function ylim = calculateInsetYLim(obj)
            ax = obj.getPrimaryAxis();
            insetYdev = obj.calculateInsetDeviationRangeY();
            primaryCursorY = getAxisCursorY(ax);
            ylim = primaryCursorY + insetYdev;
        end
        function setInsetYLim(obj, ylim)
            iAx = obj.getInsetAxis();
            set(iAx, "YLim", ylim);
        end

        function updateInsetPosition(obj)
            newInsetPosition = obj.calculateInsetPosition();
            obj.setInsetPosition(newInsetPosition);
        end
        function pos = calculateInsetPosition(obj)
            insetBottomLeftPosition = obj.getInsetBottomLeftPosition();
            insetSize = obj.getInsetSize();
            pos = insetBottomLeftPosition + insetSize;
        end
        function pos = getInsetBottomLeftPosition(obj)
            fig = obj.getFigure();
            figCursorPosition = getFigureCursorPosition(fig);
            pos = [figCursorPosition, 0, 0];
        end
        function size = getInsetSize(obj)
            ax = obj.getPrimaryAxis();
            scale = obj.getInsetScale();

            primarySize = getAxisSize(ax);
            primarySize = min(primarySize);
            primarySize = [primarySize, primarySize];
            size = scale * [-primarySize, primarySize];
        end
        function setInsetPosition(obj, position)
            iAx = obj.getInsetAxis();
            set(iAx, 'Position', position);
        end
    end

    methods (Access = private)
        function setInsetMagnification(obj, mag)
            obj.magnification = mag;
        end
        function setInsetScale(obj, scale)
            obj.scale = scale;
        end

        function is = insetIsVisible(obj)
            is = obj.insetPresent;
        end
        function mag = getInsetMagnification(obj)
            mag = obj.magnification;
        end
        function scale = getInsetScale(obj)
            scale = obj.scale;
        end
        function fig = getFigure(obj)
            fig = obj.figure;
        end
        function ax = getPrimaryAxis(obj)
            ax = obj.primaryAx;
        end
        function ax = getInsetAxis(obj)
            ax = obj.insetAx;
        end

        function point = getPrimaryCursorPoint(obj)
            ax = obj.getPrimaryAxis();
            point = getAxisCursorPoint(ax);
        end

        function ratio = calculateAxisWidthRatio(obj)
            ax = obj.getPrimaryAxis();
            iAx = obj.getInsetAxis();

            primaryWidth = getAxisWidth(ax);
            insetWidth = getAxisWidth(iAx);
            ratio = insetWidth / primaryWidth;
        end
        function ratio = calculateAxisHeightRatio(obj)
            ax = obj.getPrimaryAxis();
            iAx = obj.getInsetAxis();

            primaryHeight = getAxisHeight(ax);
            insetHeight = getAxisHeight(iAx);
            ratio = insetHeight / primaryHeight;
        end
        function ratio = calculateAxisMinimumRatio(obj)
            widthRatio = obj.calculateAxisWidthRatio();
            heightRatio = obj.calculateAxisHeightRatio();
            ratio = min(widthRatio, heightRatio);
        end
        function xdev = calculateInsetDeviationRangeX(obj)
            ax = obj.getPrimaryAxis();
            mag = obj.getInsetMagnification();

            xrange = getAxisRangeX(ax);
            ratio = obj.calculateAxisMinimumRatio();
            xdev = [-1, 1] * ratio * xrange * 0.5 / mag;
        end
        function ydev = calculateInsetDeviationRangeY(obj)
            ax = obj.getPrimaryAxis();
            mag = obj.getInsetMagnification();

            yrange = getAxisRangeY(ax);
            ratio = obj.calculateAxisMinimumRatio();
            ydev = [-1, 1] * ratio * yrange * 0.5 / mag;
        end
    end
end



function figCursorPosition = getFigureCursorPosition(fig)
cursorPosition = get(0, "PointerLocation");	% pixels [0, 0] lower left
figPosition = get(fig, 'Position');	% pixels [left, bottom, width, height]
figCursorPosition = cursorPosition - figPosition(1:2);
end
function cursorPoint = getAxisCursorPoint(ax)
cursorPoint = get(ax, "CurrentPoint");
cursorPoint = cursorPoint(1, 1:2);
end

function size = getAxisSize(ax)
pos = get(ax, 'Position');
size = pos(3:4);
end
function width = getAxisWidth(ax)
pos = get(ax, 'Position');
width = pos(3);
end
function height = getAxisHeight(ax)
pos = get(ax, 'Position');
height = pos(4);
end
function pos = getAxisCursorX(ax)
point = get(ax, "CurrentPoint");
pos = point(1, 1);
end
function pos = getAxisCursorY(ax)
point = get(ax, "CurrentPoint");
pos = point(1, 2);
end
function xrange = getAxisRangeX(ax)
xlim = get(ax, "XLim");
xrange = diff(xlim);
end
function yrange = getAxisRangeY(ax)
ylim = get(ax, "XLim");
yrange = diff(ylim);
end

function iAx = generateInsetAxis(ax)
iAx = copyobj(ax, ax.Parent);
set(iAx, "Box", "on");
pbaspect(iAx, [1, 1, 1]);
removeAxisLabels(iAx);
end
function removeAxisLabels(ax)
xlabel(ax, "");
ylabel(ax, "");
zlabel(ax, "");
title(ax, "");
end
