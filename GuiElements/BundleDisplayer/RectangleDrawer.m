classdef RectangleDrawer < handle
    properties (Access = private)
        axis;
        userDataFcn;
    end
    
    methods
        function obj = RectangleDrawer(ax, userDataFcn)
            obj.userDataFcn = userDataFcn;
            obj.axis = ax;
        end

        function rect = generateRectangle(obj, ~, event)
            point = event.IntersectionPoint(1:2);
            rect = obj.drawRectangle(point);
            obj.addMetadataToRegion(rect);
        end
    end

    methods (Access = private)
        function ax = getAxis(obj)
            ax = obj.axis;
        end

        function rect = drawRectangle(obj, point)
            ax = obj.getAxis();
            rect = drawRectangle(ax, point);
        end
        function addMetadataToRegion(obj, region)
            userData = obj.userDataFcn();
            set(region, "UserData", userData);
        end
    end
end
