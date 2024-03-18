function result = trackAndProcessRegion(trackingLinker, region)
set(region, "Color", RegionColor.workingColor); % color region as in-process
centers = trackCenters(trackingLinker, region);
initialResult = trackingLinker.generateInitialResult();
result = processResult(region, centers, initialResult);
set(region, "Color", RegionColor.finishedColor); % color region as finished
end

function centers = trackCenters(trackingLinker, region)
ims = getPreprocessedVideoInRegion(trackingLinker, region);
regionUserData = RegionUserData.fromRegion(region);
trackingMode = regionUserData.getTrackingMode();
regionTracker = RegionTracker("TrackingMode", trackingMode);
centers = regionTracker.track(ims);
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
result = postprocessResults(result);
end

function result = appendRegionalMetadata(region, result)
regionUserData = RegionUserData.fromRegion(region);
result = regionUserData.appendMetadata(result);
end



function results = postprocessResults(results)
resultCount = ResultsParser(results).getRegionCount();
if resultCount == 1
    results = postprocessResult(results);
else
    for index = 1:resultCount
        result = results(index);
        postResult = postprocessResult(result);
        results(index) = postResult;
    end
end
end

function postResult = postprocessResult(result)
postprocessor = Postprocessor(result);
postprocessor.process();
postResult = postprocessor.getPostprocessedResult();
end
