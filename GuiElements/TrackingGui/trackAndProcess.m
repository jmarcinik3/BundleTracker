function [cancel, results] = trackAndProcess(trackingLinker)
regions = trackingLinker.getRegions();
set(regions, "Color", SettingsParser.getRegionQueueColor());
[cancel, results] = trackAndProcessMultiple(trackingLinker, regions);

activeRegion = trackingLinker.getActiveRegion();
RegionUpdater.selected(activeRegion);
set(regions, "Color", SettingsParser.getRegionDefaultColor());
end

function [cancel, results] = trackAndProcessMultiple(trackingLinker, regions)
regionCount = numel(regions);
cancel = false;

taskName = 'Tracking Regions';
multiWaitbar(taskName, 0, 'CanCancel', 'on');
results = [];

for index = 1:regionCount
    region = regions(index);
    result = trackAndProcessRegion(trackingLinker, region);
    results = [results, result];

    proportionComplete = index / regionCount;
    cancel = multiWaitbar(taskName, proportionComplete) || cancel;
    if cancel
        break;
    end
end

multiWaitbar(taskName, 'Close');
end



function result = trackAndProcessRegion(trackingLinker, region)
trackingLinker.previewRegion(region);
ims = preprocessRegion( ...
    im2double(trackingLinker.getVideoInRegion(region)), ...
    Preprocessor.fromRegion(region) ...
    );

trackingMode = RegionUserData(region).getTrackingMode();
centers = trackVideo(ims, trackingMode);

result = processResult(region, centers, ims, trackingLinker);
set(region, "Color", SettingsParser.getRegionTrackedColor());
end

function centers = trackVideo(ims, trackingMode)
frameCount = size(ims, 3);
centers = PointStructurer.preallocate(frameCount);
trackFrame = TrackingAlgorithms.handleByKeyword(trackingMode, ims);

parfor index = 1:frameCount
    centers(index) = trackFrame(ims(:, :, index));
end

centers = PointStructurer.mergePoints(centers);
end

function [area, areaError] = calculateRegionArea(ims)
im = imbinarize(ims);
objectAreas = squeeze(sum(im, [1, 2]));
area = mean(objectAreas);
areaError = std(objectAreas);
end



function result = processResult(region, centers, ims, trackingLinker)
initialResult = trackingLinker.generateInitialResult();
result = table2struct([ ...
    struct2table(centers), ...
    struct2table(initialResult) ...
    ]);
result.Label = region.Label;
result.Region = getRegionMetadata(region);
result = RegionUserData(region).appendMetadata(result);

parser = struct( ...
    "results", result, ...
    "metadata", trackingLinker.generateMetadata() ...
    );
postprocessor = Postprocessor(parser);
postprocessor.process();
result = postprocessor.getPostprocessedResult();

[area, areaError] = calculateRegionArea(ims);
result.Area = area;
result.AreaError = areaError;
end