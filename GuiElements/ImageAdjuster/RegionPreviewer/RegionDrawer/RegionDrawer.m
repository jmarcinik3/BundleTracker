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

        function region = drawRegionByParameters(obj, parameters, keyword)
            ax = obj.getAxis();
            region = drawRegionByParameters(ax, parameters, keyword);
            configureRegion(obj, region);
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
set(region, "SelectedColor", SettingsParser.getRegionActiveColor());
set(region, "LabelTextColor", SettingsParser.getRegionLabelColor());
addMetadataToRegion(obj, region);
end

function addMetadataToRegion(obj, region)
userData = obj.userDataFcn();
set(region, "UserData", userData);
end
