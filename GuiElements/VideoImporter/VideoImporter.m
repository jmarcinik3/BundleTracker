classdef VideoImporter < handle
    properties (Access = private)
        ims = []; % stored 3D matrix of grayscale video
        firstFrame = [];
        fps = 0;
        videoReader;
        isImporting = false;
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
        function im = getFirstFrame(obj)
            im = obj.firstFrame;
        end
        function fps = getFps(obj)
            fps = obj.fps;
        end
        function is = videoIsImported(obj)
            is = ~obj.isImporting;
        end
    end

    %% Functions to set state information
    methods (Access = protected)
        function importVideoToRam(obj, videoReader)
            obj.isImporting = true;
            obj.ims = [];
            obj.fps = get(videoReader, "FrameRate");
            obj.firstFrame = read(videoReader, 1);
            obj.ims = readVideo(videoReader);
            obj.isImporting = false;
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
imageClass = class(read(videoReader, 1));
ims = zeros(h, w, frameCount, imageClass);
end
