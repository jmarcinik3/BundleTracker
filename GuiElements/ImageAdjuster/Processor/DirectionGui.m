classdef DirectionGui
    properties (Constant)
        rowHeight = 24;
        height = 2 * DirectionGui.rowHeight;

        filepaths = "img/" + [
            ["arrow-down-left.png", "arrow-down-right.png"];
            ["arrow-up-left.png", "arrow-up-right.png"];
            ]
        upperLeft = "Upper Left";
        upperRight = "Upper Right";
        lowerLeft = "Lower Left";
        lowerRight = "Lower Right";
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
        function obj = DirectionGui(parent)
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


    %% Functions to retrieve GUI elements
    methods
        function elem = getGridLayout(obj)
            elem = obj.gridLayout;
        end
        function group = getRadioGroup(obj)
            group = obj.radioGroup;
        end
    end
    methods (Access = private)
        function button = getSelectedButton(obj)
            button = obj.radioGroup.SelectedObject;
        end
        function label = getLabel(obj)
            label = obj.label;
        end
        function buttons = getButtons(obj)
            buttons = [ ...
                obj.upperLeftButton, ...
                obj.upperRightButton, ...
                obj.lowerLeftButton, ...
                obj.lowerRightButton ...
                ];
        end
    end

    %% Functions to retrieve state information
    methods (Static)
        function location = buttonToLocation(button)
            buttonTag = get(button, "Tag");
            location = DirectionGui.tagToLocation(buttonTag);
        end
        function location = tagToLocation(tag)
            location = tag;
        end
    end
    methods
        function text = getLocation(obj)
            button = obj.getSelectedButton();
            buttonTag = get(button, "Tag");
            text = obj.tagToLocation(buttonTag);
        end
    end

    %% Functions to set state information
    methods
        function setLocation(obj, location)
            switch location
                case DirectionGui.upperLeft
                    button = obj.upperLeftButton;
                case DirectionGui.upperRight
                    button = obj.upperRightButton;
                case DirectionGui.lowerLeft
                    button = obj.lowerLeftButton;
                case DirectionGui.lowerRight
                    button = obj.lowerRightButton;
            end
            obj.setSelectedButton(button);
        end
    end
    methods (Access = private)
        function setSelectedButton(obj, button)
            group = obj.getRadioGroup();
            set(group, "SelectedObject", button);
        end
    end
end




function layoutElements(gui)
gl = gui.getGridLayout();
group = gui.getRadioGroup();
label = gui.getLabel();

set(gl, ...
    "RowHeight", DirectionGui.height, ...
    "ColumnWidth", {'fit', '1x'} ...
    );
label.Layout.Column = 1;
group.Layout.Column = 2;
end

function label = generateLabel(gl)
text = "Positive Direction:";
label = uilabel(gl, "Text", text);
end

function button = generateUpperLeftButton(group)
location = {2, 1};
tag = DirectionGui.upperLeft;
icon = DirectionGui.filepaths(location{:});
button = generateArrowButton(group, location{:});
set(button, "Text", "", "Tag", tag, "Icon", icon);
end
function button = generateUpperRightButton(group)
location = {2, 2};
tag = DirectionGui.upperRight;
icon = DirectionGui.filepaths(location{:});
button = generateArrowButton(group, location{:});
set(button, "Text", "", "Tag", tag, "Icon", icon);
end
function button = generateLowerLeftButton(group)
location = {1, 1};
tag = DirectionGui.lowerLeft;
icon = DirectionGui.filepaths(location{:});
button = generateArrowButton(group, location{:});
set(button, "Text", "", "Tag", tag, "Icon", icon);
end
function button = generateLowerRightButton(group)
location = {1, 2};
tag = DirectionGui.lowerRight;
icon = DirectionGui.filepaths(location{:});
button = generateArrowButton(group, location{:});
set(button, "Text", "", "Tag", tag, "Icon", icon);
end

function button = generateArrowButton(rg, row, column)
leftMargin = 1;
bottomMargin = 1;

rowHeight = DirectionGui.rowHeight;
columnWidth = rowHeight;
position = [
    leftMargin + columnWidth*(column-1), ...
    bottomMargin + rowHeight * (row-1), ...
    columnWidth, ...
    rowHeight ...
    ];

button = uitogglebutton(rg, "Position", position);
end
