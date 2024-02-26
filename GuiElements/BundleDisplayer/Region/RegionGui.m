classdef RegionGui
    properties (Access = private)
        gridLayout;
        preprocessorGui;
        regionMoverGui;
    end

    methods
        function obj = RegionGui(parent, location)
            gl = generateGridLayout(parent, location);
            preprocessorGui = PreprocessorGui(gl);
            regionMoverGui = RegionMoverGui(gl);

            layoutElements(preprocessorGui, regionMoverGui);
            
            obj.gridLayout = gl;
            obj.preprocessorGui = preprocessorGui;
            obj.regionMoverGui = regionMoverGui;
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function gui = getPreprocessorGui(obj)
            gui = obj.preprocessorGui;
        end
        function gui = getRegionMoverGui(obj)
            gui = obj.regionMoverGui;
        end
    end
end



function layoutElements(preprocessorGui, regionMoverGui)
% Set component heights in grid layout
rowHeight = TrackingGui.rowHeight;

% Retrieve components
gl = preprocessorGui.getGridLayout();
ax = preprocessorGui.getAxis();
thresholdSlider = preprocessorGui.getThresholdSlider();
invertCheckbox = preprocessorGui.getInvertCheckbox();
regionMoverElement = regionMoverGui.getGridLayout();

ax.Layout.Row = [1, 4];
ax.Layout.Column = 1;

thresholdSlider.Layout.Row = 1;
invertCheckbox.Layout.Row = 2;
regionMoverElement.Layout.Row = 3;
thresholdSlider.Layout.Column = 2;
invertCheckbox.Layout.Column = 2;
regionMoverElement.Layout.Column = 2;

% Set up row heights and column widths for grid layout
set(gl, ...
    "Padding", [rowHeight, 0, rowHeight, 0], ...
    "RowHeight", {rowHeight, rowHeight, '1x', 'fit'}, ...
    "ColumnWidth", {'1x', '2x'} ...
    );
end

function gl = generateGridLayout(parent, location)
gl = uigridlayout(parent, [4, 2]);
gl.Layout.Row = location{1};
gl.Layout.Column = location{2};
end