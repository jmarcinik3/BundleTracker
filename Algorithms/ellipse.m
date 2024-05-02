function ellipseLine = ellipse(ax, varargin)
p = inputParser;
addOptional(p, "Center", [0, 0]);
addOptional(p, "RotationAngle", 0);
addOptional(p, "SemiAxes", [1, 1]);
parse(p, varargin{:});
center = p.Results.Center;
rotationAngle = p.Results.RotationAngle;
semiAxes = p.Results.SemiAxes;

xCenter = center(1);
yCenter = center(2);
xRadius = semiAxes(1);
yRadius = semiAxes(2);

Nb = 64;
theta = linspace(0, 2*pi, Nb+1);

xCosTheta = xRadius*cos(theta);
ySinTheta = yRadius*sin(theta);
x = xCosTheta*cos(rotationAngle) - ySinTheta*sin(rotationAngle) + xCenter;
y = xCosTheta*sin(rotationAngle) + ySinTheta*cos(rotationAngle) + yCenter;

ellipseLine = line(ax, x, y);
end
