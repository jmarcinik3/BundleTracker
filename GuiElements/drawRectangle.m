function rect = drawRectangle(ax, point)
rect = images.roi.Rectangle(ax);
beginDrawingFromPoint(rect, point);
updateRegionLabels(ax);
end

function updateRegionLabels(ax)
regions = getRegions(ax);
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

function regions = getRegions(ax)
children = ax.Children;
regions = findobj(children, "Type", "images.roi.rectangle");
end
