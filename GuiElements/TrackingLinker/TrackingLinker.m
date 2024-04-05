classdef TrackingLinker < RegionPreviewer ...
        & VideoImporter ...
        & VideoSelector

    properties (Constant)
        importRegionsTitle = "Import Regions";
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
            obj@VideoImporter;
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
            if obj.regionExists(RegionPreviewer.resetTitle)
                resetKeyword = source.UserData;
                regions = obj.getRegions();
                obj.resetRegionsToDefaults(regions, resetKeyword);
            end
        end

        function importRegionsMenuCalled(obj, ~, ~)
            previousDirectoryPath = obj.gui.getDirectoryPath();
            extensions = TrackingLinker.extensions;
            title = TrackingLinker.importRegionsTitle;
            filepath = uigetfilepath(extensions, title, previousDirectoryPath);
            if isfile(filepath)
                obj.importRegionsFromFile(filepath);
            end
        end

        function exportImageIfPossible(obj, ~, ~)
            imageLinker = obj.getImageLinker();
            directoryPath = obj.gui.getDirectoryPath();
            imageLinker.exportImageIfPossible(directoryPath);
        end
        function trackButtonPushed(obj, ~, ~)
            if obj.regionExists("Start Tracking")
                obj.trackAndSaveRegions();
            end
        end
        function blobDetectionButtonPushed(obj, ~, ~)
            im = obj.getFirstFrame();
            [blobParameters, blobShape] = BlobDetectorLinker.openFigure(im);
            obj.drawRegionsByParameters(blobParameters, blobShape);
        end

        function otsuThresholdsPushed(obj, ~, ~)
            if obj.regionExists(OtsuThresholdsGui.title)
                regions = obj.getRegions();
                obj.otsuThresholdRegions(regions);
            end
        end
        function regionThresholdButtonPushed(obj, source, ~)
            thresholdKeyword = source.UserData;
            if obj.regionExists(thresholdKeyword)
                regions = obj.getRegions();
                obj.thresholdRegions(regions, thresholdKeyword);
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
            fileCount = numel(filepath);
            if fileCount >= 1 && isfile(filepath)
                videoFilepathChanged(obj, filepath);
            end
        end

        function thresholdRegions(obj, regions, thresholdKeyword)
            im = obj.getFirstFrame();
            regionalImages = generateRegionalImages(regions, im);
            fig = generateFigure();
            newThresholds = AutoThresholdOpener.byKeyword(fig, regionalImages, thresholdKeyword);
            RegionUserData.setRegionsThresholds(obj, newThresholds);
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
            exists = regionExists@ActiveRegionOrderer(obj);
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
            filepath = obj.saveResults(results);
            displayTrackingCompleted(results, filepath);
            obj.exportImageIfPossible();
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
        function filepath = saveResults(obj, results)
            filepath = obj.gui.generateSaveFilepath();
            save(filepath, "results");
        end

        function throwAlertMessage(obj, message, title)
            fig = obj.gui.getFigure();
            uialert(fig, message, title);
        end
    end
end



function displayTrackingCompleted(results, filepath)
resultsParser = ResultsParser(results);
regionCount = resultsParser.getRegionCount();
title = sprintf("Tracking Completed (%d)", regionCount);
message = trackingCompletedMessage(results, filepath);
msgbox(message, title);
end
function message = trackingCompletedMessage(results, filepath)
resultsParser = ResultsParser(results);
regionCount = resultsParser.getRegionCount();
fps = resultsParser.getFps();
savedMsg = sprintf("Results saved to %s", filepath);
countMsg = sprintf("Cell Count: %d", regionCount);
fpsMsg = sprintf("FPS: %d", fps);
message = [savedMsg, countMsg, fpsMsg];
end

function videoFilepathChanged(obj, filepath)
videoReader = VideoReader(filepath);
firstFrame = read(videoReader, 1);
videoProfile = get(videoReader, "VideoFormat");
maxIntensity = getMaximumIntensity(videoProfile);
label = generateFrameLabel(videoReader);

obj.changeImage(firstFrame);
updateThresholdSliderRanges(obj, maxIntensity);
obj.setFrameLabel(label);
obj.importVideoToRam(videoReader);
end

function label = generateFrameLabel(videoReader)
frameCount = get(videoReader, "NumFrames");
fps = get(videoReader, "FrameRate");
label = sprintf("%d Frames (%d FPS)", frameCount, fps);
end

function updateThresholdSliderRanges(obj, maxIntensity)
imageLinker = obj.getImageLinker();
regionLinker = obj.getRegionLinker();
imageLinker.setMaximumIntensity(maxIntensity);
regionLinker.setMaximumIntensity(maxIntensity);
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
