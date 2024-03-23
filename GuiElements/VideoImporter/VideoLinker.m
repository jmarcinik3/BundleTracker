classdef VideoLinker < VideoImporter & VideoSelector
    properties (Access = private)
        gui;
    end

    methods
        function obj = VideoLinker(videoGui)
            obj@VideoImporter([]);
            obj@VideoSelector(videoGui);

            set(videoGui.getFilepathField(), "ValueChangedFcn", @obj.videoFilepathChanged);
            obj.gui = videoGui;
        end
    end

    %% Functions to retrieve state information
    methods (Access = protected)
        function filepath = getFilepath(obj)
            filepath = obj.gui.getFilepath();
        end
    end

    %% Functions to update state of GUI
    methods
        function videoFilepathChanged(obj, ~, ~)
            filepath = obj.getFilepath();
            updateDisplayFrame(obj);
            obj.setFilepath(filepath); % must come before updating frame label
            updateFrameLabel(obj);
        end
    end
end



function updateFrameLabel(obj)
label = generateFrameLabel(obj);
obj.setFrameLabel(label);
end

function label = generateFrameLabel(obj)
frameCount = obj.getFrameCount();
fps = obj.getFps();
label = sprintf("%d Frames (%d FPS)", frameCount, fps);
end

function updateDisplayFrame(obj)
firstFrame = obj.getFirstFrame();
obj.changeFullImage(firstFrame);
end
