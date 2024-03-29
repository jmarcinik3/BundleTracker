classdef Postprocessor < handle
    properties (Access = private)
        results;
        parser;
    end

    methods
        function obj = Postprocessor(result)
            parser = ResultsParser(result);
            obj.results = instantiatePostResult(parser);
            obj.parser = parser;
        end

        function reset(obj)
            % reset processed traces to redo postprocessing from raw traces
            obj.results = instantiatePostResult(obj.parser);
        end
        function process(obj)
            % shift first to reduce error and to rotate about mean
            obj.direct(); % set direction based on given diagonal
            obj.shift(); % center trace around zero by subtracting its mean
            obj.scale(); % scale traces nm/px and add time from FPS
            obj.rotate(); % rotate trace to direction of maximal movement
        end
        function results = getPostprocessedResult(obj)
            results = obj.results;
        end

        function direct(obj)
            obj.performOverResults(@directSingle);
        end
        function scale(obj)
            obj.performOverResults(@scaleSingle);
        end
        function shift(obj)
            obj.performOverResults(@shiftSingle);
        end
        function rotate(obj)
            obj.performOverResults(@rotateSingle);
        end
    end

    methods (Access = private)
        function performOverResults(obj, func)
            results = obj.results;
            parser = obj.parser;
            resultCount = parser.getRegionCount();

            for index = 1:resultCount
                preResult = results(index);
                postResult = func(preResult, parser, index);
                obj.results(index) = postResult;
            end
        end
    end
end



function postResult = instantiatePostResult(parser)
postResult = parser.results;
resultCount = parser.getRegionCount();

for index = 1:resultCount
    postResult(index).xProcessed = parser.getRawTraceX(index);
    postResult(index).yProcessed = parser.getRawTraceY(index);
    postResult(index).xProcessedError = parser.getRawTraceErrorX(index);
    postResult(index).yProcessedError = parser.getRawTraceErrorY(index);
end
end

function postResult = directSingle(result, parser, index)
positiveDirection = parser.getPositiveDirection(index);
disp(positiveDirection);
% process trace direction based on given diagonal
switch positiveDirection
    case DirectionGui.upperLeft
        x = -result.yProcessed;
        y = -result.xProcessed;
    case DirectionGui.upperRight
        x = result.xProcessed;
        y = -result.yProcessed;
    case DirectionGui.lowerLeft
        x = -result.xProcessed;
        y = result.yProcessed;
    case DirectionGui.lowerRight
        x = result.yProcessed;
        y = result.xProcessed;
end

% update processed traces
postResult = result;
postResult.xProcessed = x;
postResult.yProcessed = y;
end

function postResult = scaleSingle(result, parser, ~)
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
end

function postResult = shiftSingle(result, ~, ~)
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
end

function postResult = rotateSingle(result, parser, index)
% retrieve necessary data for rotating
angleMode = parser.getAngleMode(index);
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
end
