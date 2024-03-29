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

            obj.results = arrayfun( ...
                @(index) func(results(index), parser, index), ...
                1:resultCount ...
                );
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
[x, y, ~] = directXy( ...
    result.xProcessed, ...
    result.yProcessed, ...
    positiveDirection ...
    );

% update processed traces
postResult = result;
postResult.xProcessed = x;
postResult.yProcessed = y;
end
function [x, y, angle] = directXy(x, y, positiveDirection)
angle = angleFromDirection(positiveDirection);
[x, y] = TraceRotator.rotate2d(x, -y, angle);
end
function angle = angleFromDirection(direction)
switch direction
    case DirectionGui.tags(2, 3) % right
        angle = 0;
    case DirectionGui.tags(1, 3) % upper right
        angle = 45;
    case DirectionGui.tags(1, 2) % upper
        angle = 90;
    case DirectionGui.tags(1, 1) % upper left
        angle = 135;
    case DirectionGui.tags(2, 1) % left
        angle = 180;
    case DirectionGui.tags(3, 1) % lower left
        angle = 225;
    case DirectionGui.tags(3, 2) % lower
        angle = 270;
    case DirectionGui.tags(3, 3) % lower right
        angle = 315;
end
angle = deg2rad(angle);
end

function postResult = scaleSingle(result, parser, ~)
scaleFactor = parser.getScaleFactor();
scaleError = parser.getScaleFactorError();
fps = parser.getFps();

[x, y, xError, yError] = scaleXy( ...
    result.xProcessed, ...
    result.yProcessed, ...
    result.xProcessedError, ...
    result.yProcessedError, ...
    scaleFactor, ...
    scaleError ...
    );

% update processed traces
postResult = result;
postResult.xProcessed = x;
postResult.yProcessed = y;
postResult.xProcessedError = xError;
postResult.yProcessedError = yError;
postResult.t = scaleTime(fps, x);
end
function [x, y, xerr, yerr] = scaleXy(x, y, xerr, yerr, scaleFactor, scaleError)
scaleErrorFactor = (scaleError / scaleFactor) ^ 2;
x = scaleFactor * x;
y = scaleFactor * y;
xerr = x .* sqrt((xerr./x).^2 + scaleErrorFactor);
yerr = y .* sqrt((yerr./y).^2 + scaleErrorFactor);
end
function t = scaleTime(fps, x)
t = (1:numel(x)) / fps;
end

function postResult = shiftSingle(result, ~, ~)
[x, y, xError, yError] = shiftXy( ...
    result.xProcessed, ...
    result.yProcessed, ...
    result.xProcessedError, ...
    result.yProcessedError ...
    );

% update processed traces
postResult = result;
postResult.xProcessed = x;
postResult.yProcessed = y;
postResult.xProcessedError = xError;
postResult.yProcessedError = yError;
end
function [x, y, xerr, yerr] = shiftXy(x, y, xerr, yerr)
xsize = numel(x);
x = x - mean(x);
y = y - mean(y);
xErrorFromMean = sqrt(sum(xerr.^2)) / xsize;
yErrorFromMean = sqrt(sum(yerr.^2)) / xsize;
xerr = sqrt(xerr.^2 + xErrorFromMean^2);
yerr = sqrt(yerr.^2 + yErrorFromMean^2);
end

function postResult = rotateSingle(result, parser, index)
angleMode = parser.getAngleMode(index);
positiveDirection = parser.getPositiveDirection(index);
x = result.xProcessed;
y = result.yProcessed;

[x, y, angleDirection] = directXy(x, y, positiveDirection);
[angleRotate, angleError, angleInfo] = AngleAlgorithms.byKeyword(x, y, angleMode);
[x, y, xError, yError] = rotateXy( ...
    x, ...
    y, ...
    result.xProcessedError, ...
    result.yProcessedError, ...
    angleRotate, angleError ...
    );
angle = rerange(angleRotate + angleDirection);

postResult = result;
% add information pertaining to best-fit angle
postResult.angle = angle;
postResult.angleError = angleError;
postResult.angleInfo = angleInfo;

% update processed traces
postResult.xProcessed = x;
postResult.yProcessed = y;
postResult.xProcessedError = xError;
postResult.yProcessedError = yError;
end
function [xrot, yrot, xroterr, yroterr] = rotateXy(x, y, xerr, yerr, angle, angleError)
[xrot, yrot] = TraceRotator.rotate2d(x, y, angle);
[xroterr, yroterr] = TraceRotator.rotate2dError( ...
    x, y, ...
    xerr, yerr, ...
    angle, angleError ...
    );
end

function angle = rerange(angle)
angle = mod(angle, 6.28319);
if angle > 3.14159
    angle = angle - 6.28319;
end
end
