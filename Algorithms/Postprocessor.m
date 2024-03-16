classdef Postprocessor < handle
    properties (Access = private)
        result;
        parser;
    end

    methods
        function obj = Postprocessor(result)
            postResult = result;
            postResult.xProcessed = result.x;
            postResult.yProcessed = result.y;
            postResult.xProcessedError = result.xError;
            postResult.yProcessedError = result.yError;

            obj.parser = ResultsParser(result);
            obj.result = postResult;
        end

        function reset(obj)
            % reset processed traces to redo postprocessing from raw traces
            obj.result.xProcessed = x;
            obj.result.yProcessed = y;
            obj.result.xProcessedError = xError;
            obj.result.yProcessedError = yError;
        end
        function process(obj)
            % shift first to reduce error and to rotate about mean
            obj.direct(); % set direction based on given diagonal
            obj.shift(); % center trace around zero by subtracting its mean
            obj.scale(); % scale traces nm/px and add time from FPS
            obj.rotate(); % rotate trace to direction of maximal movement
        end
        function results = getPostprocessedResult(obj)
            results = obj.result;
        end

        function direct(obj)
            result = obj.result;
            parser = obj.parser;
            positiveDirection = parser.getPositiveDirection();

            % process trace direction based on given diagonal
            switch positiveDirection
                case DirectionGui.upperLeft
                    x = -result.xProcessed;
                    y = -result.yProcessed;
                case DirectionGui.upperRight
                    x = result.xProcessed;
                    y = -result.yProcessed;
                case DirectionGui.lowerLeft
                    x = -result.xProcessed;
                    y = result.yProcessed;
                case DirectionGui.lowerRight
                    x = result.xProcessed;
                    y = result.yProcessed;
            end

            % update processed traces
            postResult = result;
            postResult.xProcessed = x;
            postResult.yProcessed = y;
            obj.result = postResult;
        end
        function scale(obj)
            result = obj.result;
            parser = obj.parser;

            % retrieve necessary data for scaling
            positionScale = parser.getScaleFactor();
            scaleError = parser.getScaleFactorError();
            fps = parser.getFps();
            scaleErrorFactor = (scaleError / positionScale) ^ 2;

            x = result.xProcessed;
            y = result.yProcessed;
            xError = result.xProcessedError;
            yError = result.yProcessedError;

            % scale traces
            xScaled = positionScale * x;
            yScaled = positionScale * y;
            xScaledError = xScaled .* sqrt((xError./x).^2 + scaleErrorFactor);
            yScaledError = yScaled .* sqrt((yError./y).^2 + scaleErrorFactor);

            % update processed traces
            postResult = result;
            postResult.xProcessed = xScaled;
            postResult.yProcessed = yScaled;
            postResult.xProcessedError = xScaledError;
            postResult.yProcessedError = yScaledError;
            postResult.t = (1:numel(x)) / fps; % add time values
            obj.result = postResult;
        end
        function shift(obj)
            result = obj.result;

            % retrieve necessary data for shifting
            x = result.xProcessed;
            y = result.yProcessed;
            xErrorOld = result.xProcessedError;
            yErrorOld = result.yProcessedError;

            % tare traces to zero mean
            xsize = numel(x);
            xShifted = x - mean(x);
            yShifted = y - mean(y);
            xErrorFromMean = sqrt(sum(xErrorOld.^2)) / xsize;
            yErrorFromMean = sqrt(sum(yErrorOld.^2)) / xsize;
            xErrorTotal = sqrt(xErrorOld.^2 + xErrorFromMean^2);
            yErrorTotal = sqrt(yErrorOld.^2 + yErrorFromMean^2);

            % update processed traces
            postResult = result;
            postResult.xProcessed = xShifted;
            postResult.yProcessed = yShifted;
            postResult.xProcessedError = xErrorTotal;
            postResult.yProcessedError = yErrorTotal;
            obj.result = postResult;
        end
        function rotate(obj)
            result = obj.result;
            parser = obj.parser;

            % retrieve necessary data for rotating
            angleMode = parser.getAngleMode();
            x = result.xProcessed;
            y = result.yProcessed;
            xError = result.xProcessedError;
            yError = result.yProcessedError;

            % find angle based on linear regression and rotate by it
            [angle, angleError, angleInfo] = AngleAlgorithms.byKeyword(x, y, angleMode);
            [xRotated, yRotated] = TraceRotator.rotate2d(x, y, angle);
            [xRotatedError, yRotatedError] = TraceRotator.rotate2dError( ...
                x, y, xError, yError, angle, angleError ...
                );

            postResult = result;
            % add information pertaining to best-fit angle
            postResult.angle = angle;
            postResult.angleError = angleError;
            postResult.angleInfo = angleInfo;

            % update processed traces
            postResult.xProcessed = xRotated;
            postResult.yProcessed = yRotated;
            postResult.xProcessedError = xRotatedError;
            postResult.yProcessedError = yRotatedError;
            obj.result = postResult;
        end
    end
end