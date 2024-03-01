classdef ImageGui < PreprocessorGui
    properties (Constant, Access = private)
        rows = 1;
        columns = 2;
        size = [ImageGui.rows, ImageGui.columns];
    end

    methods
        function obj = ImageGui(gl)
            obj@PreprocessorGui(gl);
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
rowHeight = TrackingGui.rowHeight;

% Set up row heights and column widths for grid layout
set(gl, ...
    "Padding", [0, 0, 0, 0], ...
    "RowHeight", {rowHeight, '1x'}, ...
    "ColumnWidth", {'4x', '1x'} ...
    );
end

function configurePositions(imageGui)
% Retrieve components
thresholdSlider = imageGui.getThresholdSlider();
invertCheckbox = imageGui.getInvertCheckbox();
ax = imageGui.getAxis();

% Set up slider for intensity threshold to left of invert checkbox
thresholdSlider.Layout.Row = 1;
thresholdSlider.Layout.Column = 1;
invertCheckbox.Layout.Row = 1;
invertCheckbox.Layout.Column = 2;

% Set up axis on which bundles are displayed
ax.Layout.Row = 2;
ax.Layout.Column = [1, ImageGui.columns];
end