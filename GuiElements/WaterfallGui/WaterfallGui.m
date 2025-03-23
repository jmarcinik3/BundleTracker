classdef WaterfallGui
    properties (Constant)
        title = "Waterfall Plot";
        defaultLabel = "None";
    end

    properties (Constant, Access = private)
        rows = 2;
        columns = 4;
        size = [WaterfallGui.rows, WaterfallGui.columns];
    end

    properties (Access = private)
        gridLayout;
        axis;
        alphaSlider;
        labelElement;
        % colorPicker;
    end

    methods
        function obj = WaterfallGui(fig)
            set(fig, "Name", WaterfallGui.title);
            gl = uigridlayout(fig, WaterfallGui.size);

            obj.axis = generateAxis(gl);
            obj.alphaSlider = generateAlphaSlider(gl);
            obj.labelElement = generateLabelElement(gl);
            % obj.colorPicker = generateColorPicker(gl);
            obj.gridLayout = gl;

            layoutElements(obj);
        end
    end

    methods
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function ax = getAxis(obj)
            ax = obj.axis;
        end
        function slider = getAlphaSlider(obj)
            slider = obj.alphaSlider;
        end
        function elem = getLabelElement(obj)
            elem = obj.labelElement;
        end
        % function picker = getColorPicker(obj)
        %     picker = obj.colorPicker;
        % end
    end
end



function layoutElements(gui)
% set default row height for GUI elements
columns = WaterfallGui.columns;

% retrieve GUI elements
gl = gui.getGridLayout();
ax = gui.getAxis();
alphaSlider = gui.getAlphaSlider();
% colorPicker = gui.getColorPicker();
labelElement = gui.getLabelElement();

% generate labels for appropriate elements
alphaLabel = uilabel(gl, "Text", "Alpha:");
% colorLabel = uilabel(gl, "Text", "Color:");

ax.Layout.Row = 1;
ax.Layout.Column = [1, columns];

% lay out aesthetic-based elements
elems = [alphaLabel, alphaSlider]; %, colorLabel, colorPicker];
for index = 1:numel(elems)
    elem = elems(index);
    elem.Layout.Row = 2;
    elem.Layout.Column = index;
end
labelElement.Layout.Row = 2;
labelElement.Layout.Column = 4;

% set grid sizes
gl.ColumnWidth = {48, '4x', '1x', 48};
gl.RowHeight = {'1x', 48};
end



function ax = generateAxis(gl)
ax = uiaxes(gl);
ax.XLabel.String = "Time";
ax.YLabel.String = "Position";
end

function slider = generateAlphaSlider(gl)
slider = uislider(gl);
set(slider, ...
    "Limits", [0, 1], ...
    "Value", 0.15, ...
    "MajorTicks", 0:0.1:1, ...
    "MinorTicks", 0:0.02:1 ...
    );
end

% function picker = generateColorPicker(gl)
% picker = uicolorpicker(gl, ...
%     "Value", "red", ...
%     "Icon", "line" ...
%     );
% end

function spinner = generateLabelElement(gl)
spinner = uilabel(gl, "Text", WaterfallGui.defaultLabel);
end
