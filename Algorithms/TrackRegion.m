function results = TrackRegion(bounds, filepaths, trackingKeyword, preprocessor)
importer = ImportImage(bounds);
count = numel(filepaths);
progress = ProgressTracker(count);
centers = struct([]);

for index = 1:count
    filepath = filepaths(index);
    boundedImage = importer.get(filepath);
    boundedImage = preprocessor(boundedImage);
    center = TrackingAlgorithms.byKeyword(boundedImage, trackingKeyword);
    centers = [centers center];
    progress.update(index);
end

delete(progress);

results = PointStructurer.mergePoints(centers);
end