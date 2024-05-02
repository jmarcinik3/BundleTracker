function [cancel, result] = trackAndProcessRegion(trackingLinker, region)
trackingLinker.previewRegion(region);
[cancel, centers] = trackCenters(trackingLinker, region);
initialResult = trackingLinker.generateInitialResult();
result = processResult(region, centers, initialResult);
if ~cancel
    set(region, "Color", SettingsParser.getRegionTrackedColor());
end
end

function [cancel, centers] = trackCenters(trackingLinker, region)
ims = trackingLinker.getVideoInRegion(region);
ims = Preprocessor.fromRegion(region).preprocess(ims);
trackingMode = RegionUserData(region).getTrackingMode();
[cancel, centers] = trackVideo(ims, trackingMode);
end

function [cancel, centers] = trackVideo(ims, trackingMode)
taskName = 'Tracking Region';
multiWaitbar(taskName, 0, 'CanCancel', 'on');
frameCount = size(ims, 3);
centers = PointStructurer.preallocate(frameCount);
trackFrame = TrackingAlgorithms.handleByKeyword(trackingMode);

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

function result = processResult(region, centers, initialResult)
result = table2struct([ ...
    struct2table(centers), ...
    struct2table(initialResult) ...
    ]);
result = appendRegionalMetadata(region, result);
result = postprocessResult(result);
end

function result = appendRegionalMetadata(region, result)
result.Label = region.Label;
result.Region = getRegionMetadata(region);
result = RegionUserData(region).appendMetadata(result);
end

function postResult = postprocessResult(result)
postprocessor = Postprocessor(result);
postprocessor.process();
postResult = postprocessor.getPostprocessedResult();
end
