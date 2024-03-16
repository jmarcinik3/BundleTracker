classdef RegionGui
    properties (Constant, Access = private)
        rows = 7;
        columns = 5;
        size = [RegionGui.rows, RegionGui.columns];
    end

    properties (Access = private)
        gridLayout;
        preprocessorGui;
        postprocessorGui;
        regionMoverGui;
        regionCompressorGui;
        regionExpanderGui;
    end

    methods
        function obj = RegionGui(gl)
            preprocessorGui = PreprocessorGui(gl);
            postprocessorGui = PostprocessorGui(gl);
            regionMoverGui = RegionMoverGui(gl);
            regionCompressorGui = RegionCompressorGui(gl);
            regionExpanderGui = RegionExpanderGui(gl);

            layoutElements( ...
                preprocessorGui, ...
                postprocessorGui, ...
                regionMoverGui, ...
                regionCompressorGui, ...
                regionExpanderGui ...
                );

            obj.gridLayout = gl;
            obj.preprocessorGui = preprocessorGui;
            obj.postprocessorGui = postprocessorGui;
            obj.regionMoverGui = regionMoverGui;
            obj.regionCompressorGui = regionCompressorGui;
            obj.regionExpanderGui = regionExpanderGui;
        end

        function delete(obj)
            delete(obj.gridLayout);
        end
    end

    %% Functions to generate GUI elements
    methods (Static)
        function gl = generateGridLayout(parent)
            gl = uigridlayout(parent, RegionGui.size);
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
        function gui = getPostprocessorGui(obj)
            gui = obj.postprocessorGui;
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
    postprocessorGui, ...
    regionMoverGui, ...
    regionCompressorGui, ...
    regionExpanderGui ...
    )
% Set component heights in grid layout
rowHeight = TrackingGui.rowHeight;
rowCount = RegionGui.rows;
columnCount = RegionGui.columns;
adjusterLength = RegionAdjusterGui.length;

% Retrieve components
gl = preprocessorGui.getGridLayout();

ax = preprocessorGui.getAxis();
thresholdSlider = preprocessorGui.getThresholdSlider();
invertCheckbox = preprocessorGui.getInvertCheckbox();
trackingSelection = postprocessorGui.getTrackingSelectionElement();
angleSelection = postprocessorGui.getAngleSelectionElement();
directionElement = postprocessorGui.getPositiveDirectionElement();

regionMoverElement = regionMoverGui.getGridLayout();
regionCompressorElement = regionCompressorGui.getGridLayout();
regionExpanderElement = regionExpanderGui.getGridLayout();

% lay out full-row elements across all columns
rowElements = [ ...
    ax, ...
    thresholdSlider, ...
    invertCheckbox, ...
    trackingSelection, ...
    angleSelection, ...
    directionElement ...
    ];
for index = 1:numel(rowElements)
    elem = rowElements(index);
    elem.Layout.Row = index;
    elem.Layout.Column = [1, columnCount];
end

% lay out region adjuster elements in same row
adjustElements = [ ...
    regionMoverElement, ...
    regionCompressorElement, ...
    regionExpanderElement ...
    ];
for index = 1:numel(adjustElements)
    elem = adjustElements(index);
    elem.Layout.Column = index + 1;
    elem.Layout.Row = 7;
end

% Set up row heights and column widths for grid layout
gl.RowHeight = num2cell(rowHeight * ones(1, rowCount));
gl.RowHeight{1} = '1x';
gl.RowHeight{6} = DirectionGui.height;
gl.RowHeight{7} = adjusterLength;

gl.ColumnWidth = num2cell(adjusterLength * ones(1, columnCount));
gl.ColumnWidth{1} = '1x';
gl.ColumnWidth{end} = '1x';

set(gl, "Padding", [0, 0, 0, 0]);
end
