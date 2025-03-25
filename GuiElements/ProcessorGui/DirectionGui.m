classdef DirectionGui
    properties (Constant)
        rowHeight = 24;
        height = 3 * DirectionGui.rowHeight;

        filepaths = "img/" + [
            ["arrow-up-left.png", "arrow-up.png", "arrow-up-right.png"];
            ["arrow-left.png", '', "arrow-right.png"];
            ["arrow-down-left.png", "arrow-down.png", "arrow-down-right.png"];
            ]
        tags = [
            ["Upper Left", "Upper", "Upper Right"];
            ["Left", '', "Right"];
            ["Lower Left", "Lower", "Lower Right"];
            ];
    end

    properties (Access = private)
        gridLayout;
        label;
        radioGroup;
        buttons = [];
    end

    methods
        function obj = DirectionGui(parent)
            gl = uigridlayout(parent, [1, 2], "Padding", 0);

            obj.label = uilabel(gl, "Text", "Positive Direction:");
            group = uibuttongroup(gl, "BorderType", "none");
            
            obj.buttons = generateButtonGroup(group);
            obj.radioGroup = group;
            obj.gridLayout = gl;
            obj.setLocation(SettingsParser.getDefaultPositiveDirection());
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
            text = string(text);
        end
    end

    %% Functions to set state information
    methods
        function setLocation(obj, location)
            switch location
                case DirectionGui.tags(1, 3) % upper right
                    button = obj.buttons(1, 3);
                case DirectionGui.tags(1, 2) % upper
                    button = obj.buttons(1, 2);
                case DirectionGui.tags(1, 1)
                    button = obj.buttons(1, 1); % upper left
                case DirectionGui.tags(2, 1)
                    button = obj.buttons(2, 1); % left
                case DirectionGui.tags(3, 1)
                    button = obj.buttons(3, 1); % lower left
                case DirectionGui.tags(3, 2)
                    button = obj.buttons(3, 2); % lower
                case DirectionGui.tags(3, 3)
                    button = obj.buttons(3, 3); % lower right
                case DirectionGui.tags(2, 3)
                    button = obj.buttons(2, 3); % right
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

function buttons = generateButtonGroup(group)
buttons = [];
buttons(1, 3) = generateButton(group, {1, 3}); % upper right
buttons(1, 2) = generateButton(group, {1, 2}); % upper
buttons(1, 1) = generateButton(group, {1, 1}); % upper left
buttons(2, 1) = generateButton(group, {2, 1}); % left
buttons(3, 1) = generateButton(group, {3, 1}); % lower left
buttons(3, 2) = generateButton(group, {3, 2}); % lower
buttons(3, 3) = generateButton(group, {3, 3}); % lower right
buttons(2, 3) = generateButton(group, {2, 3}); % right
end

function button = generateButton(group, location)
icon = DirectionGui.filepaths(location{:});
tag = DirectionGui.tags(location{:});
button = generateArrowButton(group, location{:});
set(button, ...
    "Text", "", ...
    "Tag", tag, ...
    "Icon", icon, ...
    "Tooltip", tag ...
    );
end

function button = generateArrowButton(rg, row, column)
leftMargin = 1;
bottomMargin = 1;

rowHeight = DirectionGui.rowHeight;
columnWidth = rowHeight;
columnLocation = (column - 1);
rowLocation = 2 - (row - 1);
position = [
    leftMargin + columnWidth*columnLocation, ...
    bottomMargin + rowHeight*rowLocation, ...
    columnWidth, ...
    rowHeight ...
    ];

button = uitogglebutton(rg, "Position", position);
end
