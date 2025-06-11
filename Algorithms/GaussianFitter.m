classdef GaussianFitter < handle
    properties (Access = private)
        im;
        parameters;
        parameterErrors;
        fitPerformed = false;
    end

    methods
        function obj = GaussianFitter(im)
            obj.im = im;
        end

        function center = withError(obj)
            obj.performFit();
            [xy, xyError] = obj.getCenter();
            center = PointStructurer.asPoint(xy(1), xy(2), xyError(1), xyError(2));
        end
        function [angle, angleError, angleInfo] = angleWithError(obj)
            obj.performFit();
            [angle, angleError] = obj.getAngleRadians();
            angleInfo = obj.getMetadata();
        end
    end

    methods (Access = private)
        function performFit(obj)
            if obj.fitPerformed
                return;
            end

            im = obj.im;
            [rows, columns] = size(im);
            x = ones(rows, 1) * (1:columns); % 2D matrix of x indices
            y = (1:rows)' * ones(1, columns); % 2D matrix of y indices
            [obj.parameters, obj.parameterErrors] = fmgaussfit(x, y, im);

            obj.fitPerformed = true;
        end
    end

    %% Functions to retrieve parameter fit values
    methods
        function parameters = getParameters(obj)
            parameters = obj.parameters;
        end
        function metadata = getMetadata(obj)
            [amplitude, amplitudeError] = getAmplitude(obj);
            [angleRadians, angleRadiansError] = getAngleRadians(obj);
            [xyStd, xyStdError] = getStandardDeviation(obj);
            [xy, xyError] = getCenter(obj);
            metadata = struct( ...
                "Amplitude", amplitude, ...
                "AmplitudeError", amplitudeError, ...
                "Center", xy, ...
                "CenterError", xyError, ...
                "RotationAngle", angleRadians, ...
                "RotationAngleError", angleRadiansError, ...
                "StandardDeviation", xyStd, ...
                "StandardDeviationError", xyStdError, ...
                "Parameters", obj.parameters ...
                );
        end

        function [amplitude, amplitudeError] = getAmplitude(obj)
            amplitude = obj.parameters(1);
            amplitudeError = obj.parameterErrors(1);
        end
        function [angleRadians, angleRadiansError] = getAngleRadians(obj)
            angleRadians = wrapToPi(pi/2 - obj.parameters(2));
            angleRadiansError = obj.parameterErrors(2);
        end
        function [xyStd, xyStdError] = getStandardDeviation(obj)
            xyStd = obj.parameters(3:4);
            xyStdError = obj.parameterErrors(3:4);
        end
        function [xy, xyError] = getCenter(obj)
            xy = obj.parameters(5:6);
            xyError = obj.parameterErrors(5:6);
        end
    end
end



function [fitParameters, fitParameterErrors] = fmgaussfit(xInput, yInput, zzInput)

%% Condition the data
[xData, yData, zData] = prepareSurfaceData(xInput, yInput, zzInput);
xyData = {xData, yData};

%% Set up the startpoint
amplitudeGuess = 1;
angleRadiansGuess = pi / 2; % angle in radians
xStdGuess = 1;
yStdGuess = 1;

xLowerBound = min(xData) - 1;
yLowerBound = min(yData) - 1;
xUpperBound = max(xData) + 1;
yUpperBound = max(yData) + 1;
xGuess = (xLowerBound + xUpperBound) / 2;
yGuess = (yLowerBound + yUpperBound) / 2;
zGuess = median(zData(:));

%% Set up fittype and options.
LowerBound = [0, 0, 0, 0, xLowerBound, yLowerBound, 0];
UpperBound = [Inf, pi, Inf, Inf, xUpperBound, yUpperBound, Inf]; % angles greater than 90deg are redundant
StartPoint = [amplitudeGuess, angleRadiansGuess, xStdGuess, yStdGuess, xGuess, yGuess, zGuess];

tols = 1e-14;
options = optimset( ...
    "Algorithm", "levenberg-marquardt", ...
    "Display", "off", ...
    "MaxFunEvals", 5e2, ...
    "MaxIter", 5e2, ...
    "TolX", tols, ...
    "TolFun", tols, ...
    "TolCon", tols ...
    );

%% perform the fitting
[fitParameters, ~, residuals] = ...
    lsqcurvefit(@gaussian2d, StartPoint, xyData, zData, LowerBound, UpperBound, options);
fitParameterErrors = gaussian2dErrors(fitParameters, residuals, xyData);
end

function z = gaussian2d(p, xy)
% compute 2D gaussian
b1 = 1 / (2 * p(3)^2);
b2 = 1 / (2 * p(4)^2);
b3 = cos(p(2));
b4 = sin(p(2));

c1 = xy{1} - p(5);
c2 = xy{2} - p(6);

z = p(7) + p(1)*exp(-b1*(b3*c1 + b4*c2).^2 - b2*(-b4*c1 + b3*c2).^2);
end

function deltaParameters = gaussian2dErrors(p, residuals, xy)
% get the confidence intervals
jacobian = guassian2dJacobian(p, xy);
parameterConfidenceIntervals = nlparci(p, residuals, "Jacobian", jacobian);
deltaParameters = 0.5 * diff(parameterConfidenceIntervals, [], 2).';
end

function jacobian = guassian2dJacobian(p, xy)
% compute the jacobian
x = xy{1};
y = xy{2};

b1 = 1 / p(3)^2;
b2 = 1 / p(4)^2;
b3 = cos(p(2));
b4 = sin(p(2));

c1 = x - p(5);
c2 = y - p(6);

a1 = b3*c1 + b4*c2;
a2 = b3*c2 - b4*c1;
a3 = exp(-(b1 * a1.^2 + b2 * a2.^2));
a4 = 2 * p(1) * a3;
a5 = b1 * a1;
a6 = b2 * a2;

jacobian(:, 1) = a3;
jacobian(:, 2) = -2 * p(1) * (b1 - b2) * a3 .* a1 .* a2;
jacobian(:, 3) = a4 .* a5.^2 / p(3);
jacobian(:, 4) = a4 .* a6.^2 / p(4);
jacobian(:, 5) = a4 .* (b3*a5 - 2*b4*a6);
jacobian(:, 6) = a4 .* (b3*a6 + 2*b4*a5);
jacobian(:, 7) = ones(size(x));
end
