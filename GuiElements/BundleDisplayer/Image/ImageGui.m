classdef ImageGui < PreprocessorGui
    methods
        function obj = ImageGui(parent, location, varargin)
            gl = generateGridLayout(parent, location);
            ax = PreprocessorGui.generateAxis(gl);
            obj@PreprocessorGui(gl, ax);
            layoutElements(obj);
        end
    end

    
end



function layoutElements(preprocessorGui)
% Set component heights in grid layout
rowHeight = TrackingGui.rowHeight;

% Retrieve components
gl = preprocessorGui.getGridLayout();
thresholdSlider = preprocessorGui.getThresholdSlider();
invertCheckbox = preprocessorGui.getInvertCheckbox();
ax = preprocessorGui.getAxis();

% Set up slider for intensity threshold to left of invert checkbox
thresholdSlider.Layout.Row = 1;
thresholdSlider.Layout.Column = 1;
invertCheckbox.Layout.Row = 1;
invertCheckbox.Layout.Column = 2;

% Set up axis on which bundles are displayed
ax.Layout.Row = 2;
ax.Layout.Column = [1 2];

% Set up row heights and column widths for grid layout
set(gl, ...
    "Padding", [0, 0, 0, 0], ...
    "RowHeight", {rowHeight, '1x'}, ...
    "ColumnWidth", {'4x', '1x'} ...
    );
end

function gl = generateGridLayout(parent, location)
gl = uigridlayout(parent, [2, 1]);
gl.Layout.Row = location{1};
gl.Layout.Column = location{2};
end