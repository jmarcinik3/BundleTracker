function trackingCompleted(obj, results, metadata)
fig = generateTrackingCompletedFigure(results);
resultsFilepath = generateResultsFilepath(obj);
imageFilepath = generateImageFilepath(obj);
trackingCompleteGui = TrackingCompletedGui( ...
    fig, results, ...
    "ResultsFilepath", resultsFilepath, ...
    "ImageFilepath", imageFilepath ...
    );
uiwait(fig);

resultsFilepath = trackingCompleteGui.resultsFilepath;
imageFilepath = trackingCompleteGui.imageFilepath;

saveResults(resultsFilepath, results, metadata);
if ischar(imageFilepath) || isstring(imageFilepath)
    obj.exportFullImage(imageFilepath);
end
end

function fig = generateTrackingCompletedFigure(results)
figDefaults = SettingsParser.getTrackingCompletedFigureDefaults();
figDefaults.Name = sprintf( ...
    "%s (%d)", ...
    figDefaults.Name, ...
    ResultsParser(results).getRegionCount() ...
    );
figDefaults = namedargs2cell(figDefaults);
fig = generateFigure(figDefaults{:});
end

function filepath = generateResultsFilepath(obj)
filepath = sprintf( ...
    "%s\\%s", ...
    obj.gui.getDirectoryPath(), ...
    SettingsParser.getDefaultResultsFilename() ...
    );
end

function filepath = generateImageFilepath(obj)
filepath = sprintf( ...
    "%s\\%s", ...
    obj.gui.getDirectoryPath(), ...
    SettingsParser.getDefaultImageFilename() ...
    );
end

function saveResults(resultsFilepath, results, metadata)
if ischar(resultsFilepath) || isstring(resultsFilepath)
    save(resultsFilepath, "results", "metadata");
end
end
