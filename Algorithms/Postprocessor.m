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

        function direct(obj, varargin)
            obj.performOverResults(@directSingle, varargin{:});
        end
        function scale(obj, varargin)
            obj.performOverResults(@scaleSingle, varargin{:});
        end
        function shift(obj)
            obj.performOverResults(@shiftSingle);
        end
        function rotate(obj, varargin)
            obj.performOverResults(@rotateSingle, varargin{:});
        end
    end

    methods (Access = private)
        function performOverResults(obj, func, varargin)
            results = obj.results;
            parser = obj.parser;
            resultCount = parser.getRegionCount();
            processResult = @(index) func(results(index), parser, index, varargin{:});
            obj.results = arrayfun(processResult, 1:resultCount);
        end
    end
end



function postResult = instantiatePostResult(parser)
postResult = parser.getResult();
resultCount = parser.getRegionCount();

for index = 1:resultCount
    postResult(index).xProcessed = parser.getRawTraceX(index);
    postResult(index).yProcessed = parser.getRawTraceY(index);
    postResult(index).xProcessedError = parser.getRawTraceErrorX(index);
    postResult(index).yProcessedError = parser.getRawTraceErrorY(index);
end
end

function postResult = directSingle(result, parser, index, varargin)
p = inputParser;
addOptional(p, "PositiveDirection", parser.getPositiveDirection(index));
parse(p, varargin{:});
positiveDirection = p.Results.PositiveDirection;

[x, y, ~] = directXy( ...
    result.xProcessed, ...
    result.yProcessed, ...
    positiveDirection ...
    );

% update processed traces
postResult = result;
postResult.Direction = positiveDirection;
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

function postResult = scaleSingle(result, parser, ~, varargin)
p = inputParser;
addOptional(p, "Fps", parser.getFps());
addOptional(p, "ScaleFactor", parser.getScaleFactor());
addOptional(p, "ScaleFactorError", parser.getScaleFactorError());
parse(p, varargin{:});
scaleFactor = p.Results.ScaleFactor;
scaleError = p.Results.ScaleFactorError;
fps = p.Results.Fps;

scaleFactor = ErrorPropagator(scaleFactor, scaleError);
x = ErrorPropagator(result.xProcessed, result.xProcessedError);
y = ErrorPropagator(result.yProcessed, result.yProcessedError);
[x, y] = scaleXy(x, y, scaleFactor);

postResult = result;
% add information pertaining to scale factor
postResult.ScaleFactor = scaleFactor;
postResult.ScaleFactorError = scaleError;
postResult.Fps = fps;

% update processed traces
postResult.xProcessed = x.Value;
postResult.yProcessed = y.Value;
postResult.xProcessedError = x.Error;
postResult.yProcessedError = y.Error;
postResult.t = (1:n) / fps;
end
function [x, y] = scaleXy(x, y, scaleFactor)
xy = [x; y];
xyScaled = xy .* scaleFactor;
x = xyScaled(1, :);
y = xyScaled(2, :);
end

function postResult = shiftSingle(result, ~, ~)
x = ErrorPropagator(result.xProcessed, result.xProcessedError);
y = ErrorPropagator(result.yProcessed, result.yProcessedError);
[x, y] = shiftXy(x, y);

% update processed traces
postResult = result;
postResult.xProcessed = x.Value;
postResult.yProcessed = y.Value;
postResult.xProcessedError = x.Error;
postResult.yProcessedError = y.Error;
end
function [x, y] = shiftXy(x, y)
xy = [x; y];
xyShifted = xy - mean(xy, 2);
x = xyShifted(1, :);
y = xyShifted(2, :);
end

function postResult = rotateSingle(result, parser, index, varargin)
p = inputParser;
addOptional(p, "AngleMode", parser.getAngleMode(index));
addOptional(p, "PositiveDirection", parser.getPositiveDirection(index));
parse(p, varargin{:});
angleMode = p.Results.AngleMode;
positiveDirection = p.Results.PositiveDirection;

x = ErrorPropagator(result.xProcessed, result.xProcessedError);
y = ErrorPropagator(result.yProcessed, result.yProcessedError);

[x, y, angleDirection] = directXy(x, y, positiveDirection);
[angleRotate, angleError, angleInfo] = AngleAlgorithms.byKeyword(x.Value, y.Value, angleMode);
angleRotate = ErrorPropagator(angleRotate, angleError);
[x, y] = rotateXy(x, y, angleRotate);
angle = rerange(angleRotate + angleDirection);

postResult = result;
% add information pertaining to best-fit angle
postResult.Direction = positiveDirection;
postResult.AngleMode = angleMode;
postResult.angle = angle.Value;
postResult.angleError = angle.Error;
postResult.angleInfo = angleInfo;

% update processed traces
postResult.xProcessed = x.Value;
postResult.yProcessed = y.Value;
postResult.xProcessedError = x.Error;
postResult.yProcessedError = y.Error;
end
function [x, y] = rotateXy(x, y, angle)
[x, y] = TraceRotator.rotate2d(x, y, angle);
end

function angle = rerange(angle)
angle = mod(angle, 6.28319);
if angle > 3.14159
    angle = angle - 6.28319;
end
end
