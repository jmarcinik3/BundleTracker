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
            obj.orient(); % rotate trace such that +x is in the given direction
            obj.shift(); % center trace around zero by subtracting its mean
            obj.scale(); % scale traces nm/px and add time from FPS
            obj.rotate(); % rotate trace to direction of maximal movement
            obj.detrend(); % detrend trace to remove drift
        end
        function results = getPostprocessedResult(obj)
            results = obj.results;
        end

        function orient(obj, varargin)
            obj.performOverResults(@orientSingle, varargin{:});
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
        function detrend(obj, varargin)
            obj.performOverResults(@detrendSingle, varargin{:});
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
    postResult(index).angle = 0;
    postResult(index).angleError = 0;
end
end

function postResult = detrendSingle(result, parser, index, varargin)
p = inputParser;
addOptional(p, "DetrendMode", parser.getDetrendMode(index));
parse(p, varargin{:});
detrendMode = p.Results.DetrendMode;

[x, y, detrendInfo] = DetrendAlgorithms.byKeyword( ...
    result.xProcessed, ...
    result.yProcessed, ...
    detrendMode ...
    );

postResult = result;
% update processed traces
postResult.DetrendMode = detrendMode;
postResult.DetrendInfo = detrendInfo;
postResult.xProcessed = x;
postResult.yProcessed = y;
end

function postResult = orientSingle(result, parser, index, varargin)
p = inputParser;
addOptional(p, "PositiveDirection", parser.getPositiveDirection(index));
parse(p, varargin{:});
positiveDirection = p.Results.PositiveDirection;

[x, y, angle] = orientXy( ...
    result.xProcessed, ...
    result.yProcessed, ...
    positiveDirection ...
    );
newAngle = result.angle + angle;

% update processed traces
postResult = result;
postResult.angle = newAngle;
postResult.Direction = positiveDirection;
postResult.xProcessed = x;
postResult.yProcessed = y;
end
function [x, y, angle] = orientXy(x, y, positiveDirection)
angle = angleFromDirection(positiveDirection);
[x, y] = TraceRotator.rotate2d(x, -y, angle);
end
function angle = angleFromDirection(direction)
switch string(direction)
    case "Right"
        angle = 0;
    case "Upper Right"
        angle = 45;
    case "Upper"
        angle = 90;
    case "Upper Left"
        angle = 135;
    case "Left"
        angle = 180;
    case "Lower Left"
        angle = 225;
    case "Lower"
        angle = 270;
    case "Lower Right"
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

scaleWithError = ErrorPropagator(scaleFactor, scaleError);
x = ErrorPropagator(result.xProcessed, result.xProcessedError);
y = ErrorPropagator(result.yProcessed, result.yProcessedError);
[x, y] = scaleXy(x, y, scaleWithError);

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
postResult.t = (1:numel(x.Value)) / fps;
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
parse(p, varargin{:});
angleMode = p.Results.AngleMode;

x = ErrorPropagator(result.xProcessed, result.xProcessedError);
y = ErrorPropagator(result.yProcessed, result.yProcessedError);

[angle, angleError, angleInfo] = AngleAlgorithms.byKeyword(x.Value, y.Value, angleMode);
angle = ErrorPropagator(angle, angleError);
[x, y] = rotateXy(x, y, angle);
if ~strcmp(angleMode, "None")
    extraAngle = angleIfNoiseInX(x.Value, y.Value, angle.Value);
    [x, y] = rotateXy(x, y, extraAngle);
else
    extraAngle = 0;
end
newAngle = addAngle(result, angle + extraAngle);

postResult = result;
% add information pertaining to best-fit angle
postResult.AngleMode = angleMode;
postResult.angle = newAngle.Value;
postResult.angleError = newAngle.Error;
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



function newAngle = addAngle(result, angle)
oldAngle = ErrorPropagator(result.angle, result.angleError);
newAngle = wrapToPi(oldAngle + angle);
end
function extraAngle = angleIfNoiseInX(x, y, angle)
extraAngle = 0;
if std(x) < std(y)
    if angle <= 0
        extraAngle = pi/2;
    elseif angle > 0
        extraAngle = -pi/2;
    end
end
end
