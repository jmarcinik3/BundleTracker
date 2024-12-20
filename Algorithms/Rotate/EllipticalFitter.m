classdef EllipticalFitter
    properties (SetAccess = protected)
        Center;
        SemiAxes;
        RotationAngle;
    end

    methods
        function obj = EllipticalFitter(xy)
            % XY: a 2xN  matrix
            [center, radii, angle] = ellipseFromXy(xy);
            [radii, angle] = rerangeDirection(radii, angle);
            obj.Center = center(:).';
            obj.SemiAxes = radii;
            obj.RotationAngle = angle;
        end
    end
end



function [center, radii, angle] = ellipseFromXy(xy)
xyCenter = median(xy, 2);
ABCDEF = mostNullCoefficients(xy - xyCenter);
checkDiscriminant(ABCDEF);
center = centerFromCoefficients(ABCDEF) + xyCenter.';
angle = angleFromCoefficients(ABCDEF);
radii = radiiFromCoefficients(ABCDEF);
end

function ABCDEF = mostNullCoefficients(xy)
x = xy(1, :).';
y = xy(2, :).';
c = ones(size(x));
conicTerms = [x.^2, x.*y, y.^2, x, y, c];
[~, ~, V] = svd(conicTerms, "econ");
ABCDEF = V(1:6, 6);
end

function checkDiscriminant(ABCDEF)
ABCDEF = num2cell(ABCDEF);
[A, B, C, ~, ~, ~] = deal(ABCDEF{:});
discriminant = B^2 - 4*A*C;
if discriminant == 0
    warning("Parabola fit instead of ellipse");
elseif discriminant > 0
    warning("Hyperbola fit instead of ellipse");
end
end



function ab = radiiFromCoefficients(ABCDEF)
ABCDEF = num2cell(ABCDEF);
[A, B, C, D, E, F] = deal(ABCDEF{:});

bottom = B^2 - 4*A*C;
top1 = 2 * (A*E^2 + C*D^2 - B*D*E + F*bottom);
top2 = (A + C) + [1, -1] * sqrt((A-C)^2 + B^2);
ab = -sqrt(top1 * top2) / bottom;
end

function xy0 = centerFromCoefficients(ABCDEF)
ABCDEF = num2cell(ABCDEF);
[A, B, C, D, E, ~] = deal(ABCDEF{:});
xy0 = [2*C*D-B*E, 2*A*E-B*D] ./ (B^2-4*A*C);
end

function angle = angleFromCoefficients(ABCDEF)
ABCDEF = num2cell(ABCDEF);
[A, B, C, ~, ~, ~] = deal(ABCDEF{:});

if B == 0 && A < C
    angle = 0;
elseif B == 0 && A > C
    angle = pi/2;
elseif B ~= 0 && A < C
    angle = 0.5 * acot((C-A)/B);
elseif B ~= 0 && A > C
    angle = pi/2 + 0.5 * acot((C-A)/B);
end
end

function [radii, angle] = rerangeDirection(radii, angle)
if angle > pi/4
    angle = angle - pi/2;
    radii = flip(radii);
elseif angle < -pi/4
    angle = angle + pi/2;
    radii = flip(radii);
end
end
