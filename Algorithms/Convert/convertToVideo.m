function convertToVideo(filepaths, videoFilepath, varargin)
p = inputParser;
addOptional(p, "EveryNthFrame", 1);
addOptional(p, "FrameRate", 60);
parse(p, varargin{:});
everyNthFrame = p.Results.EveryNthFrame;
frameRate = p.Results.FrameRate;

frameCount = numel(filepaths);
frameNumbers = 1:everyNthFrame:frameCount;
progress = ProgressBar(numel(frameNumbers), "Combining TIFs");
videoWriter = VideoWriter(videoFilepath, "Archival");
set(videoWriter, "FrameRate", frameRate);
open(videoWriter);

for index = frameNumbers
    im = imread(filepaths(index));
    writeVideo(videoWriter, im);
    count(progress);
end

close(videoWriter);
end