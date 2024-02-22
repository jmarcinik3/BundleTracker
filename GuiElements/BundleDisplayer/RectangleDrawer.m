classdef RectangleDrawer < handle
    properties(Access = private, Constant)
        unprocessedColor = [0 0.4470 0.7410]; % default rectangle color
    end

    properties (Access = private)
        axis;
        userDataFcn;
    end
    
    methods
        function obj = RectangleDrawer(ax)
            obj.axis = ax;
        end

        function setUserDataFcn(obj, userDataFcn)
            obj.userDataFcn = userDataFcn;
        end
        function generateRectangle(obj, ~, event)
            point = event.IntersectionPoint(1:2);
            obj.drawRectangle(point);
        end
    end

    methods (Access = private)
        function ax = getAxis(obj)
            ax = obj.axis;
        end

        function rect = drawRectangle(obj, point)
            ax = obj.getAxis();
            rect = drawRectangle(ax, point);
            obj.addMetadataToRegion(rect);
        end
        function addMetadataToRegion(obj, region)
            color = obj.unprocessedColor;
            userData = obj.userDataFcn();

            set(region, ...
                "Color", color, ...
                "UserData", userData ...
                );
            addlistener( ...
                region, "ROIClicked", ...
                @(src, ev) region.set("Color", color) ...
                );
        end
    end
end

