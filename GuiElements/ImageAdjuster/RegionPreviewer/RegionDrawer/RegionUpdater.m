classdef RegionUpdater
    methods (Static)
        function selected(region)
            updateSelected(region);
        end
        function labels(ax)
            updateLabels(ax);
        end
    end
end



function updateSelected(activeRegion)
regions = RegionDrawer.getRegions(activeRegion);
set(regions, "Selected", false);
set(activeRegion, "Selected", true);
end

function updateLabels(ax)
regions = RegionDrawer.getRegions(ax);
regionCount = numel(regions);
for index = 1:regionCount
    region = regions(index);
    updateLabel(region, index);
end
end

function updateLabel(region, index)
label = num2str(index);
set(region, "Label", label);
end
