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
if regionCount == 1
    [cancel, results] = trackAndProcessRegion(trackingLinker, regions);
    return;
end

taskName = 'Tracking Regions';
multiWaitbar(taskName, 0, 'CanCancel', 'on');
results = [];

for index = 1:regionCount
    region = regions(index);
    [cancel, result] = trackAndProcessRegion(trackingLinker, region);
    results = [results, result];

    proportionComplete = index / regionCount;
    cancel = multiWaitbar(taskName, proportionComplete) || cancel;
    if cancel
        break;
    end
end

multiWaitbar(taskName, 'Close');
end



function [cancel, result] = trackAndProcessRegion(trackingLinker, region)
trackingLinker.previewRegion(region);
[cancel, ims] = preprocessRegion(trackingLinker, region);
if cancel
    result = [];
    return;
end

trackingMode = RegionUserData(region).getTrackingMode();
[cancel, centers] = trackVideo(ims, trackingMode);
if cancel
    result = [];
    return;
end

result = processResult(region, centers, trackingLinker);
if ~cancel
    set(region, "Color", SettingsParser.getRegionTrackedColor());
end
end

function [cancel, ims] = preprocessRegion(trackingLinker, region)
taskName = 'Preprocessing Region';
multiWaitbar(taskName, 0, 'CanCancel', 'on');
ims = im2double(trackingLinker.getVideoInRegion(region));
frameCount = size(ims, 3);
preprocessor = Preprocessor.fromRegion(region);

cancel = false;
proportionDelta = 1 / frameCount;
for index = 1:frameCount
    ims(:, :, index) = preprocessor.preprocess(ims(:, :, index));
    proportionComplete = index / frameCount;
    if mod(proportionComplete, 0.01) < proportionDelta
        cancel = multiWaitbar(taskName, proportionComplete);
    end
    if cancel
        break;
    end
end

multiWaitbar(taskName, 'Close');
end

function [cancel, centers] = trackVideo(ims, trackingMode)
taskName = 'Tracking Region';
multiWaitbar(taskName, 0, 'CanCancel', 'on');
frameCount = size(ims, 3);
centers = PointStructurer.preallocate(frameCount);
trackFrame = TrackingAlgorithms.handleByKeyword(trackingMode, ims);

cancel = false;
proportionDelta = 1 / frameCount;
for index = 1:frameCount
    centers(index) = trackFrame(ims(:, :, index));
    proportionComplete = index / frameCount;
    if mod(proportionComplete, 0.01) < proportionDelta
        cancel = multiWaitbar(taskName, proportionComplete);
    end
    if cancel
        break;
    end
end

centers = PointStructurer.mergePoints(centers);
multiWaitbar(taskName, 'Close');
end



function result = processResult(region, centers, trackingLinker)
initialResult = trackingLinker.generateInitialResult();
result = table2struct([ ...
    struct2table(centers), ...
    struct2table(initialResult) ...
    ]);
result.Label = region.Label;
result.Region = getRegionMetadata(region);
result = RegionUserData(region).appendMetadata(result);

metadata = trackingLinker.generateMetadata();
postprocessor = Postprocessor(result, "Metadata", metadata);
postprocessor.process();
result = postprocessor.getPostprocessedResult();
end