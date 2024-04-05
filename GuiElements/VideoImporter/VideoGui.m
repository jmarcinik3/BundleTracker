classdef VideoGui < handle
    properties (Access = private)
        gridLayout;
        filepathField;
        frameElement;
    end

    methods
        function obj = VideoGui(parent, location, varargin)
            p = inputParser;
            addOptional(p, "ValueChangedFcn", []);
            parse(p, varargin{:});
            valueChangedFcn = p.Results.ValueChangedFcn;

            gl = generateGridLayout(parent, location);
            obj.filepathField = generateFilepathField(gl, valueChangedFcn);
            obj.frameElement = uilabel(gl, ...
                "Text", "", ...
                "HorizontalAlignment", "center" ...
                );
            
            obj.filepathField.Layout.Column = 1;
            obj.frameElement.Layout.Column = 2;
            obj.gridLayout = gl;
        end 
    end
    
    %% Functions to retrieve GUI elements
    methods
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function ta = getFilepathField(obj)
            ta = obj.filepathField;
        end
        function elem = getFrameLabel(obj)
            elem = obj.frameElement;
        end
        function fig = getFigure(obj)
            gl = obj.getGridLayout();
            fig = ancestor(gl, "figure");
        end
    end

    %% Functions to retrieve state information
    methods
        function filepath = getFilepath(obj)
            filepathField = obj.getFilepathField();
            filepath = filepathField.Value;
        end
        function directoryPath = getDirectoryPath(obj)
            filepath = obj.getFilepath();
            directoryPath = fileparts(filepath);
        end
    end
end



function gl = generateGridLayout(parent, location)
gl = uigridlayout(parent, [1, 3]);
gl.Layout.Row = location{1};
gl.Layout.Column = location{2};

set(gl, ...
    "Padding", [0, 0, 0, 0], ...
    "ColumnWidth", {'3x', '1x'} ...
    );
end

function editfield = generateFilepathField(gl, valueChangedFcn)
editfield = uieditfield(gl);
set(editfield, ...
    "Enable", false, ...
    "ValueChangedFcn", valueChangedFcn ...
    );
editfield.Layout.Column = 1;
end
