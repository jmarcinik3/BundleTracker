function convertToVideo(filepaths, videoFilepath, varargin)
taskName = 'Combining TIFs';

p = inputParser;
addOptional(p, "EveryNthFrame", 1);
addOptional(p, "FrameRate", 60);
parse(p, varargin{:});
everyNthFrame = p.Results.EveryNthFrame;
frameRate = p.Results.FrameRate;

frameCount = numel(filepaths);
frameNumbers = 1:everyNthFrame:frameCount;
frameNumberCount = numel(frameNumbers);

multiWaitbar(taskName, 0);
videoWriter = VideoWriter(videoFilepath, "Archival");
set(videoWriter, "FrameRate", frameRate);
open(videoWriter);

for index = frameNumbers
    im = imread(filepaths(index));
    writeVideo(videoWriter, im);
    proportionComplete = index / frameNumberCount;
    multiWaitbar(taskName, proportionComplete);
end

multiWaitbar(taskName, 'Close');
close(videoWriter);
end