function [cancel, result] = trackAndProcessRegion(trackingLinker, region)
trackingLinker.previewRegion(region);
[cancel, centers] = trackCenters(trackingLinker, region);
initialResult = trackingLinker.generateInitialResult();
result = processResult(region, centers, initialResult);
if ~cancel
    set(region, "Color", RegionColor.finishedColor); % color region as finished
end
end

function [cancel, centers] = trackCenters(trackingLinker, region)
ims = getPreprocessedVideoInRegion(trackingLinker, region);
regionUserData = RegionUserData.fromRegion(region);
trackingMode = regionUserData.getTrackingMode();
regionTracker = RegionTracker("TrackingMode", trackingMode);
[cancel, centers] = regionTracker.track(ims);
end

function ims = getPreprocessedVideoInRegion(obj, region)
ims = obj.getVideoInRegion(region);
preprocessor = Preprocessor.fromRegion(region);
ims = preprocessor.preprocess(ims);
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
regionUserData = RegionUserData.fromRegion(region);
result.Label = region.Label;
result.Region = region;
result = regionUserData.appendMetadata(result);
end

function postResult = postprocessResult(result)
postprocessor = Postprocessor(result);
postprocessor.process();
postResult = postprocessor.getPostprocessedResult();
end
