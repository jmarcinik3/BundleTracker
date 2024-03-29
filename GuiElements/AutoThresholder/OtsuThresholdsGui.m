classdef OtsuThresholdsGui
    properties (Constant)
        title = "Threshold Regions by Otsu's Method";
        maxLevelCount = 20;
    end

    properties (Constant, Access = private)
        rows = 3;
        columns = 4;
        size = [OtsuThresholdsGui.rows, OtsuThresholdsGui.columns];
    end

    properties (Access = private)
        gridLayout;
        axisGridLayout;
        levelsSlider;
        countSpinner;
        actionButtons;
    end

    methods
        function obj = OtsuThresholdsGui(fig, regionCount)
            set(fig, "Name", OtsuThresholdsGui.title);
            gl = uigridlayout(fig, OtsuThresholdsGui.size);
            
            obj.axisGridLayout = generateAxes(gl, regionCount);
            obj.levelsSlider = generateLevelsSlider(gl);
            obj.actionButtons = generateActionButtons(gl);
            obj.countSpinner = generateLevelCountSpinner(gl);
            obj.gridLayout = gl;
            layoutElements(obj);
        end
    end
    
    %% Functions to retrieve GUI elements
    methods
        function fig = getFigure(obj)
            agl = obj.axisGridLayout;
            fig = ancestor(agl, "figure");
        end
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function agl = getAxisGridLayout(obj)
            agl = obj.axisGridLayout;
        end
        function axes = getAxes(obj)
            agl = obj.axisGridLayout;
            axes = findobj(agl, "Type", "axes");
        end
        function slider = getLevelsSlider(obj)
            slider = obj.levelsSlider;
        end
        function spinner = getCountSpinner(obj)
            spinner = obj.countSpinner;
        end

        function buttons = getActionButtons(obj)
            buttons = obj.actionButtons;
        end
        function button = getApplyButton(obj)
            button = obj.actionButtons(1);
        end
        function button = getCancelButton(obj)
            button = obj.actionButtons(2);
        end
    end

    %% Functions to retrieve state information
    methods
        function levels = getLevels(obj)
            levelsSlider = obj.getLevelsSlider();
            levels = get(levelsSlider, "Value");
        end
        function levelCount = getLevelCount(obj)
            levelSpinner = obj.getCountSpinner();
            levelCount = get(levelSpinner, "Value");
        end
    end
end




function layoutElements(gui)
% set default row height for GUI elements
rowHeight = TrackingGui.rowHeight;
columns = OtsuThresholdsGui.columns;

% retrieve GUI elements
gl = gui.getGridLayout();
agl = gui.getAxisGridLayout();
levelsSlider = gui.getLevelsSlider();
countSpinner = gui.getCountSpinner();
applyButton = gui.getApplyButton();
cancelButton = gui.getCancelButton();

% generate labels for appropriate elements
levelsLabel = uilabel(gl, "Text", "Pixel Intensity:");
countLabel = uilabel(gl, "Text", "Intensity Levels:");

% lay out axis elements
agl.Layout.Row = 1;
agl.Layout.Column = [1, columns];

% lay out level-based elements
levelElements = [levelsLabel, levelsSlider, countLabel, countSpinner];
for index = 1:numel(levelElements)
    elem = levelElements(index);
    elem.Layout.Row = 2;
    elem.Layout.Column = index;
end

% lay out apply/cancel buttons
applyButton.Layout.Row = 3;
cancelButton.Layout.Row = 3;
applyButton.Layout.Column = [1, 2];
cancelButton.Layout.Column = [3, 4];

% set grid sizes
gl.RowHeight = {'1x', rowHeight, rowHeight};
gl.ColumnWidth = {96, '4x', 96, '1x'};
end


%% Function to generate grid of plotting axes
function agl = generateAxes(gl, axisCount)
rowCount = ceil(sqrt(axisCount));
columnCount = ceil(axisCount / rowCount);

agl = uigridlayout(gl, [rowCount, columnCount]);
axisCreatedCount = 0;
for rowIndex = 1:rowCount
    for columnIndex = 1:columnCount
        ax = generateEmptyAxis(agl);
        ax.Layout.Row = rowIndex;
        ax.Layout.Column = columnIndex;
        axisCreatedCount = axisCreatedCount + 1;

        if axisCreatedCount == axisCount
            break;
        end
    end
    if axisCreatedCount == axisCount
        break;
    end
end
end

function slider = generateLevelsSlider(gl)
slider = uislider(gl, "range");
maxLevelCount = OtsuThresholdsGui.maxLevelCount;
sliderLimits = [0, maxLevelCount+1];
set(slider, "Limits", sliderLimits, "Value", sliderLimits);
end

function spinner = generateLevelCountSpinner(gl)
spinner = uispinner(gl);
maxLevelCount = OtsuThresholdsGui.maxLevelCount;

set(spinner, ...
    "Limits", [1, maxLevelCount], ...
    "Value", maxLevelCount, ...
    "Step", 1 ...
    );
end
