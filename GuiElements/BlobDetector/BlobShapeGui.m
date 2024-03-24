classdef BlobShapeGui
    properties (Constant)
        ellipseKeyword = "Ellipse";
        rectangleKeyword = "Rectangle";
        keywords = [ ...
            BlobShapeGui.rectangleKeyword, ...
            BlobShapeGui.ellipseKeyword ...
            ];

        rows = 1;
        columns = 6;
        size = [BlobShapeGui.rows, BlobShapeGui.columns];
    end

    properties (Access = private)
        gridLayout;
        sizeSpinners;
        shapeDropdown;
    end

    methods
        function obj = BlobShapeGui(gl)
            obj.gridLayout = gl;
            obj.sizeSpinners = generateSizeElements(gl);
            obj.shapeDropdown = generateShapeDropdown(gl);
            layoutElements(obj);
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function dropdown = getShapeDropdown(obj)
            dropdown = obj.shapeDropdown;
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
    end

    %% Functions to retrieve state information
    methods
        function shape = getBlobShape(obj)
            dropdown = obj.getShapeDropdown();
            shape = get(dropdown, "Value");
        end

        function h = getBlobHeight(obj)
            heightSpinner = obj.getHeightSpinner();
            h = get(heightSpinner, "Value");
        end
        function w = getBlobWidth(obj)
            widthSpinner = obj.getWidthSpinner();
            w = get(widthSpinner, "Value");
        end
        function [h, w] = getRectangleSize(obj)
            h = obj.getBlobHeight();
            w = obj.getBlobWidth();
        end
    end
end



function layoutElements(gui)
% retrieve GUI elements
gl = gui.getGridLayout();
shapeDropdown = gui.getShapeDropdown();
heightSpinner = gui.getHeightSpinner();
widthSpinner = gui.getWidthSpinner();

% generate labels for appropriate elements
shapeLabel = uilabel(gl, "Text", "Shape");
heightLabel = uilabel(gl, "Text", "Height:");
widthLabel = uilabel(gl, "Text", "Width:");

% lay out elements
elems = [ ...
    shapeLabel, ...
    shapeDropdown, ...
    heightLabel, ...
    heightSpinner, ...
    widthLabel, ...
    widthSpinner ...
    ];
for index = 1:numel(elems)
    elem = elems(index);
    elem.Layout.Column = index;
    elem.Layout.Row = 1;
end
end

function spinners = generateSizeElements(gl)
varargin = {"Limits", [0, Inf], "Value", 32, "Step", 1};
heightSpinner = uispinner(gl, varargin{:});
widthSpinner = uispinner(gl, varargin{:});
spinners = [heightSpinner, widthSpinner];
end

function dropdown = generateShapeDropdown(gl)
dropdown = uidropdown(gl);
set(dropdown, ...
    "Items", BlobShapeGui.keywords, ...
    "Value", BlobShapeGui.rectangleKeyword ...
    );
end
