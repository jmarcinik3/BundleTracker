classdef BlobDetectorGui
    properties (Constant)
        title = "Add Regions by Blob Detection";
    end

    properties (Constant, Access = private)
        rows = 6;
        columns = 4;
        size = [BlobDetectorGui.rows, BlobDetectorGui.columns];
        applyText = "Apply";
        cancelText = "Cancel";
    end

    properties (Access = private)
        gridLayout;
        axis;
        thresholdSlider;
        areaSlider;
        countSpinner;
        connectivityElement;
        sizeSpinners;
        actionButtons;
    end

    methods
        function obj = BlobDetectorGui(fig)
            set(fig, "Name", BlobDetectorGui.title);
            gl = uigridlayout(fig, BlobDetectorGui.size);
            
            obj.gridLayout = gl;
            obj.axis = generateAxis(gl);
            obj.thresholdSlider = generateThresholdSlider(gl);
            obj.areaSlider = generateAreaSlider(gl);
            obj.connectivityElement = generateConnectivityElement(gl);
            obj.countSpinner = generateCountSpinner(gl);
            obj.sizeSpinners = generateSizeElements(gl);
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
        
        function spinners = getSizeSpinners(obj)
            spinners = obj.sizeSpinners;
        end
        function spinner = getHeightSpinner(obj)
            spinner = obj.sizeSpinners(1);
        end
        function spinner = getWidthSpinner(obj)
            spinner = obj.sizeSpinners(2);
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
            areas = uint16(slider.Value);
        end
        function connectivity = getConnectivity(obj)
            elem = obj.getConnectivityElement();
            connectivity = elem.Value;
        end
        function maxCount = getMaximumCount(obj)
            spinner = obj.getCountSpinner();
            maxCount = spinner.Value;
        end

        function h = getRectangleHeight(obj)
            heightSpinner = obj.getHeightSpinner();
            h = get(heightSpinner, "Value");
        end
        function w = getRectangleWidth(obj)
            widthSpinner = obj.getWidthSpinner();
            w = get(widthSpinner, "Value");
        end
        function [h, w] = getRectangleSize(obj)
            h = obj.getRectangleHeight();
            w = obj.getRectangleWidth();
        end
    end
end



function layoutElements(gui)
% set default row height for GUI elements
rowHeight = TrackingGui.rowHeight;

% retrieve GUI elements
gl = gui.getGridLayout();
axis = gui.getAxis();
thresholdSlider = gui.getThresholdSlider();
areaSlider = gui.getAreaSlider();
connectivityElement = gui.getConnectivityElement();
countSpinner = gui.getCountSpinner();
heightSpinner = gui.getHeightSpinner();
widthSpinner = gui.getWidthSpinner();
applyButton = gui.getApplyButton();
cancelButton = gui.getCancelButton();

% generate labels for appropriate elements
thresholdLabel = uilabel(gl, "Text", "Pixel Intensity:");
areaLabel = uilabel(gl, "Text", "Blob Area:");
connectivityLabel = uilabel(gl, "Text", "Connectivity:");
countLabel = uilabel(gl, "Text", "Maximum Blob Count:");
heightLabel = uilabel(gl, "Text", "Height:");
widthLabel = uilabel(gl, "Text", "Width:");

% lay out axis showing image and blobs
axis.Layout.Row = 1;
axis.Layout.Column = [1, 4];

% lay out slider elements
sliders = [thresholdSlider, areaSlider];
sliderLabels = [thresholdLabel, areaLabel];
for index = 1:numel(sliderLabels)
    label = sliderLabels(index);
    slider = sliders(index);

    label.Layout.Row = index + 1;
    slider.Layout.Row = index + 1;
    label.Layout.Column = 1;
    slider.Layout.Column = [2, 4];
end

% lay out some elements to choose blob detection inputs
blobElements = [connectivityLabel, connectivityElement, countLabel, countSpinner];
for index = 1:numel(blobElements)
    elem = blobElements(index);
    elem.Layout.Column = index;
    elem.Layout.Row = 4;
end

% lay out elements to choose rectangle height/width
sizeElements = [heightLabel, heightSpinner, widthLabel, widthSpinner];
for index = 1:numel(sizeElements)
    elem = sizeElements(index);
    elem.Layout.Column = index;
    elem.Layout.Row = 5;
end

applyButton.Layout.Row = 6;
applyButton.Layout.Column = [1, 2];
cancelButton.Layout.Row = 6;
cancelButton.Layout.Column = [3, 4];

% set grid sizes
gl.RowHeight = num2cell(rowHeight * ones(1, 6));
gl.RowHeight{1} = '1x';
gl.ColumnWidth = {128, '1x', 128, '1x'};
end



function ax = generateAxis(gl)
ax = uiaxes(gl);
ax.Toolbar.Visible = "off";
ax.set( ...
    "Visible", "off", ...
    "XtickLabel", [], ...
    "YTickLabel", [] ...
    );
end

function buttons = generateActionButtons(gl)
applyButton = uibutton(gl, "Text", BlobDetectorGui.applyText);
cancelButton = uibutton(gl, "Text", BlobDetectorGui.cancelText);
buttons = [applyButton, cancelButton];
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

function spinners = generateSizeElements(gl)
varargin = {"Limits", [0, Inf], "Value", 32, "Step", 1};
heightSpinner = uispinner(gl, varargin{:});
widthSpinner = uispinner(gl, varargin{:});
spinners = [heightSpinner, widthSpinner];
end
