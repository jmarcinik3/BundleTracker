classdef RegionDrawer < handle
    properties (Constant)
        rectangleKeyword = "Rectangle";
        ellipseKeyword = "Ellipse";
        polygonKeyword = "Polygon";
        freehandKeyword = "Freehand";
    end
    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>
        axis;
        shapeKeyword;
        userDataFcn;
    end

    methods
        function obj = RegionDrawer(ax, userDataFcn)
            obj.axis = ax;
            obj.shapeKeyword = RegionDrawer.rectangleKeyword;
            obj.userDataFcn = userDataFcn;
        end
    end

    %% Functions to generate GUI elements
    methods (Access = protected)
        function region = generateRegion(obj, ~, event)
            point = event.IntersectionPoint(1:2);
            region = obj.drawRegion(point);
            obj.addMetadataToRegion(region);
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods (Access = private)
        function ax = getAxis(obj)
            ax = obj.axis;
        end
        function shapeKeyword = getRegionShape(obj)
            shapeKeyword = obj.shapeKeyword;
        end
    end
    methods (Access = protected, Static)
        function regions = getRegions(ax)
            children = ax.Children;
            regions = findobj(children, "Type", "images.roi");
            regions = flip(regions);
        end
    end

    %% Functions to set state information
    methods
        function setRegionShape(obj, shapeKeyword)
            obj.shapeKeyword = shapeKeyword;
        end
        function setRectangleShape(obj, ~, ~)
            rectangleKeyword = RegionDrawer.rectangleKeyword;
            obj.setRegionShape(rectangleKeyword);
        end
        function setEllipseShape(obj, ~, ~)
            ellipseKeyword = RegionDrawer.ellipseKeyword;
            obj.setRegionShape(ellipseKeyword);
        end
        function setPolygonShape(obj, ~, ~)
            polygonKeyword = RegionDrawer.polygonKeyword;
            obj.setRegionShape(polygonKeyword);
        end
        function setFreehandShape(obj, ~, ~)
            freehandKeyword = RegionDrawer.freehandKeyword;
            obj.setRegionShape(freehandKeyword);
        end
    end

    %% Functions to update GUI and state information
    methods (Access = protected)
        function region = drawRegion(obj, point)
            ax = obj.getAxis();
            keyword = obj.getRegionShape();
            region = drawRegionByKeyword(ax, point, keyword);
        end
    end
    methods (Access = private)
        function addMetadataToRegion(obj, region)
            userData = obj.userDataFcn();
            set(region, "UserData", userData);
        end
    end
end



function region = drawRegionByKeyword(ax, point, keyword)
switch keyword
    case RegionDrawer.rectangleKeyword
        region = images.roi.Rectangle(ax);
    case RegionDrawer.ellipseKeyword
        region = images.roi.Ellipse(ax);
    case RegionDrawer.polygonKeyword
        region = images.roi.Polygon(ax);
    case RegionDrawer.freehandKeyword
        region = images.roi.Freehand(ax);
end

beginDrawingFromPoint(region, point);
updateRegionLabels(ax);
end

function updateRegionLabels(ax)
regions = RegionDrawer.getRegions(ax);
count = numel(regions);
for index = 1:count
    region = regions(index);
    updateRegionLabel(region, index);
end
end

function updateRegionLabel(region, index)
label = num2str(index);
set(region, "Label", label);
end
