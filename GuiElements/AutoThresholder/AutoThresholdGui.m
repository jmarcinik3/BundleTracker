classdef AutoThresholdGui
    properties (Constant)
        title = "Threshold Regions by Otsu's Method";
    end

    properties (Constant, Access = ?AutoThresholdLinker)
        maxLevelCount = 20;
    end

    properties (Constant, Access = private)
        rows = 3;
        columns = 2;
        size = [AutoThresholdGui.rows, AutoThresholdGui.columns];
        applyText = "Apply";
        cancelText = "Cancel";
    end

    properties (Access = private)
        gridLayout;
        axisGridLayout;
        levelSlider;
        actionButtons;
    end

    methods
        function obj = AutoThresholdGui(fig, regionCount)
            set(fig, "Name", AutoThresholdGui.title);
            gl = uigridlayout(fig, AutoThresholdGui.size);
            agl = generateAxes(gl, regionCount);
            slider = generateLevelsSlider(gl);

            obj.gridLayout = gl;
            obj.axisGridLayout = agl;
            obj.levelSlider = slider;
            obj.actionButtons = generateActionButtons(gl);
            layoutElements(obj);
        end
    end
    
    %% 
    %% Functions to retrieve GUI elements
    methods
        function fig = getFigure(obj)
            agl = obj.axisGridLayout;
            fig = ancestor(agl, "figure");
        end
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function agl = getAxisGridLayout(obj)
            agl = obj.axisGridLayout;
        end
        function axes = getAxes(obj)
            agl = obj.axisGridLayout;
            axes = findobj(agl, "Type", "axes");
        end
        function slider = getLevelSlider(obj)
            slider = obj.levelSlider;
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




function layoutElements(gui)
% set default row height for GUI elements
rowHeight = TrackingGui.rowHeight;
columns = AutoThresholdGui.columns;

% retrieve GUI elements
gl = gui.getGridLayout();
agl = gui.getAxisGridLayout();
slider = gui.getLevelSlider();
applyButton = gui.getApplyButton();
cancelButton = gui.getCancelButton();

% lay out full-row elements
agl.Layout.Row = 1;
slider.Layout.Row = 2;
agl.Layout.Column = [1, columns];
slider.Layout.Column = [1, columns];

% lay out apply/cancel buttons
applyButton.Layout.Row = 3;
cancelButton.Layout.Row = 3;
applyButton.Layout.Column = 1;
cancelButton.Layout.Column = 2;

% set grid sizes
gl.RowHeight = {'1x', rowHeight, rowHeight};
end


%% Function to generate grid of plotting axes
function agl = generateAxes(gl, axisCount)
rowCount = ceil(sqrt(axisCount));
columnCount = ceil(axisCount / rowCount);

agl = uigridlayout(gl, [rowCount, columnCount]);
axisCreatedCount = 0;
for rowIndex = 1:rowCount
    for columnIndex = 1:columnCount
        ax = generateAxis(agl);
        ax.Layout.Row = rowIndex;
        ax.Layout.Column = columnIndex;
        axisCreatedCount = axisCreatedCount + 1;

        if axisCreatedCount == axisCount
            break;
        end
    end
    if axisCreatedCount == axisCount
        break;
    end
end
end

%% Function to generate plotting axis
% Generates axis on which hair cell image is plotted
%
% Arguments
%
% * uigridlayout |gl|: layout to add axis in
%
% Returns uiaxes
function ax = generateAxis(gl)
ax = uiaxes(gl);
ax.Toolbar.Visible = "off";
ax.set( ...
    "Visible", "off", ...
    "XtickLabel", [], ...
    "YTickLabel", [] ...
    );
end

function buttons = generateActionButtons(gl)
applyButton = uibutton(gl, "Text", AutoThresholdGui.applyText);
cancelButton = uibutton(gl, "Text", AutoThresholdGui.cancelText);
buttons = [applyButton, cancelButton];
end

function slider = generateLevelsSlider(gl)
slider = uislider(gl, "range");
maxLevelCount = AutoThresholdGui.maxLevelCount;

set(slider, ...
    "Limits", [0, maxLevelCount], ...
    "Value", [0, maxLevelCount], ...
    "MajorTicks", 0:5:maxLevelCount, ...
    "MinorTicks", 0:maxLevelCount ...
    );
end


