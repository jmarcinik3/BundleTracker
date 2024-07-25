classdef RegionGui < ProcessorGui
    properties (Constant, Access = private)
        rows = 4;
        columns = 1;
        size = [RegionGui.rows, RegionGui.columns];
    end

    properties (Access = private)
        gridLayout;
        regionMoverGui;
        regionCompressorGui;
        regionExpanderGui;
    end

    methods
        function obj = RegionGui(gl)
            obj@ProcessorGui(gl);
            
            adjusterGl = uigridlayout(gl, [1, 3]);
            regionMoverGui = RegionMoverGui(adjusterGl);
            regionCompressorGui = RegionCompressorGui(adjusterGl);
            regionExpanderGui = RegionExpanderGui(adjusterGl);
            guis = {regionMoverGui, regionCompressorGui, regionExpanderGui};
            layoutAdjusterElements(guis);

            obj.gridLayout = gl;
            layoutAdjusterElements(guis);
            layoutElements(obj, adjusterGl);
            

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



function layoutElements(obj, adjusterGl)
% retrieve components
gl = obj.getGridLayout();
ax = obj.getAxis();
preprocessingGl = layoutPreprocessingElements(gl, obj);
processingGl = layoutProcessingElements(gl, obj);

% lay out full-row elements across all columns
elements = [ ...
    ax, ...
    preprocessingGl, ...
    processingGl, ...
    adjusterGl ...
    ];
for index = 1:numel(elements)
    element = elements(index);
    set(element, "Parent", gl);
    element.Layout.Row = index;
end

rowHeight = TrackingGui.rowHeight;
set(gl, ...
    "RowSpacing", 0, ...
    "RowHeight", {'fit', 4*rowHeight, 6*rowHeight, 3*rowHeight}, ...
    "ColumnWidth", {'1x'} ...
    );
end

function gl = layoutPreprocessingElements(parent, gui)
% Retrieve components
gl = uigridlayout(parent, [3, 1]);
smoothingSlider = gui.getSmoothingSlider();
thresholdSlider = gui.getThresholdSlider();
invertCheckbox = gui.getInvertCheckbox();

% lay out elements
elements = [ ...
    smoothingSlider, ...
    thresholdSlider, ...
    invertCheckbox ...
    ];
for index = 1:numel(elements)
    element = elements(index);
    set(element, "Parent", gl);
    element.Layout.Row = index;
end

set(gl, ...
    "Padding", 0, ...
    "RowSpacing", 0, ...
    "RowHeight", {'1.5x', '1.5x', '1x'} ...
    );
end

function gl = layoutProcessingElements(parent, gui)
% Retrieve components
gl = uigridlayout(parent, [4, 1]);
trackingSelection = gui.getTrackingSelectionElement();
angleSelection = gui.getAngleSelectionElement();
detrendSelection = gui.getDetrendSelectionElement();
directionElement = gui.getPositiveDirectionElement();

% lay out elements
elements = [ ...
    trackingSelection, ...
    angleSelection, ...
    detrendSelection, ...
    directionElement ...
    ];
for index = 1:numel(elements)
    element = elements(index);
    set(element, "Parent", gl);
    element.Layout.Row = index;
end

set(gl, ...
    "Padding", 0, ...
    "RowSpacing", 0, ...
    "RowHeight", {'1x', '1x', '1x', '3x'} ...
    );
end

function layoutAdjusterElements(guis)
for index = 1:numel(guis)
    element = guis{index}.getGridLayout();
    element.Layout.Column = index;
end
end
