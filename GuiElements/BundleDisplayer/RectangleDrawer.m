classdef RectangleDrawer < handle
    properties(Access = private, Constant)
        unprocessedColor = [0, 0.447, 0.741]; % default rectangle color
    end

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
            color = obj.unprocessedColor;
            userData = obj.userDataFcn();

            set(region, ...
                "Color", color, ...
                "UserData", userData ...
                );
            addlistener(region, "ROIMoved", @obj.regionMoved);
        end

        function regionMoved(obj, source, ~)
            color = obj.unprocessedColor;
            source.set("Color", color);
        end
    end
end
