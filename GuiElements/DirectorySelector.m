classdef DirectorySelector < handle
    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>

        gridLayout;
        directoryPathField;
        filecountField;
        filepather;
    end

    methods
        function obj = DirectorySelector(parent, location, varargin)
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

    %% Functions to generate GUI elements
    methods (Access = private)
        function filepather = generateFilepather(obj)
            directoryPath = obj.getDirectoryPath();
            filepather = ImageFilepather(directoryPath);
        end
    end
    
    %% Functions to retrieve GUI elements
    methods (Access = protected)
        function gl = getDirectorySelectionElement(obj)
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
    methods (Access = protected)
        function im = getFirstImage(obj)
            if obj.directoryHasImage()
                filepath = obj.getFirstFilepath();
                im = imread(filepath);
            else
                im = [];
            end
        end
        function text = getDirectoryPath(obj)
            ta = obj.getDirectoryPathField();
            text = ta.Value;
        end
        function filepaths = getFilepaths(obj)
            filepaths = obj.filepather.getFilepaths();
        end
    end
    methods (Access = private)
        function filepath = getFirstFilepath(obj)
            filepath = obj.filepather.getFilepath(1);
        end
        function count = getFilecount(obj)
            count = obj.filepather.getFilecount();
        end

        function is = directoryIsValid(obj)
            directoryPath = obj.getDirectoryPath();
            is = directoryIsValid(directoryPath);
            if ~is
                obj.throwAlertMessage("Directory path is invalid!", "Open Directory");
            end
        end
        function has = directoryHasImage(obj)
            count = obj.getFilecount();
            directory = obj.getDirectoryPath();
            has = count >= 1 && isfolder(directory);
            if ~has
                obj.throwAlertMessage("No valid images found!", "Choose Directory");
            end
        end
    end

    %% Functions to set state information
    methods (Access = protected)
        function setDirectory(obj, directoryPath, source, event)
            directoryPathField = obj.getDirectoryPathField();
            directoryPathField.Value = directoryPath;
            obj.updateFilepather();

            
            if nargin == 2
                source = obj;
                event = struct( ...
                    "Source", source, ...
                    "EventName", "FakeEvent" ...
                    );
            end
            directoryPathField.ValueChangedFcn(source, event);
        end
        function setDirectoryValueChangedFcn(obj, valueChangedFcn)
            directoryPathField = obj.getDirectoryPathField();
            set(directoryPathField, "ValueChangedFcn", valueChangedFcn);
        end
    end
    methods (Access = private)
        function setDirectoryIfChosen(obj, directoryPath, source, event)
            if directoryIsChosen(directoryPath)
                obj.setDirectory(directoryPath, source, event);
            end
        end
        function setFilecount(obj, count)
            elem = obj.getFilecountField();
            label = num2str(count);
            set(elem, "Text", label);
        end
    end
    
    %% Functions to update state information
    methods
        function chooseDirectory(obj, source, event)
            previousDirectoryPath = obj.getDirectoryPath();
            directoryPath = uigetdir(previousDirectoryPath);
            obj.setDirectoryIfChosen(directoryPath, source, event);
        end
        function openDirectory(obj, ~, ~)
            if obj.directoryIsValid()
                directoryPath = obj.getDirectoryPath();
                winopen(directoryPath);
            end
        end
    end
    methods (Access = private)
        function updateFilepather(obj)
            filepather = obj.generateFilepather();
            obj.filepather = filepather;
            obj.updateFilecount();
        end
        function updateFilecount(obj)
            count = obj.getFilecount();
            obj.setFilecount(count);
        end
        function throwAlertMessage(obj, message, title)
            fig = obj.getFigure();
            uialert(fig, message, title);
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

function is = directoryIsChosen(directoryPath)
is = directoryPath ~= 0;
end
function is = directoryIsValid(directoryPath)
is = isfolder(directoryPath);
end