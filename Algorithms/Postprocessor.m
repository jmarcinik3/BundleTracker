classdef Postprocessor < handle
    properties (Access = private)
        results;
    end

    methods
        function obj = Postprocessor(results)
            postResults = results;
            postResults.xProcessed = results.x;
            postResults.yProcessed = results.y;
            postResults.xProcessedError = results.xError;
            postResults.yProcessedError = results.yError;
            obj.results = postResults;
        end

        function reset(obj)
            % reset processed traces to redo postprocessing from raw traces
            obj.results.xProcessed = x;
            obj.results.yProcessed = y;
            obj.results.xProcessedError = xError;
            obj.results.yProcessedError = yError;
        end
        function process(obj)
            % shift first to reduce error and to rotate about mean
            obj.direct(); % set direction based on given diagonal
            obj.shift(); % center trace around zero by subtracting its mean
            obj.scale(); % scale traces nm/px and add time from FPS
            obj.rotate(); % rotate trace to direction of maximal movement
        end
        function results = getPostprocessedResults(obj)
            results = obj.results;
        end

        function direct(obj)
            results = obj.results;
            positiveDirection = results.Direction;

            % process trace direction based on given diagonal
            switch positiveDirection
                case DirectionGui.upperLeft
                    x = -results.xProcessed;
                    y = -results.yProcessed;
                case DirectionGui.upperRight
                    x = results.xProcessed;
                    y = -results.yProcessed;
                case DirectionGui.lowerLeft
                    x = -results.xProcessed;
                    y = results.yProcessed;
                case DirectionGui.lowerRight
                    x = results.xProcessed;
                    y = results.yProcessed;
            end

            % update processed traces
            postResults = results;
            postResults.xProcessed = x;
            postResults.yProcessed = y;
            obj.results = postResults;
        end
        function scale(obj)
            results = obj.results;

            % retrieve necessary data for scaling
            positionScale = results.ScaleFactor;
            scaleError = results.ScaleFactorError;
            scaleErrorFactor = (scaleError / positionScale) ^ 2;
            fps = results.Fps;

            x = results.xProcessed;
            y = results.yProcessed;
            xError = results.xProcessedError;
            yError = results.yProcessedError;

            % scale traces
            xScaled = positionScale * x;
            yScaled = positionScale * y;
            xScaledError = xScaled .* sqrt((xError./x).^2 + scaleErrorFactor);
            yScaledError = yScaled .* sqrt((yError./y).^2 + scaleErrorFactor);

            % update processed traces
            postResults = results;
            postResults.xProcessed = xScaled;
            postResults.yProcessed = yScaled;
            postResults.xProcessedError = xScaledError;
            postResults.yProcessedError = yScaledError;
            postResults.t = (1:numel(x)) / fps; % add time values
            obj.results = postResults;
        end
        function shift(obj)
            results = obj.results;

            % retrieve necessary data for shifting
            x = results.xProcessed;
            y = results.yProcessed;
            xErrorOld = results.xProcessedError;
            yErrorOld = results.yProcessedError;

            % tare traces to zero mean
            xsize = numel(x);
            xShifted = x - mean(x);
            yShifted = y - mean(y);
            xErrorFromMean = sqrt(sum(xErrorOld.^2)) / xsize;
            yErrorFromMean = sqrt(sum(yErrorOld.^2)) / xsize;
            xErrorTotal = sqrt(xErrorOld.^2 + xErrorFromMean^2);
            yErrorTotal = sqrt(yErrorOld.^2 + yErrorFromMean^2);

            % update processed traces
            postResults = results;
            postResults.xProcessed = xShifted;
            postResults.yProcessed = yShifted;
            postResults.xProcessedError = xErrorTotal;
            postResults.yProcessedError = yErrorTotal;
            obj.results = postResults;
        end
        function rotate(obj)
            results = obj.results;

            % retrieve necessary data for rotating
            angleMode = results.AngleMode;
            x = results.xProcessed;
            y = results.yProcessed;
            xError = results.xProcessedError;
            yError = results.yProcessedError;

            % find angle based on linear regression and rotate by it
            [angle, angleError, angleInfo] = AngleAlgorithms.byKeyword(x, y, angleMode);
            [xRotated, yRotated] = TraceRotator.rotate2d(x, y, angle);
            [xRotatedError, yRotatedError] = TraceRotator.rotate2dError( ...
                x, y, xError, yError, angle, angleError ...
                );

            postResults = results;
            % add information pertaining to best-fit angle
            postResults.angle = angle;
            postResults.angleError = angleError;
            postResults.angleInfo = angleInfo;

            % update processed traces
            postResults.xProcessed = xRotated;
            postResults.yProcessed = yRotated;
            postResults.xProcessedError = xRotatedError;
            postResults.yProcessedError = yRotatedError;
            obj.results = postResults;
        end
    end
end