function region = drawRegionByParameters(ax, parameters, keyword)
switch keyword
    case BlobDrawer.ellipseKeyword
        region = drawEllipseByParameters(ax, parameters);
    case BlobDrawer.rectangleKeyword
        region = drawRectangleByPosition(ax, parameters);
end
end

function rect = drawRectangleByPosition(ax, position)
rect = images.roi.Rectangle(ax, "Position", position);
end

function ell = drawEllipseByParameters(ax, parameters)
center = parameters(1:2);
radii = parameters(3:4);
angle = parameters(5);

ell = images.roi.Ellipse(ax, ...
    "Center", center, ...
    "RotationAngle", rad2deg(angle), ...
    "SemiAxes", radii ...
    );
end
