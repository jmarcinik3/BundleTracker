classdef KinociliumLocation
    properties (Constant)
        rowHeight = 22;
        height = 3 * 22;

        upperLeft = "Upper Left";
        upperRight = "Upper Right";
        lowerLeft = "Lower Left";
        lowerRight = "Lower Right";
    end

    properties (Access = private, Constant)
        upperLeftText = "↖";
        upperRightText = "↗";
        lowerLeftText = "↙";
        lowerRightText = "↘";
        title = "Kinocilium";

        textToLocation = dictionary( ...
            KinociliumLocation.upperLeftText, KinociliumLocation.upperLeft, ...
            KinociliumLocation.upperRightText, KinociliumLocation.upperRight, ...
            KinociliumLocation.lowerLeftText, KinociliumLocation.lowerLeft, ...
            KinociliumLocation.lowerRightText, KinociliumLocation.lowerRight ...
            );
    end

    properties (Access = private)
        radioGroup;
        upperLeftButton;
        upperRightButton;
        lowerLeftButton;
        lowerRightButton;
    end

    methods
        function obj = KinociliumLocation(gl)
            radioGroup = uibuttongroup(gl);
            radioGroup.Title = obj.title;
            radioGroup.TitlePosition = "centertop";
            radioGroup.BorderType = "line";
            obj.radioGroup = radioGroup;

            obj.upperLeftButton = generateArrowButton(radioGroup, obj.upperLeftText, [2 1]);
            obj.upperRightButton = generateArrowButton(radioGroup, obj.upperRightText, [2 2]);
            obj.lowerLeftButton = generateArrowButton(radioGroup, obj.lowerLeftText, [1 1]);
            obj.lowerRightButton = generateArrowButton(radioGroup, obj.lowerRightText, [1 2]);
        end

        function elem = getElement(obj)
            elem = obj.radioGroup;
        end

        function text = getLocation(obj)
            button = obj.getSelectedButton();
            buttonText = button.Text;
            text = obj.textToLocation(buttonText);
        end
        function button = getSelectedButton(obj)
            button = obj.radioGroup.SelectedObject;
        end

        function isSelected = isUpperLeft(obj)
            isSelected = obj.getSelectedButton() == obj.upperLeftButton;
        end
        function isSelected = isLowerLeft(obj)
            isSelected = obj.getSelectedButton() == obj.lowerLeftButton;
        end
        function isSelected = isUpperRight(obj)
            isSelected = obj.getSelectedButton() == obj.upperRightButton;
        end
        function isSelected = isLowerRight(obj)
            isSelected = obj.getSelectedButton() == obj.lowerRightButton;
        end
    end
end

function button = generateArrowButton(rg, text, loc)
row = loc(1);
column = loc(2);

leftMargin = 10;
rowHeight = KinociliumLocation.rowHeight;
columnWidth = rowHeight;
widthLimit = 100;
position = [leftMargin+columnWidth*(column-1), rowHeight*(row-1), columnWidth, rowHeight];

button = uitogglebutton(rg, "Text", text, "Position", position);
end
