classdef ImageGui < ProcessorGui
    properties (Constant, Access = private)
        rows = 4;
        columns = 6;
        size = [ImageGui.rows, ImageGui.columns];
    end

    methods
        function obj = ImageGui(gl)
            obj@ProcessorGui(gl);
            layoutElements(obj);
        end
    end

    %% Functions to generate GUI elements
    methods (Static)
        function gl = generateGridLayout(parent)
            gl = uigridlayout(parent, ImageGui.size);
        end
    end
end



function layoutElements(imageGui)
columnCount = ImageGui.columns;
rowCount = ImageGui.rows;

% Retrieve components
gl = imageGui.getGridLayout();
thresholdSlider = imageGui.getThresholdSlider();
invertCheckbox = imageGui.getInvertCheckbox();
trackingSelection = imageGui.getTrackingSelectionElement();
angleSelection = imageGui.getAngleSelectionElement();
directionElement = imageGui.getPositiveDirectionElement();
ax = imageGui.getAxis();

% generate labels for appropriate elements
trackingLabel = uilabel(gl, "Text", "Tracking:");
angleLabel = uilabel(gl, "Text", "Rotation:");

% lay out preprocessing elements
thresholdSlider.Layout.Row = 1;
invertCheckbox.Layout.Row = 1;
thresholdSlider.Layout.Column = [1, columnCount-1];
invertCheckbox.Layout.Column = columnCount;

% lay out processing elements
trackingLabel.Layout.Row = 2;
trackingSelection.Layout.Row = 2;
angleLabel.Layout.Row = 3;
angleSelection.Layout.Row = 3;
directionElement.Layout.Row = [2, 3];

trackingLabel.Layout.Column = 1;
trackingSelection.Layout.Column = 2;
angleLabel.Layout.Column = 1;
angleSelection.Layout.Column = 2;
directionElement.Layout.Column = [3, 4];

% Set up axis on which bundles are displayed
ax.Layout.Row = rowCount;
ax.Layout.Column = [1, columnCount];

% Set up row heights and column widths for grid layout
rowSpacing = 1;
rowHeight = (DirectionGui.height - rowSpacing) / 2;

gl.RowHeight = num2cell(rowHeight * ones(1, rowCount));
gl.RowHeight{end} = '1x';

set(gl, ...
    "Padding", [0, 0, 0, 0], ...
    "RowSpacing", rowSpacing, ...
    "ColumnWidth", {64, 192, 96, 96, '3x', 96} ...
    );
end
