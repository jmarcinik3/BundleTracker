classdef ProgressTracker < handle
    properties (Access = private, Constant)
        deltaUpdateTimeSeconds = 0.1;
    end

    properties (Access = private)
        totalCount;
        previousUpdateTimeSeconds = 0;
        continueProgress = true;
        progressBar;
        messageFormat = "Tracking Bundles: %d/%d";
    end

    methods
        function obj = ProgressTracker(totalCount)
            obj.progressBar = obj.generateProgressBar(totalCount);
        end
    end

    %% Functions to generate GUI elements
    methods
        function progressBar = generateProgressBar(obj, totalCount)
            obj.totalCount = totalCount;
            message = obj.getMessage(0);
            progressBar = waitbar( ...
                0, message, ...
                "CreateCancelBtn", @obj.cancelButtonPressed ...
                );
        end
    end

    %% Functions to update GUI elements
    methods
        function continueProgress = updateIfValid(obj, index)
            continueProgress = obj.continueProgress;
            if continueProgress
                obj.updateIfNeeded(index);
            end
        end
        function delete(obj)
            delete(obj.progressBar);
        end
    end
    methods (Access = private)
        function is = updateIsNeeded(obj, timeSeconds)
            previousTime = obj.previousUpdateTimeSeconds;
            deltaTime = obj.deltaUpdateTimeSeconds;
            is = timeSeconds - previousTime > deltaTime;
        end
        function updateIfNeeded(obj, index)
            timeSeconds = second(datetime);
            if obj.updateIsNeeded(timeSeconds)
                obj.update(index);
                obj.previousUpdateTimeSeconds = timeSeconds;
            end
        end
        function update(obj, index)
            total = obj.totalCount;
            message = obj.getMessage(index);
            proportionComplete = index / total;
            waitbar(proportionComplete, obj.progressBar, message);
        end
        function message = getMessage(obj, currentIndex)
            messageFormat = obj.messageFormat;
            totalCount = obj.totalCount;
            message = sprintf(messageFormat, currentIndex, totalCount);
        end

        function cancelButtonPressed(obj, ~, ~)
            obj.continueProgress = false;
        end
    end
end