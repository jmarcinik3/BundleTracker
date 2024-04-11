classdef AutoThresholdsGui
    properties (Constant, Access = private)
        rows = 3;
        columns = 4;
        size = [AutoThresholdsGui.rows, AutoThresholdsGui.columns];
    end

    properties (Access = private)
        gridLayout;
        axesGrid;
        levelsSlider;
        countSpinner;
        actionButtons;
        
        maxLevelCount;
    end

    methods
        function obj = AutoThresholdsGui(fig, regionCount, maxLevelCount)
            gl = uigridlayout(fig, AutoThresholdsGui.size);

            obj.maxLevelCount = maxLevelCount;

            obj.axesGrid = generateAxesGrid(gl, regionCount);
            obj.levelsSlider = generateLevelsSlider(gl, maxLevelCount);
            obj.actionButtons = generateActionButtons(gl);
            obj.countSpinner = generateLevelCountSpinner(gl, maxLevelCount);
            obj.gridLayout = gl;
            layoutElements(obj);
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function fig = getFigure(obj)
            agl = obj.axesGrid;
            fig = ancestor(agl, "figure");
        end
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function agl = getAxesGrid(obj)
            agl = obj.axesGrid;
        end
        function axes = getAxes(obj)
            agl = obj.axesGrid;
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
        function maxLevelCount = getMaxLevelCount(obj)
            maxLevelCount = obj.maxLevelCount;
        end
    end
end



function layoutElements(gui)
% set default row height for GUI elements
rowHeight = TrackingGui.rowHeight;
columns = AutoThresholdsGui.columns;

% retrieve GUI elements
gl = gui.getGridLayout();
agl = gui.getAxesGrid();
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

function slider = generateLevelsSlider(gl, maxLevelCount)
slider = uislider(gl, "range");
sliderLimits = [0, maxLevelCount+1];
set(slider, "Limits", sliderLimits, "Value", sliderLimits);
end

function spinner = generateLevelCountSpinner(gl, maxLevelCount)
spinner = uispinner(gl);
set(spinner, ...
    "Limits", [1, maxLevelCount], ...
    "Value", maxLevelCount, ...
    "Step", 1 ...
    );
end
