classdef VideoSelector < AlertThrower
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
    methods (Access = private)
        function is = directoryIsValid(obj)
            directoryPath = obj.gui.getDirectoryPath();
            is = isfolder(directoryPath);
            if ~is
                title = SettingsParser.getOpenDirectoryLabel();
                obj.throwAlertMessage("Directory path is invalid!", title);
            end
        end
    end

    %% Functions to set state information
    methods
        function importVideo(obj, filepath, source, event)
            if isfile(filepath)
                if nargin == 2
                    source = obj;
                    event = generateFakeEvent(obj);
                end
                filepathField = obj.gui.getFilepathField();
                set(filepathField, "Value", filepath);
                filepathField.ValueChangedFcn(source, event);
            end
        end
    end
    methods (Access = protected)
        function setFrameLabel(obj, text)
            elem = obj.gui.getFrameLabel();
            set(elem, "Text", text);
        end
    end

    %% Functions to update state information
    methods
        function importVideoButtonPushed(obj, source, event)
            previousDirectoryPath = obj.gui.getDirectoryPath();
            title = SettingsParser.getImportVideoLabel();
            extensions = VideoSelector.extensions;
            filepath = uigetfilepath(extensions, title, previousDirectoryPath);
            obj.importVideo(filepath, source, event);
        end
        function openDirectory(obj, ~, ~)
            if obj.directoryIsValid()
                directoryPath = obj.gui.getDirectoryPath();
                winopen(directoryPath);
            end
        end
    end
    methods (Access = protected)
        function fig = getFigure(obj)
            fig = obj.gui.getFigure();
        end
    end
end



function event = generateFakeEvent(source)
event = struct( ...
    "Source", source, ...
    "EventName", "FakeEvent" ...
    );
end
