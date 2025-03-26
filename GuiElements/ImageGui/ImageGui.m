classdef ImageGui < ProcessorGui
    properties (Constant, Access = private)
        rows = 3;
        columns = 1;
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
% Retrieve components
gl = imageGui.getGridLayout();
ax = imageGui.getAxis();
preprocessingGl = layoutPreprocessingElements(gl, imageGui);
processingGl = layoutProcessingElements(gl, imageGui);

elements = [ ...
    ax, ...
    preprocessingGl, ...
    processingGl ...
    ];
for index = 1:numel(elements)
    elements(index).Layout.Row = index;
end

set(gl, ...
    "RowSpacing", 0, ...
    "RowHeight", {'1x', 75, DirectionGui.height} ...
    );
end

function gl = layoutPreprocessingElements(parent, gui)
% Retrieve components
gl = uigridlayout(parent, [1, 5]);
smoothingShaper = gui.getSmoothingShaper();
thresholdSlider = gui.getThresholdSlider();
invertCheckbox = gui.getInvertCheckbox();

% generate labels for appropriate elements
smoothingLabel = uilabel(gl, "Text", "Smoothing:");
thresholdLabel = uilabel(gl, "Text", "Intensity:");

% lay out elements
elements = [ ...
    smoothingLabel, ...
    smoothingShaper, ...
    thresholdLabel, ...
    thresholdSlider, ...
    invertCheckbox ...
    ];
for index = 1:numel(elements)
    element = elements(index);
    set(element, "Parent", gl);
    element.Layout.Row = 1;
    element.Layout.Column = index;
end

set(gl, ...
    "Padding", 0, ...
    "RowSpacing", 0, ...
    "ColumnWidth", {75, '1x', 75, '1x', 75} ...
    );
end

function gl = layoutProcessingElements(parent, gui)
% Retrieve components
gl = uigridlayout(parent, [3, 4]);
trackingSelection = gui.getTrackingSelectionElement();
angleSelection = gui.getAngleSelectionElement();
detrendSelection = gui.getDetrendSelectionElement();
directionElement = gui.getPositiveDirectionElement();

% generate labels for appropriate elements
trackingLabel = uilabel(gl, "Text", "Track:");
angleLabel = uilabel(gl, "Text", "Rotate:");
detrendLabel = uilabel(gl, "Text", "Detrend:");

% lay out elements
elements = [ ...
    trackingLabel, ...
    trackingSelection, ...
    angleLabel, ...
    angleSelection, ...
    detrendLabel, ...
    detrendSelection ...
    ];
for index = 1:numel(elements)
    element = elements(index);
    set(element, "Parent", gl);
    element.Layout.Row = floor((index-1) / 2) + 1;
    element.Layout.Column = mod(index+1, 2) + 1;
end

set(directionElement, "Parent", gl);
directionElement.Layout.Row = [1, 3];
directionElement.Layout.Column = [3, 4];

% Set up row heights and column widths for grid layout
rowSpacing = 0;
rowHeight = (DirectionGui.height - rowSpacing) / 3;

set(gl, ...
    "Padding", 0, ...
    "RowSpacing", rowSpacing, ...
    "RowHeight", rowHeight, ...
    "ColumnWidth", {75, '1x', 150, '1x'} ...
    );
end
