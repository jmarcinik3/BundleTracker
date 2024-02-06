function [fitParameters, zFit, fitParameterErrors, zError, resnorm, rsquare] ...
    = fmgaussfit(xInput, yInput, zzInput)
% FMGAUSSFIT Create/alter optimization OPTIONS structure.
%   [fitParameters,..., rr] = fmgaussfit(xInput,yInput,zzInput) uses zzInput for the surface
%   height. xInput and yInput are vectors or matrices defining the x and y
%   components of a surface. If xInput and yInput are vectors, length(xInput) = n and
%   length(yInput) = m, where [m,n] = size(Z). In this case, the vertices of the
%   surface faces are (xInput(j), yInput(i), zzInput(i,j)) triples. To create xInput and yInput
%   matrices for arbitrary domains, use the meshgrid function. FMGAUSSFIT
%   uses the lsqcurvefit tool, and the OPTIMZATION TOOLBOX. The initial
%   guess for the gaussian is places at the maxima in the zzInput plane. The fit
%   is restricted to be in the span of xInput and yInput.
%   See:
%       http://en.wikipedia.org/wiki/Gaussian_function
%
%   Examples:
%     To fit a 2D gaussian:
%       [fitParameters, zFit, fitParameterErrors, zError, resnorm, rr] =
%       fmgaussfit(xInput, yInput, zzInput);
%   See also SURF, OMPTMSET, LSQCURVEFIT, NLPARCI, NLPREDCI.

%   Copyright 2013, Nathan Orloff.

%% Condition the data
[xData, yData, zData] = prepareSurfaceData(xInput, yInput, zzInput);
xyData = {xData, yData};

%% Set up the startpoint
amplitudeGuess = 1;
angleDegreesGuess = 45; % angle in degrees.
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
UpperBound = [Inf, 180, Inf, Inf, xUpperBound, yUpperBound, Inf]; % angle greater than 90 are redundant
StartPoint = [amplitudeGuess, angleDegreesGuess, xStdGuess, yStdGuess, xGuess, yGuess, zGuess];

tols = 1e-16;
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
[fitParameters, resnorm, residuals] = ...
    lsqcurvefit(@gaussian2d, StartPoint, xyData, zData, LowerBound, UpperBound, options);
[fitParameterErrors, zFit, zError] = gaussian2dErrors(fitParameters, residuals, xyData);
rsquare = rsquared(zData, zFit, zError);
zFit = reshape(zFit, size(zzInput));
zError = reshape(zError, size(zzInput));
end

function rr = rsquared(zData, zFit, zError)
% reduced chi-squared
deltaZ = zData - zFit;
rr = 1 / (numel(zData)-8) .* sum((deltaZ./zError).^2); % minus 8 because there are 7 fit parameters +1 (DOF)
end

function z = gaussian2d(p, xy)
% compute 2D gaussian
b1 = 1 / p(3)^2;
b2 = 1 / p(4)^2;
b3 = cosd(p(2));
b4 = sind(p(2));

c1 = xy{1} - p(5);
c2 = xy{2} - p(6);

z = p(7) + p(1)*exp(-b1*(b3*c1 + b4*c2).^2 - b2*(-b4*c1 + b3*c2).^2);
end

function [deltaParameters, zFit, zError] = gaussian2dErrors(p, residuals, xy)
% get the confidence intervals
jacobian = guassian2dJacobian(p, xy);
parameterConfidenceIntervals = nlparci(p, residuals, "Jacobian", jacobian);
deltaParameters = (diff(parameterConfidenceIntervals, [], 2) / 2)';
[zFit, zError] = nlpredci(@gaussian2d, xy, p, residuals, "Jacobian", jacobian);
end

function jacobian = guassian2dJacobian(p, xy)
% compute the jacobian
x = xy{1};
y = xy{2};

b1 = 1/p(3)^2;
b2 = 1/p(4)^2;
b3 = cosd(p(2));
b4 = sind(p(2));

c1 = x - p(5);
c2 = y - p(6);

a1 = b3*c1 + b4*c2;
a2 = b3*c2 - b4*c1;
a3 = exp(-(b1 * a1.^2 + b2 * a2.^2));
a4 = 2 * p(1) * a3;
a5 = b1 * a1;
a6 = b2 * a2;

jacobian(:,1) = a3;
jacobian(:,2) = -2 * p(1) * (b1 - b2) * a3 .* a1 .* a2;
jacobian(:,3) = a4 .* a5.^2 / p(3);
jacobian(:,4) = a4 .* a6.^2 / p(4);
jacobian(:,5) = a4 .* (b3*a5 - 2*b4*a6);
jacobian(:,6) = a4 .* (b3*a6 + 2*b4*a5);
jacobian(:,7) = ones(size(x));
end