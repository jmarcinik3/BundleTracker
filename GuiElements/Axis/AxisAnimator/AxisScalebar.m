classdef AxisScalebar < handle
    properties (Access = private)
        buttonDownPoint = [];
        dragStartValue = [];
        horizontalLine;
        verticalLine;
        axis;
        horizontalText;
        verticalText;
    end

    properties (SetObservable = true)
        ScalebarPosition = [0, 0];
        Color = [0, 0, 0];
        Border = 'LL'; % 'LL', 'LR', 'UL', 'UR'
        HorizontalLength = 0;
        VerticalLength = 0;
        HorizontalMultiplier = 1;
        VerticalMultiplier = 1;
        HorizontalTextPosition = [0, 0];
        VerticalTextPosition = [0, 0];
        HorizontalTextRotation = 0;
        VerticalTextRotation = 90;
        HorizontalUnit = '';
        VerticalUnit = '';
    end

    methods
        function obj = AxisScalebar(ax, varargin)
            addlistener(obj, "ScalebarPosition", "PostSet", @obj.setScalebarPosition);
            addlistener(obj, "Color", "PostSet", @obj.setColor);
            addlistener(obj, "Border", "PostSet", @obj.setBorder);
            addlistener(obj, "HorizontalLength", "PostSet", @obj.setHorizontalLength);
            addlistener(obj, "VerticalLength", "PostSet", @obj.setVerticalLength);
            addlistener(obj, "HorizontalMultiplier", "PostSet", @obj.setHorizontalMultiplier);
            addlistener(obj, "VerticalMultiplier", "PostSet", @obj.setVerticalMultiplier);
            addlistener(obj, "HorizontalTextPosition", "PostSet", @obj.setHorizontalTextPosition);
            addlistener(obj, "VerticalTextPosition", "PostSet", @obj.setVerticalTextPosition);
            addlistener(obj, "HorizontalTextRotation", "PostSet", @obj.setHorizontalTextRotation);
            addlistener(obj, "VerticalTextRotation", "PostSet", @obj.setVerticalTextRotation);
            addlistener(obj, "HorizontalUnit", "PostSet", @obj.setHorizontalUnit);
            addlistener(obj, "VerticalUnit", "PostSet", @obj.setVerticalUnit);

            axisXLim = get(ax, "XLim");
            axisYLim = get(ax, "YLim");
            axisXWidth = diff(axisXLim);
            axisYWidth = diff(axisYLim);

            hold(ax, "on");
            templine = plot( ...
                ax, ...
                [0, 0], ...
                [0, 0], ...
                "Color", obj.Color, ...
                "LineWidth", 1.5 ...
                );

            obj.horizontalLine = [copy(templine), templine];
            obj.verticalLine = [copy(templine), copy(templine)];
            set([obj.verticalLine, obj.horizontalLine], ...
                "Parent", ax, ...
                "ButtonDownFcn", @obj.buttonDownLine ...
                );
            obj.horizontalText = text( ...
                ax, ...
                0, ...
                0, ...
                '', ...
                "Color", obj.Color, ...
                "ButtonDownFcn", @obj.buttonDownText ...
                );
            obj.verticalText = text( ...
                ax, ...
                0, ...
                0, ...
                '', ...
                "Color", obj.Color, ...
                "Rotation", 90, ...
                "ButtonDownFcn", @obj.buttonDownText ...
                );

            scalebarMenu = uicontextmenu;
            uimenu(scalebarMenu, ...
                "Label", "Rotate Scalebar", ...
                "Callback", @(src,ev) obj.uiRotateScalebar() ...
                );
            uimenu(scalebarMenu, ...
                "Label", "Toggle Axis Visibility", ...
                "Callback", @(src,ev) obj.uiToggleAxisVisibility() ...
                );
            uimenu(scalebarMenu, ...
                "Label", "Delete Scalebar", ...
                "Separator", "on", ...
                "Callback", @(src,ev) obj.delete() ...
                );
            set( ...
                [obj.horizontalLine, obj.verticalLine], ...
                "uicontextmenu", scalebarMenu ...
                );

            horizontalLabelMenu = uicontextmenu;
            uimenu(horizontalLabelMenu, ...
                "Label", "Set Length [x]", ...
                "Callback", @obj.uiSetHorizontalLength ...
                );
            uimenu(horizontalLabelMenu, ...
                "Label", "Set Unit [x]", ...
                "Callback", @obj.uiSetHorizontalUnit ...
                );
            uimenu(horizontalLabelMenu, ...
                "Label", "Set Multiplier [x]", ...
                "Callback", @obj.uiSetHorizontalMultiplier ...
                );
            uimenu(horizontalLabelMenu, ...
                "Label", "Rotate Text [x]",...
                "Callback", @obj.uiRotateHorizontal ...
                );
            set(obj.horizontalText, "uicontextmenu", horizontalLabelMenu);

            verticalLabelMenu = uicontextmenu;
            uimenu(verticalLabelMenu, ...
                "Label", "Set Length [y]", ...
                "Callback", @obj.uiSetVerticalLength ...
                );
            uimenu(verticalLabelMenu, ...
                "Label", "Set Unit [y]", ...
                "Callback", @obj.uiSetVerticalUnit ...
                );
            uimenu(verticalLabelMenu, ...
                "Label", "Set Multiplier [y]", ...
                "Callback", @obj.uiSetVerticalMultiplier ...
                );
            uimenu(verticalLabelMenu, ...
                "Label", "Rotate Text [y]",...
                "Callback", @obj.uiRotateVertical ...
                );
            set(obj.verticalText, "uicontextmenu", verticalLabelMenu);

            p = inputParser;
            p.addParameter("ScalebarPosition", [axisXLim(1) + 0.1*axisXWidth, axisYLim(1) + 0.1*axisYWidth]);
            p.addParameter("Color", obj.Color);
            p.addParameter("Border", obj.Border);
            p.addParameter("HorizontalLength", roundToNice(0.1*axisXWidth));
            p.addParameter("VerticalLength", roundToNice(0.1*axisYWidth));
            p.addParameter("HorizontalMultiplier", 1);
            p.addParameter("VerticalMultiplier", 1);
            p.addParameter("HorizontalTextPosition", 0.02*axisXWidth*[1, -1]);
            p.addParameter("VerticalTextPosition", 0.02*axisXWidth*[-1, 1]);
            p.addParameter("HorizontalTextRotation", obj.HorizontalTextRotation);
            p.addParameter("VerticalTextRotation", obj.VerticalTextRotation);
            p.addParameter("HorizontalUnit", obj.HorizontalUnit);
            p.addParameter("VerticalUnit", obj.VerticalUnit);
            p.parse(varargin{:});

            propertyNames = string(p.Parameters);
            for propertyName = propertyNames
                obj.(propertyName) = p.Results.(propertyName);
            end

            obj.axis = ax;
        end

        function delete(obj)
            delete(obj.horizontalLine);
            delete(obj.verticalLine);
            delete(obj.horizontalText);
            delete(obj.verticalText);
        end
    end

    %% Functions to set state through GUI
    methods (Access = private)
        function uiSetHorizontalLength(obj, ~, ~)
            default = {num2str(obj.HorizontalLength)};
            answer = inputdlg( ...
                "Enter length (float)", ...
                "Horizontal Scalebar", ...
                1, ...
                default ...
                );
            if isempty(answer)
                return;
            end
            length = str2double(answer{1});
            obj.HorizontalLength = length;
        end
        function uiSetVerticalLength(obj, ~, ~)
            default = {num2str(obj.VerticalLength)};
            answer = inputdlg( ...
                "Enter length (float)", ...
                "Vertical Scalebar", ...
                1, ...
                default ...
                );
            if isempty(answer)
                return;
            end
            length = str2double(answer{1});
            obj.VerticalLength = length;
        end
        function uiSetHorizontalMultiplier(obj, ~, ~)
            default = {num2str(obj.HorizontalMultiplier)};
            answer = inputdlg( ...
                "Enter multiplier (float)", ...
                "Horizontal Scalebar", ...
                1, ...
                default ...
                );
            if isempty(answer)
                return;
            end
            multiplier = str2double(answer{1});
            obj.HorizontalMultiplier = multiplier;
        end
        function uiSetVerticalMultiplier(obj, ~, ~)
            default = {num2str(obj.VerticalMultiplier)};
            answer = inputdlg( ...
                "Enter multiplier (float)", ...
                "Vertical Scalebar", ...
                1, ...
                default ...
                );
            if isempty(answer)
                return;
            end
            multiplier = str2double(answer{1});
            obj.VerticalMultiplier = multiplier;
        end
        function uiSetHorizontalUnit(obj, ~, ~)
            answer = inputdlg( ...
                "Enter unit (string)", ...
                "Horizontal Scalebar", ...
                1, ...
                {obj.HorizontalUnit} ...
                );
            if isempty(answer)
                return;
            end
            unit = answer{1};
            obj.HorizontalUnit = unit;
        end
        function uiSetVerticalUnit(obj, ~, ~)
            answer = inputdlg( ...
                "Enter unit (string)", ...
                "Vertical Scalebar", ...
                1, ...
                {obj.VerticalUnit} ...
                );
            if isempty(answer)
                return;
            end
            unit = answer{1};
            obj.VerticalUnit = unit;
        end

        function uiRotateScalebar(obj, ~, ~)
            border = obj.Border;
            switch border
                case 'LL'; newBorder = 'UL';
                case 'LR'; newBorder = 'LL';
                case 'UR'; newBorder = 'LR';
                case 'UL'; newBorder = 'UR';
            end
            obj.Border = newBorder;
        end
        function uiRotateHorizontal(obj, ~, ~)
            obj.HorizontalTextRotation = obj.HorizontalTextRotation - 90;
        end
        function uiRotateVertical(obj, ~, ~)
            obj.VerticalTextRotation = obj.VerticalTextRotation - 90;
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

    %% Functions to set state dynamically
    methods
        function setScalebarPosition(obj, ~, ~)
            position = obj.ScalebarPosition;
            xPosition = position(1);
            yPosition = position(2);

            set(obj.verticalLine(1), "XData", xPosition * [1, 1]);
            set(obj.verticalLine(2), "XData", (xPosition + obj.HorizontalLength)*[1, 1]);
            set(obj.horizontalLine(1), "YData", yPosition * [1, 1]);
            set(obj.horizontalLine(2), "YData", (yPosition + obj.VerticalLength) * [1, 1]);
            set(obj.verticalLine, "YData", yPosition + [0, obj.VerticalLength]);
            set(obj.horizontalLine, "XData", xPosition + [0, obj.HorizontalLength]);
            set(obj.horizontalText, "Position", [obj.HorizontalTextPosition + position, 0]);
            set(obj.verticalText, "Position", [obj.VerticalTextPosition + position, 0]);
            set(obj.verticalLine, "Color", obj.Color);
            set(obj.horizontalLine, "Color", obj.Color);
        end
        function setColor(obj, ~, ~)
            color = obj.Color;
            isColor = numel(validatecolor(color)) == 3;
            if isColor
                colorObjs = [
                    obj.horizontalLine, ...
                    obj.verticalLine, ...
                    obj.horizontalText, ...
                    obj.verticalText ...
                    ];
                for colorObj = colorObjs
                    colorObj.Color = color;
                end
            end
        end

        function setBorder(obj, ~, ~)
            value = obj.Border;
            horizontalLocation = value(1);
            verticalLocation = value(2);
            obj.setHorizontalBorder(horizontalLocation);
            obj.setVerticalBorder(verticalLocation);

        end
        function setHorizontalBorder(obj, location)
            switch upper(location)
                case 'L'
                    set(obj.horizontalLine(1), "Visible", "on");
                    set(obj.horizontalLine(2), "Visible", "off");
                case 'U'
                    set(obj.horizontalLine(1), "Visible", "off");
                    set(obj.horizontalLine(2), "Visible", "on");
            end
        end
        function setVerticalBorder(obj, location)
            switch upper(location)
                case 'L'
                    set(obj.verticalLine(1), "Visible", "on");
                    set(obj.verticalLine(2), "Visible", "off");
                case 'R'
                    set(obj.verticalLine(1), "Visible", "off");
                    set(obj.verticalLine(2), "Visible", "on");
            end
        end

        function setHorizontalTextPosition(obj, ~, ~)
            newPosition = [obj.ScalebarPosition + obj.HorizontalTextPosition, 0];
            set(obj.horizontalText, "Position", newPosition);
        end
        function setVerticalTextPosition(obj, ~, ~)
            newPosition = [obj.ScalebarPosition + obj.VerticalTextPosition, 0];
            set(obj.verticalText, "Position", newPosition);
        end
        function setHorizontalTextRotation(obj, ~, ~)
            set(obj.horizontalText, "Rotation", obj.HorizontalTextRotation);
        end
        function setVerticalTextRotation(obj, ~, ~)
            set(obj.verticalText, "Rotation", obj.VerticalTextRotation);
        end
        function setHorizontalLength(obj, ~, ~)
            horizontalLength = obj.HorizontalLength;
            xPosition = obj.ScalebarPosition(1);
            horizontalLineX = xPosition + [0, horizontalLength];
            verticalLineX = xPosition + horizontalLength * [1, 1];

            set(obj.horizontalLine, "XData", horizontalLineX);
            set(obj.verticalLine(2), "XData", verticalLineX);
            obj.refreshHorizontalText();
        end
        function setVerticalLength(obj, ~, ~)
            verticalLength = obj.VerticalLength;
            yPosition = obj.ScalebarPosition(2);
            verticalLineY = yPosition + [0, verticalLength];
            horizontalLineY = yPosition + verticalLength * [1, 1];

            set(obj.verticalLine, "YData", verticalLineY);
            set(obj.horizontalLine(2), "YData", horizontalLineY);
            obj.refreshVerticalText();
        end
        
        function setHorizontalMultiplier(obj, ~, ~)
            obj.refreshHorizontalText();
        end
        function setVerticalMultiplier(obj, ~, ~)
            obj.refreshVerticalText();
        end
        function setHorizontalUnit(obj, ~, ~)
            obj.refreshHorizontalText();
        end
        function setVerticalUnit(obj, ~, ~)
            obj.refreshVerticalText();
        end

        function refreshHorizontalText(obj, ~, ~)
            horizontalText = obj.horizontalText;
            if ishandle(horizontalText)
                length = obj.HorizontalLength * obj.HorizontalMultiplier;
                unitString = [num2str(length), ' ', obj.HorizontalUnit];
                set(horizontalText, "String", unitString);
            end
        end
        function refreshVerticalText(obj, ~, ~)
            verticalText = obj.verticalText;
            if ishandle(verticalText)
                length = obj.VerticalLength * obj.VerticalMultiplier;
                unitString = [num2str(length), ' ', obj.VerticalUnit];
                set(verticalText, "String", unitString);
            end
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function text = getHorizontalText(obj)
            text = obj.horizontalText;
        end
        function text = getVerticalText(obj)
            text = obj.verticalText;
        end
        function line = getHorizontalLine(obj)
            line = obj.horizontalLine;
        end
        function line = getVerticalLine(obj)
            line = obj.verticalLine;
        end
    end
    methods (Access = private)
        function fig = getFigure(obj)
            ax = obj.getAxis();
            fig = ancestor(ax, "figure");
        end
        function ax = getAxis(obj)
            ax = obj.axis;
        end

        function is = isHorizontalLine(~, source)
            is = isgraphics(source, "Line") ...
                && diff(source.YData) == 0;
        end
        function is = isVerticalLine(~, source)
            is = isgraphics(source, "Line") ...
                && diff(source.XData) == 0;
        end
        function is = isLine(obj, source)
            is = obj.isHorizontalLine(source) ...
                || obj.isVerticalLine(source);
        end
        function is = isHorizontalText(obj, source)
            is = isgraphics(source, "Text") ...
                && isequal(source, obj.horizontalText);
        end
        function is = isVerticalText(obj, source)
            is = isgraphics(source, "Text") ...
                && isequal(source, obj.verticalText);
        end
        function is = isText(obj, source)
            is = obj.isHorizontalText(source) ...
                || obj.isVerticalText(source);
        end
    end

    %% Functions to handle interactive click events
    methods (Access = private)
        function buttonDownText(obj, source, event)
            fig = obj.getFigure();
            ax = obj.getAxis();

            saveWindowFcn.Motion = get(fig, "WindowButtonMotionFcn");
            saveWindowFcn.Up = get(fig, "WindowButtonUpFcn");
            obj.buttonDownPoint = getAxisPoint(ax);

            if obj.isHorizontalText(source)
                obj.dragStartValue = obj.HorizontalTextPosition;
            elseif obj.isVerticalText(source)
                obj.dragStartValue = obj.VerticalTextPosition;
            end

            set(fig, ...
                "WindowButtonMotionFcn", @(src,ev) obj.moveText(source, event), ...
                "WindowButtonUpFcn", @(src,ev) obj.buttonUp(src, ev, saveWindowFcn) ...
                );
        end
        function buttonDownLine(obj, source, event)
            fig = obj.getFigure();
            ax = obj.getAxis();

            previousWindowFcn.Motion = get(fig, "WindowButtonMotionFcn");
            previousWindowFcn.Up = get(fig, "WindowButtonUpFcn");
            obj.buttonDownPoint = getAxisPoint(ax);

            if obj.isCloserToCorner(source, event)
                obj.dragStartValue = obj.ScalebarPosition;
                motionFcn = @obj.moveScalebar;
            elseif obj.isHorizontalLine(source)
                obj.dragStartValue = obj.HorizontalLength;
                motionFcn = @obj.stretchScalebar;
            elseif obj.isVerticalLine(source)
                obj.dragStartValue = obj.VerticalLength;
                motionFcn = @obj.stretchScalebar;
            end

            set(fig, ...
                "WindowButtonMotionFcn", @(src,ev) motionFcn(source, event), ...
                "WindowButtonUpFcn", @(src,ev) obj.buttonUp(source, event, previousWindowFcn) ...
                );
        end

        function moveText(obj, source, ~)
            ax = obj.getAxis();
            currentPoint = getAxisPoint(ax);
            previousPoint = obj.buttonDownPoint;
            newPoint = obj.dragStartValue + (currentPoint - previousPoint);

            if obj.isHorizontalText(source)
                obj.HorizontalTextPosition = newPoint;
            elseif obj.isVerticalText(source)
                obj.VerticalTextPosition = newPoint;
            end
        end
        function moveScalebar(obj, ~, ~)
            ax = obj.getAxis();
            currentPoint = getAxisPoint(ax);
            previousPoint = obj.buttonDownPoint;
            obj.ScalebarPosition = obj.dragStartValue + (currentPoint - previousPoint);
        end
        function stretchScalebar(obj, source, ~)
            ax = obj.getAxis();
            currentPoint = getAxisPoint(ax);
            previousPoint = obj.buttonDownPoint;
            dxyPoint = currentPoint - previousPoint;

            if obj.isHorizontalLine(source)
                newLength = obj.dragStartValue + dxyPoint(1);
                obj.HorizontalLength = roundToNice(newLength);
            elseif obj.isVerticalLine(source)
                newLength = obj.dragStartValue + dxyPoint(2);
                obj.VerticalLength = roundToNice(newLength);
            end
        end

        function buttonUp(obj, ~, ~, previousWindowFcn)
            fig = obj.getFigure();
            set(fig, "pointer", "arrow");
            set(fig, "WindowButtonMotionFcn", previousWindowFcn.Motion);
            set(fig, "WindowButtonUpFcn", previousWindowFcn.Up);
        end
    end

    %% Functions to calculate realtime state information
    methods
        function isCloser = isCloserToCorner(obj, ~, event)
            ax = obj.getAxis();

            cornerPosition = obj.getCornerPosition();
            otherPosition = obj.getAntiCornerPosition();
            eventPosition = event.IntersectionPoint(1, 1:2);

            cornerPosition = limitsToPixels(ax, cornerPosition);
            otherPosition = limitsToPixels(ax, otherPosition);
            eventPosition = limitsToPixels(ax, eventPosition);

            cornerDistance = sqrt(sum((eventPosition - cornerPosition).^2));
            otherDistance = sqrt(sum((eventPosition - otherPosition).^2));
            isCloser = cornerDistance <= otherDistance;
        end

        function point = getCornerPosition(obj, border)
            if nargin < 2
                border = obj.Border;
            end
            x = get(obj.horizontalLine(1), "XData");
            y = get(obj.verticalLine(1), "YData");

            switch border
                case 'LL'; point = [x(1), y(1)];
                case 'LR'; point = [x(2), y(1)];
                case 'UR'; point = [x(2), y(2)];
                case 'UL'; point = [x(1), y(2)];
            end
        end
        function point = getAntiCornerPosition(obj, border)
            if nargin < 2
                border = obj.Border;
            end
            x = get(obj.horizontalLine(1), "XData");
            y = get(obj.verticalLine(1), "YData");

            switch border
                case 'LL'; point = [x(2), y(2)];
                case 'LR'; point = [x(1), y(2)];
                case 'UR'; point = [x(1), y(1)];
                case 'UL'; point = [x(2), y(1)];
            end
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

function point = getAxisPoint(ax)
point = get(ax, "CurrentPoint");
point = point(1, 1:2);
end
function pointPixels = limitsToPixels(ax, point)
axPosition = get(ax, "InnerPosition");
xLim = get(ax, "XLim");
yLim = get(ax, "YLim");
axLim = [xLim; yLim];
axLength = axPosition(3:4);
pointPixels = axLength .* (point - axLim(:, 1)) ./ (axLim(:, 2) - axLim(:, 1));
end
