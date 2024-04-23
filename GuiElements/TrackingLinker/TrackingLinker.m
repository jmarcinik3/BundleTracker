classdef TrackingLinker < RegionPreviewer ...
        & VideoImporter ...
        & VideoSelector

    properties (Constant)
        extensions = {'*.mat', "MATLAB Structure"};
    end

    properties (Access = private)
        firstFrame;
        gui;
    end

    methods
        function obj = TrackingLinker(trackingGui, varargin)
            p = inputParser;
            addOptional(p, "StartingFilepath", "");
            parse(p, varargin{:});
            startingFilepath = p.Results.StartingFilepath;

            videoGui = trackingGui.getVideoGui();
            imageGui = trackingGui.getImageGui();
            regionGui = trackingGui.getRegionGui();

            obj@RegionPreviewer(regionGui, imageGui);
            obj@VideoImporter();
            obj@VideoSelector(videoGui);

            set(videoGui.getFilepathField(), "ValueChangedFcn", @obj.videoFilepathChanged);
            obj.gui = trackingGui;

            fig = trackingGui.getFigure();
            TrackingToolbar(fig, obj);
            figureKeyPressFcn = @(src, ev) keyPressed(obj, src, ev);
            set(fig, "WindowKeyPressFcn", figureKeyPressFcn);

            TrackingMenu(fig, obj);

            obj.setFilepathIfChosen(startingFilepath);
        end
    end

    %% Functions to update state of GUI
    methods
        function resetRegionsButtonPushed(obj, source, ~)
            title = SettingsParser.getResetRegionLabel();
            if obj.regionExists(title)
                resetKeyword = source.UserData;
                regions = obj.getRegions();
                obj.resetRegionsToDefaults(regions, resetKeyword);
            end
        end

        function importRegionsMenuCalled(obj, ~, ~)
            previousDirectoryPath = obj.gui.getDirectoryPath();
            extensions = TrackingLinker.extensions;
            title = SettingsParser.getImportRegionsLabel();
            filepath = uigetfilepath(extensions, title, previousDirectoryPath);
            if isfile(filepath)
                obj.importRegionsFromFile(filepath);
            end
        end
        function exportImageButtonPushed(obj, ~, ~)
            obj.exportImage();
        end
        function exportImage(obj, path)
            if nargin < 2
                path = obj.gui.getDirectoryPath();
            end
            exportImage@RegionPreviewer(obj, path);
        end

        function trackButtonPushed(obj, ~, ~)
            if obj.regionExists("Start Tracking")
                obj.trackAndSaveRegions();
            end
        end
        function blobDetectionButtonPushed(obj, ~, ~)
            fig = generateBlobDetectionFigure();
            im = obj.getFirstFrame();
            [blobParameters, blobShape] = BlobDetectorLinker.openFigure(fig, im);
            obj.drawRegionsByParameters(blobParameters, blobShape);
        end
        function regionThresholdButtonPushed(obj, ~, ~)
            title = SettingsParser.getAutothresholdFigureDefaults().Name;
            if obj.regionExists(title)
                regions = obj.getRegions();
                thresholdRegions(obj, regions);
            end
        end

        function openWaterfallPlotPushed(obj, ~, ~)
            startingDirectory = obj.gui.getDirectoryPath();
            extensions = TrackingLinker.extensions;
            filepath = uigetfilepath(extensions, "Create Waterfall Plot", startingDirectory);
            if isfile(filepath)
                openWaterfallPlot(filepath);
            end
        end
    end
    methods (Access = private)
        function videoFilepathChanged(obj, ~, ~)
            filepath = obj.gui.getVideoFilepath();
            if numel(filepath) >= 1 && isfile(filepath)
                videoFilepathChanged(obj, filepath);
            end
        end
    end

    %% Functions to generate state information
    methods
        function result = generateInitialResult(obj)
            gui = obj.gui;
            result = struct( ...
                "DirectoryPath", gui.getDirectoryPath(), ...
                "ScaleFactor", gui.getScaleFactor(), ...
                "ScaleFactorError", gui.getScaleFactorError(), ...
                "Fps", obj.getFps() ...
                );
        end
    end
    methods (Access = protected)
        function exists = regionExists(obj, title)
            exists = regionExists@RegionVisibler(obj);
            if ~exists && nargin >= 2
                obj.throwAlertMessage("No cells selected!", title);
            end
        end
    end
    methods (Access = private)
        function trackAndSaveRegions(obj)
            [cancel, results] = obj.trackAndProcess();
            if ~cancel
                obj.trackingCompleted(results);
            else
                obj.throwAlertMessage("Tracking Canceled!", "Start Tracking");
            end
        end
        function trackingCompleted(obj, results)
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

            if ischar(resultsFilepath) || isstring(resultsFilepath)
                save(resultsFilepath, "results");
            end
            if ischar(imageFilepath) || isstring(imageFilepath)
                obj.exportImage(imageFilepath);
            end
        end
        function [cancel, results] = trackAndProcess(obj)
            taskName = 'Tracking Regions';
            regions = obj.getRegions();

            multiWaitbar(taskName, 0, 'CanCancel', 'on');
            regionCount = numel(regions);
            results = [];
            set(regions, "Color", SettingsParser.getRegionQueueColor());

            for index = 1:regionCount
                region = regions(index);
                [cancel, result] = trackAndProcessRegion(obj, region);
                results = [results, result];

                proportionComplete = index / regionCount;
                cancel = multiWaitbar(taskName, proportionComplete) || cancel;
                if cancel
                    break;
                end
            end

            activeRegion = obj.getActiveRegion();
            RegionUpdater.selected(activeRegion);
            multiWaitbar(taskName,'Close');
        end

        function throwAlertMessage(obj, message, title)
            fig = obj.gui.getFigure();
            uialert(fig, message, title);
        end
    end
end



function videoFilepathChanged(obj, filepath)
videoReader = VideoReader(filepath);
firstFrame = read(videoReader, 1);
videoProfile = get(videoReader, "VideoFormat");
maxIntensity = getMaximumIntensity(videoProfile);
label = generateFrameLabel(videoReader);

obj.changeImage(firstFrame);
obj.setMaximumIntensity(maxIntensity);
obj.setFrameLabel(label);
obj.importVideoToRam(videoReader);
end

function label = generateFrameLabel(videoReader)
frameCount = get(videoReader, "NumFrames");
fps = get(videoReader, "FrameRate");
label = sprintf("%d Frames (%d FPS)", frameCount, fps);
end

function maxIntensity = getMaximumIntensity(videoProfile)
switch string(videoProfile)
    case {"Mono8 Signed", "RGB24 Signed"}
        maxIntensity = 2^7;
    case {"Mono8", "RGB24", "Grayscale"}
        maxIntensity = 2^8;
    case {"Mono16 Signed", "RGB48 Signed"}
        maxIntensity = 2^15;
    case {"Mono16", "RGB48"}
        maxIntensity = 2^16;
end
end

function openWaterfallPlot(filepath)
resultsParser = ResultsParser(filepath);
traces = resultsParser.getProcessedTrace();
time = resultsParser.getTime();
WaterfallLinker.openFigure(traces, time);
end

function thresholdRegions(obj, regions)
fig = generateAutothresholdFigure();
im = obj.getFirstFrame();
regionalImages = generateRegionalImages(regions, im);
newThresholds = AutoThresholdOpener.openFigure(fig, regionalImages);
RegionUserData.setRegionsThresholds(obj, newThresholds);
end

function fig = generateTrackingCompletedFigure(results)
resultsParser = ResultsParser(results);
regionCount = resultsParser.getRegionCount();

figDefaults = SettingsParser.getTrackingCompletedFigureDefaults();
figDefaults.Name = sprintf("%s (%d)", figDefaults.Name, regionCount);
figDefaults = namedargs2cell(figDefaults);
fig = generateFigure(figDefaults{:});
end
function fig = generateBlobDetectionFigure()
figDefaults = namedargs2cell(SettingsParser.getBlobDetectionFigureDefaults());
fig = generateFigure(figDefaults{:});
end
function fig = generateAutothresholdFigure()
figDefaults = namedargs2cell(SettingsParser.getAutothresholdFigureDefaults());
fig = generateFigure(figDefaults{:});
end

function filepath = generateResultsFilepath(obj)
directoryPath = obj.gui.getDirectoryPath();
filename = SettingsParser.getDefaultResultsFilename();
filepath = sprintf("%s\\%s", directoryPath, filename);
end
function filepath = generateImageFilepath(obj)
directoryPath = obj.gui.getDirectoryPath();
filename = SettingsParser.getDefaultImageFilename();
filepath = sprintf("%s\\%s", directoryPath, filename);
end
