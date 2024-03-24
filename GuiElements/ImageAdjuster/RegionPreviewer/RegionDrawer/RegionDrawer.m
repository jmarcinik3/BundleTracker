classdef RegionDrawer < RegionShaper
    properties (Access = private)
        userDataFcn;
    end

    methods
        function obj = RegionDrawer(ax, userDataFcn)
            obj@RegionShaper(ax);
            obj.userDataFcn = userDataFcn;
        end
    end

    %% Functions to generate GUI elements
    methods (Access = protected)
        function region = drawRegionOnClick(obj, ~, event)
            point = event.IntersectionPoint(1:2);
            region = obj.byPoint(point);
            configureRegion(obj, region);
        end
        function rect = drawRectangleByPosition(obj, position)
            ax = obj.getAxis();
            rect = images.roi.Rectangle(ax, "Position", position);
            configureRegion(obj, rect);
        end
        function ell = drawEllipseByParameters(obj, parameters)
            ax = obj.getAxis();
            ell = drawEllipseByParameters(ax, parameters);
            configureRegion(obj, ell);
        end
    end
    methods (Access = private)
        function region = byPoint(obj, point)
            region = obj.generateRegionByKeyword();
            beginDrawingFromPoint(region, point);
            RegionDrawer.updateSelected(region);
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods (Static)
        function regions = getRegions(obj)
            if isa(obj, "matlab.ui.control.UIAxes")
                children = obj.Children;
                regions = findobj(children, "Type", "images.roi");
                regions = flip(regions);
            elseif RegionType.isRegion(obj)
                ax = ancestor(obj, "axes");
                regions = RegionDrawer.getRegions(ax);
            end
        end
    end

    %% Functions to update GUI and state information
    methods (Static)
        function updateSelected(activeRegion)
            RegionUpdater.selected(activeRegion);
            RegionUpdater.labels(activeRegion);
        end
    end
end



function configureRegion(obj, region)
set(region, "SelectedColor", RegionColor.workingColor);
addMetadataToRegion(obj, region);
end

function addMetadataToRegion(obj, region)
userData = obj.userDataFcn();
set(region, "UserData", userData);
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
