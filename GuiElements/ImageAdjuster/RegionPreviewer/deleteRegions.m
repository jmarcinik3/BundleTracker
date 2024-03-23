function deleteRegions(regions)
if iscell(regions)
    regionCount = numel(regions);
    for index = 1:regionCount
        region = regions{index};
        region.notify("DeletingROI");
        delete(region);
    end
elseif ismatrix(regions)
    arrayfun(@(region) region.notify("DeletingROI"), regions);
    delete(regions);
end
end