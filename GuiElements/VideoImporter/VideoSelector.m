classdef VideoSelector < handle
    properties (Constant)
        importTitle = "&Import Video";
        openTitle = "&Open Directory";
    end
    properties (Access = private, Constant)
        extensions = { ...
            '*.mj2', "Motion JPEG 2000"; ...
            }; % compatible extensions to import video
    end

    properties (Access = private)
        gui;
    end

    methods
        function obj = VideoSelector(videoGui)
            filepathField = videoGui.getFilepathField();
            set(filepathField, "ValueChangedFcn", []);
            obj.gui = videoGui;
        end
    end

    %% Functions to retrieve state information
    methods (Access = protected)
        function im = getFirstFrame(obj)
            filepath = obj.gui.getFilepath();
            videoReader = VideoReader(filepath);
            im = readFrame(videoReader);
        end
    end
    methods (Access = private)
        function is = directoryIsValid(obj)
            directoryPath = obj.gui.getDirectoryPath();
            is = isfolder(directoryPath);
            if ~is
                title = VideoSelector.openTitle;
                obj.throwAlertMessage("Directory path is invalid!", title);
            end
        end
    end

    %% Functions to set state information
    methods
        function setFrameLabel(obj, text)
            elem = obj.gui.getFrameLabel();
            set(elem, "Text", text);
        end
        function setFilepathIfChosen(obj, filepath, source, event)
            if isfile(filepath)
                if nargin == 2
                    source = obj;
                    event = generateFakeEvent(obj);
                end
                obj.setVideoFilepath(filepath, source, event);
            end
        end
    end
    methods (Access = private)
        function setVideoFilepath(obj, filepath, source, event)
            filepathField = obj.gui.getFilepathField();
            set(filepathField, "Value", filepath);
            filepathField.ValueChangedFcn(source, event);
        end
    end

    %% Functions to update state information
    methods
        function importVideo(obj, source, event)
            previousDirectoryPath = obj.gui.getDirectoryPath();
            title = VideoSelector.importTitle;
            extensions = VideoSelector.extensions;
            filepath = uigetfilepath(extensions, title, previousDirectoryPath);
            obj.setFilepathIfChosen(filepath, source, event);
        end
        function openDirectory(obj, ~, ~)
            if obj.directoryIsValid()
                directoryPath = obj.gui.getDirectoryPath();
                winopen(directoryPath);
            end
        end
    end
    methods (Access = private)
        function throwAlertMessage(obj, message, title)
            fig = obj.gui.getFigure();
            uialert(fig, message, title);
        end
    end
end



function event = generateFakeEvent(source)
event = struct( ...
    "Source", source, ...
    "EventName", "FakeEvent" ...
    );
end
