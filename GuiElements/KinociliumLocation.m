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
            group = generateRadioGroup(gl);
            obj.radioGroup = group;

            obj.upperLeftButton = generateUpperLeftButton(group);
            obj.upperRightButton = generateUpperRightButton(group);
            obj.lowerLeftButton = generateLowerLeftButton(group);
            obj.lowerRightButton = generateLowerRightButton(group);
        end
    end

    %% Functions to retreive GUI elements and state information
    methods
        function elem = getElement(obj)
            elem = obj.radioGroup;
        end
        function text = getLocation(obj)
            button = obj.getSelectedButton();
            buttonText = button.Text;
            text = obj.textToLocation(buttonText);
        end
    end
    methods (Access = private)
        function button = getSelectedButton(obj)
            button = obj.radioGroup.SelectedObject;
        end
    end
end

function group = generateRadioGroup(gl)
group = uibuttongroup(gl);
group.Title = KinociliumLocation.title;
group.TitlePosition = "centertop";
group.BorderType = "line";
end

function button = generateUpperLeftButton(group)
text = KinociliumLocation.upperLeftText;
location = [2, 1];
button = generateArrowButton(group, text, location);
end
function button = generateUpperRightButton(group)
text = KinociliumLocation.upperRightText;
location = [2, 2];
button = generateArrowButton(group, text, location);
end
function button = generateLowerLeftButton(group)
text = KinociliumLocation.lowerLeftText;
location = [1, 1];
button = generateArrowButton(group, text, location);
end
function button = generateLowerRightButton(group)
text = KinociliumLocation.lowerRightText;
location = [1, 2];
button = generateArrowButton(group, text, location);
end

function button = generateArrowButton(rg, text, loc)
row = loc(1);
column = loc(2);

leftMargin = 10;
rowHeight = KinociliumLocation.rowHeight;
columnWidth = rowHeight;
position = [
    leftMargin + columnWidth*(column-1), ...
    rowHeight * (row-1), ...
    columnWidth, ...
    rowHeight ...
    ];

button = uitogglebutton(rg, ...
    "Text", text, ...
    "Position", position ...
    );
end
