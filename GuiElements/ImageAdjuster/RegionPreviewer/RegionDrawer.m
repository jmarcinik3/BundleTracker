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
            obj.addMetadataToRegion(region);
            configureRegion(region);
        end
        function rect = drawRectangleByPosition(obj, position)
            ax = obj.getAxis();
            rect = images.roi.Rectangle(ax, "Position", position);
            obj.addMetadataToRegion(rect);
            configureRegion(rect);
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
            if strcmp(get(obj, 'type'), 'axes')
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
            updateRegionSelected(activeRegion);
            updateRegionLabels(activeRegion);
        end
    end
    methods (Access = private)
        function addMetadataToRegion(obj, region)
            userData = obj.userDataFcn();
            set(region, "UserData", userData);
        end
    end
end





function configureRegion(region)
set(region, "SelectedColor", RegionColor.workingColor);
end

function updateRegionSelected(activeRegion)
regions = RegionDrawer.getRegions(activeRegion);
set(regions, "Selected", false);
set(activeRegion, "Selected", true);
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
