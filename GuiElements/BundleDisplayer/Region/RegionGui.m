classdef RegionGui
    properties (Access = private)
        gridLayout;
        preprocessorGui;
        regionMoverGui;
        regionCompressorGui;
        regionExpanderGui;

        getAxis;
        getImageSize;
    end

    methods
        function obj = RegionGui(parent)
            gl = uigridlayout(parent, [4, 5]);
            preprocessorGui = PreprocessorGui(gl);
            regionMoverGui = RegionMoverGui(gl);
            regionCompressorGui = RegionCompressorGui(gl);
            regionExpanderGui = RegionExpanderGui(gl);

            % inherited getters
            obj.getAxis = @preprocessorGui.getAxis;
            obj.getImageSize = @preprocessorGui.getImageSize;
            iIm = preprocessorGui.getInteractiveImage();
            addlistener(iIm, "CData", "PostSet", @obj.resizeAxis);

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

    %% Functions to update state of GUI
    methods (Access = private)
        function resizeAxis(obj, ~, ~)
            ax = obj.getAxis();
            [h, w] = obj.getImageSize();
            resizeAxis(ax, h, w, "FitToContent", true);
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

% layout axis
ax.Layout.Row = 1;
ax.Layout.Column = [1, 5];

% layout rows
thresholdSlider.Layout.Row = 2;
invertCheckbox.Layout.Row = 3;
regionMoverElement.Layout.Row = 4;
regionCompressorElement.Layout.Row = 4;
regionExpanderElement.Layout.Row = 4;

% layout columns
thresholdSlider.Layout.Column = [1, 5];
invertCheckbox.Layout.Column = [1, 5];
regionMoverElement.Layout.Column = 2;
regionCompressorElement.Layout.Column = 3;
regionExpanderElement.Layout.Column = 4;

% Set up row heights and column widths for grid layout
set(gl, ...
    "Padding", [rowHeight, 0, rowHeight, 0], ...
    "RowHeight", {'1x', rowHeight, rowHeight, 48}, ...
    "ColumnWidth", {'1x', 48, 48, 48, '1x'} ...
    );
end
