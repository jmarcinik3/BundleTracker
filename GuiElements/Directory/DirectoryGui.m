classdef DirectoryGui < handle
    properties (Constant)
        chooseTitle = "Import Directory";
        openTitle = "Open Directory";
    end

    properties (Access = private)
        gridLayout;
        directoryPathField;
        filecountField;
    end

    methods
        function obj = DirectoryGui(parent, location, varargin)
            p = inputParser;
            addOptional(p, "ValueChangedFcn", []);
            parse(p, varargin{:});
            valueChangedFcn = p.Results.ValueChangedFcn;

            gl = generateGridLayout(parent, location);
            obj.directoryPathField = generateDirpathField(gl, valueChangedFcn);
            obj.filecountField = generateFilecountField(gl);
            obj.gridLayout = gl;
        end 
    end
    
    %% Functions to retrieve GUI elements
    methods
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function ta = getDirectoryPathField(obj)
            ta = obj.directoryPathField;
        end
        function lbl = getFilecountField(obj)
            lbl = obj.filecountField;
        end
        function fig = getFigure(obj)
            gl = obj.getGridLayout();
            fig = ancestor(gl, "figure");
        end
    end

    %% Functions to retrieve state information
    methods
        function text = getDirectoryPath(obj)
            ta = obj.getDirectoryPathField();
            text = ta.Value;
        end
    end
end



function gl = generateGridLayout(parent, location)
rowHeight = TrackingGui.rowHeight;

gl = uigridlayout(parent, [1, 2]);
gl.Layout.Row = location{1};
gl.Layout.Column = location{2};

set(gl, ...
    "Padding", [0, 0, 0, 0], ...
    "ColumnWidth", {'1x', 3 * rowHeight} ...
    );
end

function editfield = generateDirpathField(gl, valueChangedFcn)
editfield = uieditfield(gl);
set(editfield, ...
    "Enable", false, ...
    "ValueChangedFcn", valueChangedFcn ...
    );
editfield.Layout.Column = 1;
end

function editfield = generateFilecountField(gl)
editfield = uilabel(gl);
set(editfield, "Text", num2str(0));
editfield.Layout.Column = 2;
end
