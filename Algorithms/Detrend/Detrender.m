classdef Detrender < handle
    properties (Access = private)
        t;
        x;

        xDetrended;
        xPoly = [];
        polyPower = 0;
        xMovingAverage = [];
        windowSize = 0;
        detrendInfo = struct();

        polynomialIncrease;
        windowCycleCount;
        windowThreshold;
    end

    methods
        function obj = Detrender(t, x, varargin)
            p = inputParser;
            addOptional(p, "PolynomialIncrease", 0.01);
            addOptional(p, "WindowCycleCount", 2);
            addOptional(p, "WindowThreshold", 0.95);
            parse(p, varargin{:});
            obj.polynomialIncrease = p.Results.PolynomialIncrease;
            obj.windowCycleCount = p.Results.WindowCycleCount;
            obj.windowThreshold = p.Results.WindowThreshold;

            obj.t = t;
            obj.x = x;
            obj.xDetrended = x;
        end
    end

    %% Functions to retrieve information
    methods
        function x = getDetrended(obj)
            x = obj.xDetrended;
        end
        function info = getInfo(obj)
            info = obj.detrendInfo;
        end

        function x = getMovingAverage(obj)
            x = obj.xMovingAverage;
        end
        function x = getPolynomial(obj)
            x = obj.xPoly;
        end
        function x = getPolynomialDegree(obj)
            x = obj.polyPower;
        end
        function x = getWindowSize(obj)
            x = obj.windowSize;
        end
    end

    %% Functions to perform detrending
    methods
        function obj = detrend(obj)
            obj.byPolynomial();
            obj.byMovingAverage();
        end

        function obj = byMovingAverage(obj)
            threshold = obj.windowThreshold;
            cycleCount = obj.windowCycleCount;
            x = obj.xDetrended;

            windowSize = determineWindowSize(x, cycleCount, threshold);
            xAvg = MovingAverage.averageByKeyword(x, windowSize, "Hann");

            obj.xDetrended = x - xAvg;
            obj.xMovingAverage = xAvg;
            obj.windowSize = windowSize;

            detrendInfo = struct( ...
                "WindowMinCycles", cycleCount, ...
                "WindowShape", "Hann", ...
                "WindowSize", windowSize, ...
                "WindowThreshold", threshold ...
                );
            obj.detrendInfo = table2struct([ ...
                struct2table(obj.detrendInfo), ...
                struct2table(detrendInfo) ...
                ]);
        end
        function obj = byPolynomial(obj)
            factor = obj.polynomialIncrease;
            t = obj.t;
            x = obj.xDetrended;

            warning("off");
            polyPower = determinePolyPower(t, x, factor);
            xPolyFit = polyfit(t, x, polyPower);
            xPoly = polyval(xPolyFit, t);
            warning("on");

            obj.xDetrended = x - xPoly;
            obj.xPoly = xPoly;
            obj.polyPower = polyPower;

            detrendInfo = struct( ...
                "PolynomialIncrease", factor, ...
                "PolynomialPower", polyPower ...
                );
            obj.detrendInfo = table2struct([ ...
                struct2table(obj.detrendInfo), ...
                struct2table(detrendInfo) ...
                ]);
        end
    end
end



function [polyPower, proportions] = determinePolyPower(x, y, increaseFactor)
polyPower = 0;
[newProportion, yPoly] = calculatePolyRangeProportion(x, y, polyPower);
proportions = newProportion;

while doNextPoly(newProportion, increaseFactor)
    polyPower = polyPower + 1;
    y = y - yPoly;
    [newProportion, yPoly] = calculatePolyRangeProportion(x, y, polyPower);
    proportions = [proportions, newProportion]; %#ok<AGROW>
end

polyPower = polyPower - 1;
end
function do = doNextPoly(newProportion, increaseFactor)
do = newProportion <= (1 + increaseFactor);
end

function [proportion, yPoly] = calculatePolyRangeProportion(x, y, n)
yPolyCoefficients = polyfit(x, y, n);
yPoly = polyval(yPolyCoefficients, x);
proportion = proportionFunction(y, yPoly);
end
function proportion = proportionFunction(x, xDrift)
dx = x - xDrift;
xRange = rangeFunction(x);
dxRange = rangeFunction(dx);
proportion = dxRange / xRange;
end
function xRange = rangeFunction(x)
xRange = max(x) - min(x);
end



function windowSize = determineWindowSize(x, minCycleCount, threshold)
xLength = numel(x);
xHalfLength = round(0.5 * xLength);

xFft = abs(fft(x));
xFft = xFft(1:xHalfLength);
xFft = cumsum(xFft);
xFft = xFft / xFft(xHalfLength);

cycleThreshold = find(xFft >= threshold, 1, "first");
periodThreshold = round(minCycleCount * cycleThreshold);
windowSize = round(min(periodThreshold, 2*xLength));
end
