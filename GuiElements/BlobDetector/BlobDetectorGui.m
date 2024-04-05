classdef BlobDetectorGui
    properties (Constant)
        title = "Add Regions by Blob Detection";
    end

    properties (Constant)
        rows = 7;
        columns = 4;
        size = [BlobDetectorGui.rows, BlobDetectorGui.columns];
    end

    properties (Access = private)
        gridLayout;
        axis;
        thresholdSlider;
        areaSlider;
        countSpinner;
        connectivityElement;
        excludeBorderBlobsCheckbox;
        actionButtons;
        blobShapeGui;
    end

    methods
        function obj = BlobDetectorGui(fig)
            set(fig, "Name", BlobDetectorGui.title);
            gl = uigridlayout(fig, BlobDetectorGui.size);
            shapeGl = uigridlayout(gl);

            obj.gridLayout = gl;
            obj.axis = generateEmptyAxis(gl);
            obj.thresholdSlider = generateThresholdSlider(gl);
            obj.areaSlider = generateAreaSlider(gl);
            obj.connectivityElement = generateConnectivityElement(gl);
            obj.countSpinner = generateCountSpinner(gl);
            obj.blobShapeGui = BlobShapeGui(shapeGl);
            obj.excludeBorderBlobsCheckbox = generateExcludeBorderBlobsCheckbox(gl);
            obj.actionButtons = generateActionButtons(gl);
            layoutElements(obj);
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function fig = getFigure(obj)
            ax = obj.getAxis();
            fig = ancestor(ax, "figure");
        end
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function ax = getAxis(obj)
            ax = obj.axis;
        end
        function slider = getThresholdSlider(obj)
            slider = obj.thresholdSlider;
        end
        function slider = getAreaSlider(obj)
            slider = obj.areaSlider;
        end
        function elem = getConnectivityElement(obj)
            elem = obj.connectivityElement;
        end
        function spinner = getCountSpinner(obj)
            spinner = obj.countSpinner;
        end
        function checkbox = getExcludeBorderBlobsCheckbox(obj)
            checkbox = obj.excludeBorderBlobsCheckbox;
        end

        function dropdown = getShapeDropdown(obj)
            dropdown = obj.blobShapeGui.getShapeDropdown();
        end
        function spinners = getSizeSpinners(obj)
            spinners = obj.blobShapeGui.getSizeSpinners();
        end
        function spinner = getHeightSpinner(obj)
            spinner = obj.blobShapeGui.getHeightSpinner();
        end
        function spinner = getWidthSpinner(obj)
            spinner = obj.blobShapeGui.getWidthSpinner();
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
        function thresholds = getThresholds(obj)
            slider = obj.getThresholdSlider();
            thresholds = slider.Value;
        end
        function areas = getAreas(obj)
            slider = obj.getAreaSlider();
            areas = round(slider.Value);
        end
        function connectivity = getConnectivity(obj)
            elem = obj.getConnectivityElement();
            connectivity = elem.Value;
        end
        function maxCount = getMaximumCount(obj)
            spinner = obj.getCountSpinner();
            maxCount = spinner.Value;
        end
        function exclude = getExcludeBorderBlob(obj)
            checkbox = obj.getExcludeBorderBlobsCheckbox();
            exclude = checkbox.Value;
        end

        function shape = getBlobShape(obj)
            shape = obj.blobShapeGui.getBlobShape();
        end
        function h = getBlobHeight(obj)
            h = obj.blobShapeGui.getBlobHeight();
        end
        function w = getBlobWidth(obj)
            w = obj.blobShapeGui.getBlobWidth();
        end
        function [h, w] = getRectangleSize(obj)
            [h, w] = obj.blobShapeGui.getRectangleSize();
        end
    end
end



function layoutElements(gui)
% set default row height for GUI elements
rowHeight = TrackingGui.rowHeight;
rows = BlobDetectorGui.rows;
columns = BlobDetectorGui.columns;

% retrieve GUI elements
gl = gui.getGridLayout();
axis = gui.getAxis();
thresholdSlider = gui.getThresholdSlider();
areaSlider = gui.getAreaSlider();
connectivityElement = gui.getConnectivityElement();
countSpinner = gui.getCountSpinner();
shapeGridLayout = gui.blobShapeGui.getGridLayout();
excludeBorderBlobsCheckbox = gui.getExcludeBorderBlobsCheckbox();
applyButton = gui.getApplyButton();
cancelButton = gui.getCancelButton();

% generate labels for appropriate elements
thresholdLabel = uilabel(gl, "Text", "Pixel Intensity:");
areaLabel = uilabel(gl, "Text", "Blob Area:");
connectivityLabel = uilabel(gl, "Text", "Connectivity:");
countLabel = uilabel(gl, "Text", "Maximum Blob Count:");

% lay out axis showing image and blobs
axis.Layout.Row = 1;
axis.Layout.Column = [1, columns];

% lay out slider elements
sliders = [thresholdSlider, areaSlider];
sliderLabels = [thresholdLabel, areaLabel];
for index = 1:numel(sliderLabels)
    label = sliderLabels(index);
    slider = sliders(index);

    label.Layout.Row = index + 1;
    slider.Layout.Row = index + 1;
    label.Layout.Column = 1;
    slider.Layout.Column = [2, columns];
end

% lay out some elements to choose blob detection inputs
blobElements = [connectivityLabel, connectivityElement, countLabel, countSpinner];
for index = 1:numel(blobElements)
    elem = blobElements(index);
    elem.Layout.Column = index;
    elem.Layout.Row = 4;
end

% lay out elements to choose blob shape
shapeGridLayout.Layout.Column = [1, columns];
shapeGridLayout.Layout.Row = 5;


% lay out checkbox to exclude blobs along border
excludeBorderBlobsCheckbox.Layout.Row = 6;
excludeBorderBlobsCheckbox.Layout.Column = [1, columns];

% lay out button to close window
applyButton.Layout.Row = rows;
applyButton.Layout.Column = [1, 2];
cancelButton.Layout.Row = rows;
cancelButton.Layout.Column = [3, 4];

% set grid sizes
gl.RowHeight = num2cell(rowHeight * ones(1, 7));
gl.RowHeight{1} = '1x';
gl.ColumnWidth = {144, '1x', 144, '1x'};

set(shapeGridLayout, ...
    "Padding", [0, 0, 0, 0], ...
    "RowHeight", rowHeight, ...
    "ColumnWidth", {48, '1x', 48, '1x', 48, '1x'} ...
    );
end

function slider = generateThresholdSlider(gl)
slider = uislider(gl, "range");
set(slider, ...
    "Limits", [0, 1], ...
    "Value", [0, 1], ...
    "MajorTicks", 0:0.1:1, ...
    "MinorTicks", 0:0.01:1 ...
    )
end

function slider = generateAreaSlider(gl)
slider = uislider(gl, "range");
set(slider, ...
    "Limits", [0, 256], ...
    "Value", [0, 256] ...
    )
end

function elem = generateConnectivityElement(gl)
elem = uispinner(gl);
set(elem, ...
    "Limits", [4, 8], ...
    "Value", 8, ...
    "Step", 4 ...
    );
end

function spinner = generateCountSpinner(gl)
spinner = uispinner(gl);
set(spinner, ...
    "Limits", [0, Inf], ...
    "Value", 100, ...
    "Step", 1 ...
    );
end

function checkbox = generateExcludeBorderBlobsCheckbox(gl)
checkbox = uicheckbox(gl);
set(checkbox, ...
    "Text", "Exclude Border Blobs", ...
    "Value", 1 ...
    );
end
