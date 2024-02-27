classdef KinociliumLocation
    properties (Constant)
        rowHeight = 24;
        height = 2 * KinociliumLocation.rowHeight;

        filepaths = "img/" + [
            ["arrow-down-left.png", "arrow-down-right.png"];
            ["arrow-up-left.png", "arrow-up-right.png"];
            ]
        upperLeft = "Upper Left";
        upperRight = "Upper Right";
        lowerLeft = "Lower Left";
        lowerRight = "Lower Right";
    end

    properties (Access = private, Constant)
        title = "Kinocilium";
    end

    properties (Access = private)
        gridLayout;
        label;
        radioGroup;
        upperLeftButton;
        upperRightButton;
        lowerLeftButton;
        lowerRightButton;
    end

    methods
        function obj = KinociliumLocation(parent)
            gl = uigridlayout(parent, [1, 2]);
            gl.Padding = [0, 0, 0, 0];
            
            obj.label = generateLabel(gl);
            group = uibuttongroup(gl, "BorderType", "none");

            obj.upperLeftButton = generateUpperLeftButton(group);
            obj.upperRightButton = generateUpperRightButton(group);
            obj.lowerLeftButton = generateLowerLeftButton(group);
            obj.lowerRightButton = generateLowerRightButton(group);
            obj.radioGroup = group;
            
            obj.gridLayout = gl;
            layoutElements(obj);
        end
    end

    %% Functions to retreive GUI elements and state information
    methods (Static)
        function location = tagToLocation(tag)
            location = tag;
        end
    end
    methods
        function elem = getGridLayout(obj)
            elem = obj.gridLayout;
        end
        function text = getLocation(obj)
            button = obj.getSelectedButton();
            buttonTag = get(button, "Tag");
            text = obj.tagToLocation(buttonTag);
        end
    end
    methods (Access = private)
        function button = getSelectedButton(obj)
            button = obj.radioGroup.SelectedObject;
        end
        function group = getRadioGroup(obj)
            group = obj.radioGroup;
        end
        function label = getLabel(obj)
            label = obj.label;
        end
    end
end




function layoutElements(gui)
gl = gui.getGridLayout();
group = gui.getRadioGroup();
label = gui.getLabel();

set(gl, ...
    "RowHeight", KinociliumLocation.height, ...
    "ColumnWidth", {'fit', '1x'} ...
    );
label.Layout.Column = 1;
group.Layout.Column = 2;
end



function label = generateLabel(gl)
text = "Kinocilium:";
label = uilabel(gl, "Text", text);
end

function button = generateUpperLeftButton(group)
location = {2, 1};
tag = KinociliumLocation.upperLeft;
icon = KinociliumLocation.filepaths(location{:});
button = generateArrowButton(group, location{:});
set(button, "Text", "", "Tag", tag, "Icon", icon);
end
function button = generateUpperRightButton(group)
location = {2, 2};
tag = KinociliumLocation.upperRight;
icon = KinociliumLocation.filepaths(location{:});
button = generateArrowButton(group, location{:});
set(button, "Text", "", "Tag", tag, "Icon", icon);
end
function button = generateLowerLeftButton(group)
location = {1, 1};
tag = KinociliumLocation.lowerLeft;
icon = KinociliumLocation.filepaths(location{:});
button = generateArrowButton(group, location{:});
set(button, "Text", "", "Tag", tag, "Icon", icon);
end
function button = generateLowerRightButton(group)
location = {1, 2};
tag = KinociliumLocation.lowerRight;
icon = KinociliumLocation.filepaths(location{:});
button = generateArrowButton(group, location{:});
set(button, "Text", "", "Tag", tag, "Icon", icon);
end

function button = generateArrowButton(rg, row, column)
leftMargin = 1;
bottomMargin = 1;

rowHeight = KinociliumLocation.rowHeight;
columnWidth = rowHeight;
position = [
    leftMargin + columnWidth*(column-1), ...
    bottomMargin + rowHeight * (row-1), ...
    columnWidth, ...
    rowHeight ...
    ];

button = uitogglebutton(rg, "Position", position);
end
