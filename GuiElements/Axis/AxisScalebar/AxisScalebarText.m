classdef AxisScalebarText < handle
    properties (Access = private)
        axis;
        text;
        unit = '';
        multiplier = 1;
        dragStartValue = [];
    end

    properties (SetObservable = true, Access = private)
        Length = 1;
    end

    methods
        function obj = AxisScalebarText(ax, text, name)
            if nargin < 3
                name = "default";
            end

            AxisDraggable( ...
                text, ...
                "ButtonDownFcn", @obj.buttonDown, ...
                "ButtonMotionFcn", @obj.buttonMotion ...
                );

            menu = uicontextmenu();
            uimenu(menu, ...
                "Label", sprintf("Set Length [%s]", name), ...
                "Callback", @obj.uiSetLength ...
                );
            uimenu(menu, ...
                "Label", sprintf("Set Unit [%s]", name), ...
                "Callback", @obj.uiSetUnit ...
                );
            uimenu(menu, ...
                "Label", sprintf("Set Multiplier [%s]", name), ...
                "Callback", @obj.uiSetMultiplier ...
                );
            uimenu(menu, ...
                "Label", sprintf("Rotate Text [%s]", name),...
                "Callback", @obj.uiRotate ...
                );
            set(text, "ContextMenu", menu);

            obj.text = text;
            obj.axis = ax;
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods
        function text = getText(obj)
            text = obj.text;
        end
        function unit = getUnit(obj)
            unit = obj.unit;
        end
        function multiplier = getMultiplier(obj)
            multiplier = obj.multiplier;
        end
        function length = getLength(obj)
            length = obj.Length;
        end
        function position = getPosition(obj)
            position = get(obj.getText(), "Position");
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
        function rotation = getRotation(obj)
            rotation = get(obj.getText(), "Rotation");
        end
    end

    methods
        function setUnit(obj, unit)
            obj.unit = unit;
            obj.refreshText();
        end
        function setMultiplier(obj, multiplier)
            obj.multiplier = multiplier;
            obj.refreshText();
        end
        function setLength(obj, length)
            obj.Length = length;
            obj.refreshText();
        end
        function setPosition(obj, position)
            set(obj.getText(), "Position", position);
        end
    end
    methods (Access = private)
        function refreshText(obj, ~, ~)
            text = obj.getText();
            if ishandle(text)
                length = obj.getLength() * obj.getMultiplier();
                unitString = [num2str(length), ' ', obj.getUnit()];
                set(text, "String", unitString);
            end
        end

        function uiSetLength(obj, ~, ~)
            default = {num2str(obj.getLength())};
            answer = inputdlg( ...
                "Enter length (float)", ...
                "Scalebar Text", ...
                1, ...
                default ...
                );
            if isempty(answer)
                return;
            end
            length = str2double(answer{1});
            obj.setLength(length);
        end
        function uiSetMultiplier(obj, ~, ~)
            default = {num2str(obj.getMultiplier())};
            answer = inputdlg( ...
                "Enter multiplier (float)", ...
                "Scalebar Text", ...
                1, ...
                default ...
                );
            if isempty(answer)
                return;
            end
            multiplier = str2double(answer{1});
            obj.setMultiplier(multiplier);
        end
        function uiSetUnit(obj, ~, ~)
            default = {obj.getUnit()};
            answer = inputdlg( ...
                "Enter unit (string)", ...
                "Scalebar Text", ...
                1, ...
                default ...
                );
            if isempty(answer)
                return;
            end
            unit = answer{1};
            obj.setUnit(unit);
        end
        function uiRotate(obj, ~, ~)
            text = obj.getText();
            newRotation = get(text, "Rotation") - 90;
            set(text, "Rotation", newRotation);
        end
    end

    %% Functions to handle interactive click events
    methods (Access = private)
        function buttonDown(obj, ~, ~)
            obj.dragStartValue = get(obj.getText(), "Position");
        end
        function buttonMotion(obj, previousPoint, currentPoint)
            newPoint = obj.dragStartValue + (currentPoint - previousPoint);
            obj.setPosition(newPoint);
        end
    end
end