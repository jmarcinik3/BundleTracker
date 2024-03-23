classdef VideoImporter < handle
    properties (Access = protected)
        ims; % stored 3D matrix of grayscale video (uint16)
    end
    properties (Access = private)
        filepath; % video filepath
        videoReader; % object to read video
    end

    methods
        function obj = VideoImporter(filepath)
            obj.setFilepath(filepath);
        end
    end

    %% Functions to retrieve state information
    methods
        function ims = getVideoInRegion(obj, region)
            im1 = obj.ims(:, :, 1);
            [rowsSlice, columnsSlice] = MatrixUnpadder.slicesByRegion(region, im1);
            ims = obj.ims(rowsSlice, columnsSlice, :);
        end
    end
    methods (Access = protected)
        function im = getFrameInRegion(obj, frameNumber, region)
            im1 = obj.ims(:, :, 1);
            [rowsSlice, columnsSlice] = MatrixUnpadder.slicesByRegion(region, im1);
            im = obj.ims(rowsSlice, columnsSlice, frameNumber);
        end

        function fps = getFps(obj)
            fps = get(obj.videoReader, "FrameRate");
        end
        function frameCount = getFrameCount(obj)
            frameCount = get(obj.videoReader, "NumFrames");
        end
        function filepath = getFilepath(obj)
            filepath = obj.filepath;
        end
    end

    %% Functions to set state information
    methods (Access = protected)
        function setFilepath(obj, filepath)
            obj.filepath = filepath;
            obj.ims = [];
            if numel(filepath) >= 1 && isfile(filepath)
                videoReader = VideoReader(obj.filepath);
                obj.videoReader = videoReader;
                obj.ims = readVideo(videoReader);
            end
        end
    end
end



function ims = readVideo(videoReader)
taskName = 'Importing Frames';

multiWaitbar(taskName, 0);
frameCount = get(videoReader, "NumFrames");
ims = preallocateVideo(videoReader);

for index = 1:frameCount
    ims(:, :, index) = read(videoReader, index);
    proportionComplete = index / frameCount;
    multiWaitbar(taskName, proportionComplete);
end

multiWaitbar(taskName, 'Close');
end

function ims = preallocateVideo(videoReader)
w = get(videoReader, "Width");
h = get(videoReader, "Height");
frameCount = get(videoReader, "NumFrames");
ims = zeros(h, w, frameCount, "uint16");
end
