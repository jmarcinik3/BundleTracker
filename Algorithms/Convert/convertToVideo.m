function convertToVideo(filepaths, videoFilepath, varargin)
frameCount = numel(filepaths);
progress = ProgressBar(frameCount, "Combining TIFs");
videoWriter = VideoWriter(videoFilepath, "Archival");
set(videoWriter, varargin{:});
open(videoWriter);

for index = 1:frameCount
    im = imread(filepaths(index));
    writeVideo(videoWriter, im);
    count(progress);
end

close(videoWriter);
end