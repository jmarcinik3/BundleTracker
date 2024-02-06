classdef ProgressTracker < handle
    properties (Access = public)
        fileCount;
    end

    properties (Access = private)
        deltaUpdateTimeSeconds = 0.1;
        previousUpdateTimeSeconds = 0;
        progressBar;
    end

    methods
        function obj = ProgressTracker(fileCount)
            obj.fileCount = fileCount;
            message = obj.getMessage(0);
            obj.progressBar = waitbar(0, message);
        end

        function delete(obj)
            delete(obj.progressBar);
        end

        function update(obj, index)
            timeSeconds = second(datetime);

            if (timeSeconds - obj.previousUpdateTimeSeconds > obj.deltaUpdateTimeSeconds)
                total = obj.fileCount;
                message = obj.getMessage(index);
                waitbar(index / total, obj.progressBar, message);
                obj.previousUpdateTimeSeconds = timeSeconds;
            end
        end
    end

    methods (Access = private)
        function message = getMessage(obj, currentIndex)
            message = sprintf( ...
                "Tracking Bundles: %d/%d", ...
                currentIndex, ...
                obj.fileCount ...
                );
        end
    end
end