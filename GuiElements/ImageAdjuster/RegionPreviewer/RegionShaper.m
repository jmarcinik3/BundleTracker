classdef RegionShaper < handle
    properties (Constant)
        rectangleKeyword = "Rectangle";
        ellipseKeyword = "Ellipse";
        polygonKeyword = "Polygon";
        freehandKeyword = "Freehand";
    end

    properties (Access = private)
        axis;
        shapeKeyword = RegionShaper.rectangleKeyword;
    end

    methods
        function obj = RegionShaper(ax)
            obj.axis = ax;
        end
    end

    %% Functions to generate GUI elements
    methods (Access = protected)
        function region = generateRegionByKeyword(obj)
            ax = obj.getAxis();
            keyword = obj.getRegionShape();
            region = generateRegionByKeyword(ax, keyword);
        end
    end

    %% Functions to retrieve GUI elements
    methods (Access = protected)
        function ax = getAxis(obj)
            ax = obj.axis;
        end
    end

    %% Functions to state information
    methods (Access = protected)
        function shapeKeyword = getRegionShape(obj)
            shapeKeyword = obj.shapeKeyword;
        end
    end

    %% Functions to set state information
    methods
        function setRegionShape(obj, shapeKeyword)
            obj.shapeKeyword = shapeKeyword;
        end
        function setRectangleShape(obj, ~, ~)
            rectangleKeyword = RegionShaper.rectangleKeyword;
            obj.setRegionShape(rectangleKeyword);
        end
        function setEllipseShape(obj, ~, ~)
            ellipseKeyword = RegionShaper.ellipseKeyword;
            obj.setRegionShape(ellipseKeyword);
        end
        function setPolygonShape(obj, ~, ~)
            polygonKeyword = RegionShaper.polygonKeyword;
            obj.setRegionShape(polygonKeyword);
        end
        function setFreehandShape(obj, ~, ~)
            freehandKeyword = RegionShaper.freehandKeyword;
            obj.setRegionShape(freehandKeyword);
        end
    end
end



function region = generateRegionByKeyword(ax, keyword)
switch keyword
    case RegionShaper.rectangleKeyword
        region = images.roi.Rectangle(ax);
    case RegionShaper.ellipseKeyword
        region = images.roi.Ellipse(ax);
    case RegionShaper.polygonKeyword
        region = images.roi.Polygon(ax);
    case RegionShaper.freehandKeyword
        region = images.roi.Freehand(ax);
end
end
