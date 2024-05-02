function deleteRegions(regions)
if numel(regions) == 0
    return;
end
ax = ancestor(regions(1), "axes");
regionCount = numel(regions);

for index = 1:regionCount
    region = regions(index);
    region.notify("DeletingROI");
    delete(region);
end

RegionUpdater.labels(ax);
end