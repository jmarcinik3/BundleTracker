classdef BlobDrawer
    properties (Constant)
        ellipseKeyword = "Ellipse";
        rectangleKeyword = "Rectangle";
        keywords = [ ...
            BlobDrawer.rectangleKeyword, ...
            BlobDrawer.ellipseKeyword ...
            ];

        color = "black";
        lineWidth = 2;
    end

    methods (Static)
        function byKeyword(ax, parameters, keyword)
            switch keyword
                case BlobDrawer.ellipseKeyword
                    BlobDrawer.ellipses(ax, parameters);
                case BlobDrawer.rectangleKeyword
                    BlobDrawer.rectangles(ax, parameters);
            end
        end

        function rectangles(ax, positions)
            redrawBlobs(ax, positions, @drawRectangle);
        end
        function ellipses(ax, parameters)
            redrawBlobs(ax, parameters, @drawEllipse);
        end
    end
end



function redrawBlobs(ax, parameters, drawFcn)
clearAxis(ax);
blobCount = size(parameters, 1);
for blobIndex = 1:blobCount
    parameter = parameters(blobIndex, :);
    drawFcn(ax, parameter);
end
end

function rect = drawRectangle(ax, position)
rect = rectangle(ax, ...
    "Position", position, ...
    "EdgeColor", BlobDrawer.color, ...
    "LineWidth", BlobDrawer.lineWidth ...
    );
end

function ell = drawEllipse(ax, parameters)
center = parameters(1:2);
radii = parameters(3:4);
angle = parameters(5);

ell = ellipse(ax, ...
    "Center", center, ...
    "RotationAngle", angle, ...
    "SemiAxes", radii ...
    );
set(ell, ...
    "Color", BlobDrawer.color, ...
    "LineWidth", BlobDrawer.lineWidth ...
    );
end

function clearAxis(ax)
conditions = { ...
    {"Type", "rectangle"}, ...
    "-or", ...
    {"Type", "Line"} ...
    };
blobs = findobj(ax.Children, conditions);
delete(blobs);
end
