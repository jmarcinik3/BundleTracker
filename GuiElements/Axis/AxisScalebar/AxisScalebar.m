classdef AxisScalebar < handle
    properties (Access = private)
        scalebar;
        horizontalText;
        verticalText;
        scalebarPosition;
    end

    methods
        function obj = AxisScalebar(ax, varargin)
            hold(ax, "on");

            scalebar = LineScalebar(ax);
            scalebarX = scalebar.getPositionX();
            scalebarY = scalebar.getPositionY();
            horizontalText = text(ax, scalebarX, scalebarY, '', "Rotation", 0);
            verticalText = text(ax, scalebarX, scalebarY, '', "Rotation", 90);

            horizontalTextObj = AxisScalebarText(ax, horizontalText, 'x');
            verticalTextObj = AxisScalebarText(ax, verticalText, 'y');

            addlistener(scalebar, "Position", "PreSet", @obj.scalebarPreSet);
            addlistener(scalebar, "Position", "PostSet", @obj.scalebarPostSet);
            addlistener(scalebar, "Position", "PostSet", @obj.scalebarPostSet);
            addlistener(horizontalTextObj, "Length", "PostSet", @obj.textLengthChanged);
            addlistener(verticalTextObj, "Length", "PostSet", @obj.textLengthChanged);
            
            obj.horizontalText = horizontalTextObj;
            obj.verticalText = verticalTextObj;
            obj.scalebar = scalebar;
        end
    end

    %% Functions to set state dynamically
    methods
        function setColor(obj, color)
            isColor = numel(validatecolor(color)) == 3;
            if isColor
                set(obj.horizontalText.getText(), "Color", color);
                set(obj.verticalText.getText(), "Color", color);
                set(obj.scalebar.getLine(), "Color", color);
            end
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function bar = getScalebar(obj)
            bar = obj.scalebar;
        end
        function text = getHorizontalText(obj)
            text = obj.horizontalText;
        end
        function text = getVerticalText(obj)
            text = obj.verticalText;
        end
    end

    methods (Access = private)
        function scalebarPreSet(obj, ~, event)
            obj.scalebarPosition = event.AffectedObject.getPosition();
        end
        function scalebarPostSet(obj, ~, ~)
            horizontalText = obj.getHorizontalText();
            verticalText = obj.getVerticalText();
            scalebar = obj.getScalebar();
            
            previousPosition = obj.scalebarPosition;
            newPosition = scalebar.getPosition();
            positionDifference = [newPosition(1:2) - previousPosition(1:2), 0];
            horizontalTextPosition = horizontalText.getPosition() + positionDifference;
            horizontalText.setPosition(horizontalTextPosition);
            verticalTextPosition = verticalText.getPosition() + positionDifference;
            verticalText.setPosition(verticalTextPosition);
            
            horizontalText.setLength(scalebar.getWidth());
            verticalText.setLength(scalebar.getHeight());
        end
        function textLengthChanged(obj, ~, event)
            text = event.AffectedObject;
            newLength = text.getLength();
            if text == obj.getHorizontalText()
                obj.scalebar.setWidth(newLength);
            elseif text == obj.getVerticalText()
                obj.scalebar.setHeight(newLength);
            end
        end
    end
end