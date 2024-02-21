classdef DirectorySelector < handle
    properties (Access = private, Constant)
        imageExtension = ".tif";
    end
    properties (Access = private)
        figure;
        gridLayout;
        dirpathDisplay;
        filecountDisplay;
        chooseButton;
        openButton;

        filepather;
    end

    methods
        function obj = DirectorySelector(parent, varargin)
            p = inputParser;
            addOptional(p, "ValueChangedFcn", []);
            parse(p, varargin{:});
            valueChangedFcn = p.Results.ValueChangedFcn;

            gl = uigridlayout(parent, [1 4]);
            dirpathDisplay = uieditfield(gl);
            filecountDisplay = uilabel(gl);
            chooseButton = uibutton(gl);
            openButton = uibutton(gl);

            set(dirpathDisplay, ...
                "Enable", false, ...
                "ValueChangedFcn", valueChangedFcn ...
                );
            set(filecountDisplay, "Text", num2str(0));
            set(chooseButton, ...
                "Text", "Choose", ...
                "ButtonPushedFcn", @obj.chooseButtonPushed ...
                );
            set(openButton, ...
                "Text", "Open", ...
                "ButtonPushedFcn", @obj.openButtonPushed ...
                );

            dirpathDisplay.Layout.Column = 1;
            chooseButton.Layout.Column = 3;
            openButton.Layout.Column = 4;
            gl.Padding = [0 0 0 0];

            obj.dirpathDisplay = dirpathDisplay;
            obj.filecountDisplay = filecountDisplay;
            obj.chooseButton = chooseButton;
            obj.openButton = openButton;
            obj.gridLayout = gl;
            obj.figure = ancestor(parent, "figure");
        end

        function text = getDirectoryPath(obj)
            ta = obj.getDirpathDisplay();
            text = ta.Value;
        end
        function count = getFilecount(obj)
            count = obj.filepather.getFilecount();
        end
        function filepath = getFirstFilepath(obj)
            filepath = obj.filepather.get(1);
        end
        function filepaths = getFilepaths(obj)
            filepaths = obj.filepather.getFilepaths();
        end

        function setDirectory(obj, directoryPath, source, event)
            tb = obj.getDirpathDisplay();
            tb.Value = directoryPath;

            obj.updateFilepather();
            obj.updateFilecount();

            if nargin == 2
                source = obj.getChooseButton();
                event = struct( ...
                    "Source", source, ...
                    "EventName", "FakeEvent" ...
                    );
            end
            tb.ValueChangedFcn(source, event);
        end
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
    end

    methods (Access = private)
        function chooseButtonPushed(obj, source, event)
            previousDirectoryPath = obj.getDirectoryPath();
            directoryPath = uigetdir(previousDirectoryPath);
            obj.setDirectoryIfChosen(directoryPath, source, event);
        end
        function setDirectoryIfChosen(obj, directoryPath, source, event)
            if directoryIsChosen(directoryPath)
                obj.setDirectory(directoryPath, source, event);
            end
        end
        
        function openButtonPushed(obj, ~, ~)
            if obj.directoryIsValid()
                directoryPath = obj.getDirectoryPath();
                winopen(directoryPath);
            end
        end
        function directoryIsValid(obj)
            directoryPath = obj.getDirectoryPath();
            is = isfolder(directoryPath);
            if ~is
                obj.throwAlertMessage("Directory path is invalid!", "Open Directory");
            end
        end

        function throwAlertMessage(obj, message, title)
            fig = obj.getFigure();
            uialert(fig, message, title);
        end
    end

    methods (Access = private)
        function updateFilepather(obj)
            directory = obj.getDirectoryPath();
            pather = ImageFilepather(directory, obj.imageExtension);
            obj.filepather = pather;
        end
        function updateFilecount(obj)
            count = obj.getFilecount();
            obj.setFilecount(count);
        end
        function setFilecount(obj, count)
            elem = obj.getFilecountDisplay();
            label = num2str(count);
            set(elem, "Text", label);
        end
        
        function ta = getDirpathDisplay(obj)
            ta = obj.dirpathDisplay;
        end
        function lbl = getFilecountDisplay(obj)
            lbl = obj.filecountDisplay;
        end
        function fig = getFigure(obj)
            gl = obj.getGridLayout();
            fig = ancestor(gl, "figure");
        end
        function btn = getChooseButton(obj)
            btn = obj.chooseButton;
        end
    end
end

function is = directoryIsChosen(directoryPath)
is = directoryPath ~= 0;
end