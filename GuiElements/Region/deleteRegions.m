function deleteRegions(regions)
regionCount = numel(regions);
for index = 1:regionCount
    region = regions(index);
    region.notify("DeletingROI");
    delete(region);
end
end