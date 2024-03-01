classdef DirectorySelector < handle
    properties (Constant)
        chooseTitle = "Import Directory";
        openTitle = "Open Directory";
    end

    properties (Access = private)
        gui;
        filepather;
    end

    methods
        function obj = DirectorySelector(directoryGui, valueChangedFcn)
            directoryPathField = directoryGui.getDirectoryPathField();
            set(directoryPathField, "ValueChangedFcn", valueChangedFcn);
            obj.gui = directoryGui;
        end 
    end

    %% Functions to generate GUI elements
    methods (Access = private)
        function filepather = generateFilepather(obj)
            directoryPath = obj.gui.getDirectoryPath();
            filepather = ImageFilepather(directoryPath);
        end
    end

    %% Functions to retrieve state information
    methods
        function im = getFirstImage(obj)
            if obj.directoryHasImage()
                filepath = obj.getFirstFilepath();
                im = imread(filepath);
            else
                im = [];
            end
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
            directoryPath = obj.gui.getDirectoryPath();
            is = directoryIsValid(directoryPath);
            if ~is
                title = DirectorySelector.openTitle;
                obj.throwAlertMessage("Directory path is invalid!", title);
            end
        end
        function has = directoryHasImage(obj)
            count = obj.getFilecount();
            directory = obj.gui.getDirectoryPath();
            has = count >= 1 && isfolder(directory);
            if ~has
                title = DirectorySelector.chooseTitle;
                obj.throwAlertMessage("No valid images found!", title);
            end
        end
    end

    %% Functions to set state information
    methods
        function setDirectory(obj, directoryPath, source, event)
            directoryPathField = obj.gui.getDirectoryPathField();
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
    end
    methods (Access = private)
        function setDirectoryIfChosen(obj, directoryPath, source, event)
            if directoryIsChosen(directoryPath)
                obj.setDirectory(directoryPath, source, event);
            end
        end
        function setFilecount(obj, count)
            elem = obj.gui.getFilecountField();
            label = sprintf("%d Frames", count);
            set(elem, "Text", label);
        end
    end
    
    %% Functions to update state information
    methods
        function chooseDirectory(obj, source, event)
            previousDirectoryPath = obj.gui.getDirectoryPath();
            title = DirectorySelector.chooseTitle;
            directoryPath = uigetdir(previousDirectoryPath, title);
            obj.setDirectoryIfChosen(directoryPath, source, event);
        end
        function openDirectory(obj, ~, ~)
            if obj.directoryIsValid()
                directoryPath = obj.gui.getDirectoryPath();
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
            fig = obj.gui.getFigure();
            uialert(fig, message, title);
        end
    end
end



function is = directoryIsChosen(directoryPath)
is = directoryPath ~= 0;
end

function is = directoryIsValid(directoryPath)
is = isfolder(directoryPath);
end
