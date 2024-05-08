classdef ImageGui < ProcessorGui
    properties (Constant, Access = private)
        rows = 5;
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
detrendSelection = imageGui.getDetrendSelectionElement();
ax = imageGui.getAxis();

% generate labels for appropriate elements
trackingLabel = uilabel(gl, "Text", "Track:");
angleLabel = uilabel(gl, "Text", "Rotate:");
detrendLabel = uilabel(gl, "Text", "Detrend:");

% lay out preprocessing elements
thresholdSlider.Layout.Row = 2;
invertCheckbox.Layout.Row = 2;
thresholdSlider.Layout.Column = [1, columnCount-1];
invertCheckbox.Layout.Column = columnCount;

% lay out processing elements
trackingLabel.Layout.Row = 3;
trackingSelection.Layout.Row = 3;
angleLabel.Layout.Row = 4;
angleSelection.Layout.Row = 4;
detrendLabel.Layout.Row = 5;
detrendSelection.Layout.Row = 5;
directionElement.Layout.Row = [3, 5];

trackingLabel.Layout.Column = 1;
trackingSelection.Layout.Column = 2;
angleLabel.Layout.Column = 1;
angleSelection.Layout.Column = 2;
detrendLabel.Layout.Column = 1;
detrendSelection.Layout.Column = 2;
directionElement.Layout.Column = [3, 4];

% Set up axis on which bundles are displayed
ax.Layout.Row = 1;
ax.Layout.Column = [1, columnCount];

% Set up row heights and column widths for grid layout
rowSpacing = 1;
rowHeight = (DirectionGui.height - rowSpacing) / 3;
gl.RowHeight = num2cell(rowHeight * ones(1, rowCount));
gl.RowHeight{1} = '1x';

set(gl, ...
    "Padding", [0, 0, 0, 0], ...
    "RowSpacing", rowSpacing, ...
    "ColumnWidth", {64, 192, 96, 96, '3x', 96} ...
    );
end
