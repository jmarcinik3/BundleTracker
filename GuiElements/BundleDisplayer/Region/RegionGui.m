classdef RegionGui
    properties (Access = private)
        gridLayout;
        preprocessorGui;
        regionMoverGui;
        regionCompressorGui;
        regionExpanderGui;
    end

    methods
        function obj = RegionGui(parent, location)
            gl = generateGridLayout(parent, location);
            preprocessorGui = PreprocessorGui(gl);
            regionMoverGui = RegionMoverGui(gl);
            regionCompressorGui = RegionCompressorGui(gl);
            regionExpanderGui = RegionExpanderGui(gl);

            layoutElements( ...
                preprocessorGui, ...
                regionMoverGui, ...
                regionCompressorGui, ...
                regionExpanderGui ...
                );
            
            obj.gridLayout = gl;
            obj.preprocessorGui = preprocessorGui;
            obj.regionMoverGui = regionMoverGui;
            obj.regionCompressorGui = regionCompressorGui;
            obj.regionExpanderGui = regionExpanderGui;
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
        function gui = getRegionCompressorGui(obj)
            gui = obj.regionCompressorGui;
        end
        function gui = getRegionExpanderGui(obj)
            gui = obj.regionExpanderGui;
        end
    end
end



function layoutElements( ...
    preprocessorGui, ...
    regionMoverGui, ...
    regionCompressorGui, ...
    regionExpanderGui ...
    )
% Set component heights in grid layout
rowHeight = TrackingGui.rowHeight;

% Retrieve components
gl = preprocessorGui.getGridLayout();
ax = preprocessorGui.getAxis();
thresholdSlider = preprocessorGui.getThresholdSlider();
invertCheckbox = preprocessorGui.getInvertCheckbox();

regionMoverElement = regionMoverGui.getGridLayout();
regionCompressorElement = regionCompressorGui.getGridLayout();
regionExpanderElement = regionExpanderGui.getGridLayout();

ax.Layout.Row = [1, 4];
ax.Layout.Column = 1;

thresholdSlider.Layout.Row = 1;
invertCheckbox.Layout.Row = 2;
regionMoverElement.Layout.Row = 3;
regionCompressorElement.Layout.Row = 3;
regionExpanderElement.Layout.Row = 3;

thresholdSlider.Layout.Column = [2, 5];
invertCheckbox.Layout.Column = [2, 5];
regionMoverElement.Layout.Column = 2;
regionCompressorElement.Layout.Column = 3;
regionExpanderElement.Layout.Column = 4;

% Set up row heights and column widths for grid layout
set(gl, ...
    "Padding", [rowHeight, 0, rowHeight, 0], ...
    "RowHeight", {rowHeight, rowHeight, '1x', 'fit'}, ...
    "ColumnWidth", {'1x', 48, 48, 48, '1x'} ...
    );
end

function gl = generateGridLayout(parent, location)
gl = uigridlayout(parent, [4, 5]);
gl.Layout.Row = location{1};
gl.Layout.Column = location{2};
end