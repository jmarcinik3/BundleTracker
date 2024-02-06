classdef DirectorySelector < handle
    properties
        figure;
        gridLayout;
        filepathDisplay;
        filecountDisplay;
        chooseButton;
        openButton
    end

    methods
        function obj = DirectorySelector(parent, figure)
            obj.figure = figure;

            gl = uigridlayout(parent, [1 4]);
            filepathDisplay = uieditfield(gl);
            filecountDisplay = uilabel(gl);
            chooseButton = uibutton(gl);
            openButton = uibutton(gl);

            filepathDisplay.Enable = false;
            filecountDisplay.Text = num2str(0);
            chooseButton.Text = "Choose";
            chooseButton.ButtonPushedFcn = @(src, ev) obj.chooseButtonPushed(src, ev);
            openButton.Text = "Open";
            openButton.ButtonPushedFcn = @(src, ev) obj.openButtonPushed();

            filepathDisplay.Layout.Column = 1;
            chooseButton.Layout.Column = 3;
            openButton.Layout.Column = 4;
            gl.Padding = [0 0 0 0];

            obj.filepathDisplay = filepathDisplay;
            obj.filecountDisplay = filecountDisplay;
            obj.chooseButton = chooseButton;
            obj.openButton = openButton;
            obj.gridLayout = gl;
        end

        function setDirectory(obj, directoryPath)
            tb = obj.getFilepathDisplay();
            tb.Value = directoryPath;
        end

        function setFilecount(obj, count)
            lbl = obj.getFilecountDisplay();
            lbl.Text = num2str(count);
        end

        function text = getDirectory(obj)
            ta = obj.getFilepathDisplay();
            text = ta.Value;
        end

        function ta = getFilepathDisplay(obj)
            ta = obj.filepathDisplay;
        end
    end

    methods (Access = private)
        function chooseButtonPushed(obj, src, ev)
            previousDirectoryPath = obj.getDirectory();
            directoryPath = uigetdir(previousDirectoryPath);

            if directoryPath ~= 0
                ta = obj.getFilepathDisplay();
                obj.setDirectory(directoryPath);
                ta.ValueChangedFcn(src, ev);
            end
        end

        function openButtonPushed(obj)
            directoryPath = obj.getDirectory();
            if isfolder(directoryPath)
                winopen(directoryPath);
            else
                uialert(obj.figure, "Directory path is invalid!", "Open Directory")
            end
        end



        function lbl = getFilecountDisplay(obj)
            lbl = obj.filecountDisplay;
        end
    end
end