classdef ImageGui < ProcessorGui
    properties (Constant, Access = private)
        rows = 3;
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
configureGridLayout(imageGui);
configurePositions(imageGui);
end

function configureGridLayout(imageGui)
gl = imageGui.getGridLayout();

% Set up row heights and column widths for grid layout
set(gl, ...
    "Padding", [0, 0, 0, 0], ...
    "RowHeight", {TrackingGui.rowHeight, DirectionGui.height, '1x'}, ...
    "ColumnWidth", {'1x', '3x', '1x', '3x', '1x', '3x'} ...
    );
end

function configurePositions(imageGui)
columnCount = ImageGui.columns;

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
angleLabel.Layout.Row = 2;
trackingSelection.Layout.Row = 2;
angleSelection.Layout.Row = 2;
directionElement.Layout.Row = 2;

trackingLabel.Layout.Column = 1;
trackingSelection.Layout.Column = 2;
angleLabel.Layout.Column = 3;
angleSelection.Layout.Column = 4;
directionElement.Layout.Column = [5, 6];

% Set up axis on which bundles are displayed
ax.Layout.Row = ImageGui.rows;
ax.Layout.Column = [1, columnCount];
end
