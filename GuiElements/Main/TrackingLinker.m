classdef TrackingLinker < VideoImporter & RegionPreviewer
    properties (Access = private)
        gui;
        videoSelector;
    end

    methods
        function obj = TrackingLinker(trackingGui, varargin)
            p = inputParser;
            addOptional(p, "StartingFilepath", "");
            parse(p, varargin{:});
            startingFilepath = p.Results.StartingFilepath;

            directoryGui = trackingGui.getDirectoryGui();
            imageGui = trackingGui.getImageGui();
            regionGuiPanel = trackingGui.getRegionGuiPanel();
            imageLinker = ImageLinker(imageGui);

            obj@RegionPreviewer(imageLinker, regionGuiPanel);
            obj@VideoImporter([]);
            obj.videoSelector = VideoSelector( ...
                directoryGui, ...
                @obj.videoFilepathChanged ...
                );

            obj.gui = trackingGui;

            fig = trackingGui.getFigure();
            TrackingToolbar(fig, obj);
            figureKeyPressFcn = @(src, ev) keyPressed(obj, src, ev);
            set(fig, "WindowKeyPressFcn", figureKeyPressFcn);

            obj.videoSelector.setFilepathIfChosen(startingFilepath);
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function selector = getVideoSelector(obj)
            selector = obj.videoSelector;
        end
    end

    %% Functions to update state of GUI
    methods
        function exportImageIfPossible(obj, ~, ~)
            directoryPath = obj.gui.getDirectoryPath();
            obj.imageLinker.exportImageIfPossible(directoryPath);
        end
        function trackButtonPushed(obj, ~, ~)
            if obj.regionExists("Start Tracking")
                obj.trackAndSaveRegions();
            end
        end
        function blobDetectionButtonPushed(obj, ~, ~)
            im = obj.videoSelector.getFirstFrame();
            rectanglePositions = BlobDetectorLinker.openFigure(im);
            obj.appendRectanglesByPositions(rectanglePositions);
        end

        function regionThresholdButtonPushed(obj, ~, ~)
            if obj.regionExists(AutoThresholdGui.title)
                regions = obj.getRegions();
                obj.autothresholdRegions(regions);
            end
        end
        function autothresholdRegions(obj, regions)
            im = obj.videoSelector.getFirstFrame();
            newThresholds = AutoThresholdLinker.openFigure(im, regions);
            thresholdCount = numel(newThresholds);
            for i = 1:thresholdCount
                region = regions(i);
                newThreshold = newThresholds(i);
                setLowerThreshold(region, newThreshold);
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
            exists = regionExists@ActiveRegionOrderer(obj);
            if ~exists
                obj.throwAlertMessage("No cells selected!", title);
            end
        end
    end
    methods (Access = private)
        function trackAndSaveRegions(obj)
            results = obj.trackAndProcess();
            trackingWasCompleted = true;

            if trackingWasCompleted
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
        function results = trackAndProcess(obj)
            regions = obj.getRegions();
            results = {};
            set(regions, "Color", RegionColor.queueColor); % color regions as queued

            for index = 1:numel(regions)
                region = regions(index);
                result = trackAndProcessRegion(obj, region);
                results{index} = result;
            end

            results = cell2mat(results);
            set(regions, "Color", RegionColor.unprocessedColor); % color regions as unprocessed
        end
        function filepath = saveResults(obj, results)
            filepath = obj.gui.generateSaveFilepath();
            save(filepath, "results");
        end

        function videoFilepathChanged(obj, ~, ~)
            videoSelector = obj.videoSelector;
            filepath = videoSelector.getFilepath();
            updateDisplayFrame(obj, videoSelector);
            obj.setFilepath(filepath); % must come before updating frame label
            updateFrameLabel(obj, videoSelector);
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

function updateFrameLabel(obj, videoSelector)
label = generateFrameLabel(obj);
videoSelector.setFrameLabel(label);
end

function label = generateFrameLabel(obj)
frameCount = obj.getFrameCount();
fps = obj.getFps();
label = sprintf("%d Frames (%d FPS)", frameCount, fps);
end

function updateDisplayFrame(obj, videoSelector)
firstFrame = videoSelector.getFirstFrame();
obj.changeFullImage(firstFrame);
end

function setLowerThreshold(region, threshold)
regionUserData = RegionUserData.fromRegion(region);
regionUserData.setLowerThreshold(threshold);
end
