classdef ProgressTracker < handle
    properties
        fileCount;
    end

    properties (Access = private)
        deltaUpdateTimeSeconds = 0.5;
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
        function updateIfNeeded(obj, index)
            timeSeconds = second(datetime);
            if obj.updateIsNeeded(timeSeconds)
                obj.update(index);
                obj.previousUpdateTimeSeconds = timeSeconds;
            end
        end
    end

    methods(Access = private)
        function is = updateIsNeeded(obj, timeSeconds)
            previousTime = obj.previousUpdateTimeSeconds;
            deltaTime = obj.deltaUpdateTimeSeconds;
            is = timeSeconds - previousTime > deltaTime;
        end
        function update(obj, index)
            total = obj.fileCount;
            message = obj.getMessage(index);
            proportionComplete = index / total;
            waitbar(proportionComplete, obj.progressBar, message);
        end
        function message = getMessage(obj, currentIndex)
            totalCount = obj.fileCount;
            message = sprintf( ...
                "Tracking Bundles: %d/%d", ...
                currentIndex, totalCount ...
                );
        end
    end
end