classdef RegionUpdater
    methods (Static)
        function update(region)
            RegionUpdater.selected(region);
            RegionUpdater.labels(region);
        end

        function selected(activeRegion)
            regions = RegionDrawer.getRegions(activeRegion);
            set(regions, "Selected", false);
            set(activeRegion, "Selected", true);
        end

        function labels(ax)
            regions = RegionDrawer.getRegions(ax);
            arrayfun( ...
                @(index) set(regions(index), "Label", num2str(index)), ...
                1:numel(regions) ...
                );
        end
    end
end
