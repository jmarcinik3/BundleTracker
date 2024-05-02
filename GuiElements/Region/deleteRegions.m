function deleteRegions(regions)
ax = ancestor(regions, "axes");
regionCount = numel(regions);

for index = 1:regionCount
    region = regions(index);
    region.notify("DeletingROI");
    delete(region);
end

RegionUpdater.labels(ax);
end