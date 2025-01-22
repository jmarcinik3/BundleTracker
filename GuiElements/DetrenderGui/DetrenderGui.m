classdef DetrenderGui
    properties (Access = private)
        figure;
        axis;
        slider;
        dropdown;
        actionButtons;
    end

    methods
        function obj = DetrenderGui(fig, windowWidthMax)
            gl = uigridlayout(fig, ...
                [2, 2], ...
                "RowHeight", {'1x', 50}, ...
                "ColumnWidth", {'1x', 150, 50, 50} ...
                );

            axis = generateAxis(gl);
            slider = generateWindowWidthSlider(gl, windowWidthMax);
            dropdown = generateWindowShapeDropdown(gl);
            
            actionButtons = generateActionButtons(gl);
            applyButton = actionButtons(1);
            cancelButton = actionButtons(2);

            axis.Layout.Row = 1;
            axis.Layout.Column = [1, 4];
            slider.Layout.Row = 2;
            slider.Layout.Column = 1;
            dropdown.Layout.Row = 2;
            dropdown.Layout.Column = 2;
            applyButton.Layout.Row = 2;
            applyButton.Layout.Column = 3;
            cancelButton.Layout.Row = 2;
            cancelButton.Layout.Column = 4;

            obj.figure = fig;
            obj.axis = axis;
            obj.slider = slider;
            obj.dropdown = dropdown;
            obj.actionButtons = actionButtons;
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods
        function fig = getFigure(obj)
            fig = obj.figure;
        end
        function ax = getAxis(obj)
            ax = obj.axis;
        end
        function slider = getWindowWidthSlider(obj)
            slider = obj.slider;
        end
        function dropdown = getWindowShapeDropdown(obj)
            dropdown = obj.dropdown;
        end
        function buttons = getActionButtons(obj)
            buttons = obj.actionButtons;
        end
        function button = getApplyButton(obj)
            button = obj.actionButtons(1);
        end
        function button = getCancelButton(obj)
            button = obj.actionButtons(2);
        end
    end
end


function ax = generateAxis(gl)
ax = uiaxes(gl);
ax.XLabel.String = "Time";
ax.YLabel.String = "Position";
end
function slider = generateWindowWidthSlider(gl, windowWidthMax)
defaults = SettingsParser.getWindowWidthSliderDefaults();
slider = uislider(gl, ...
    defaults{:}, ...
    "Value", windowWidthMax, ...
    "Limits", [100, windowWidthMax], ...
    "MinorTicks", 100:100:windowWidthMax, ...
    "MajorTicks", 500:500:windowWidthMax ...
    );
end
function dropdown = generateWindowShapeDropdown(gl)
defaults = SettingsParser.getWindowShapeDropdownDefaults();
dropdown = uidropdown(gl, ...
    defaults{:}, ...
    "Items", MovingAverage.keywords ...
    );
end
