classdef TrackingLinker < RegionPreviewer ...
        & VideoImporter ...
        & VideoSelector
    properties (Access = private)
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
            regionGuiPanel = trackingGui.getRegionGuiPanel();
            imageLinker = ImageLinker(imageGui);

            obj@RegionPreviewer(imageLinker, regionGuiPanel);
            obj@VideoImporter([]);
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
            im = obj.getFirstFrame();
            rectanglePositions = BlobDetectorLinker.openFigure(im);
            obj.drawRectanglesByPositions(rectanglePositions);
        end

        function otsuThresholdsPushed(obj, ~, ~)
            if obj.regionExists(OtsuThresholdsGui.title)
                regions = obj.getRegions();
                obj.otsuThresholdRegions(regions);
            end
        end
        function otsuThresholdRegions(obj, regions)
            im = obj.getFirstFrame();
            regionalImages = generateRegionalImages(regions, im);
            fig = generateFigure();
            newThresholds = OtsuThresholdsLinker.openGui(fig, regionalImages);
            RegionUserData.setRegionsThresholds(regions, newThresholds);
        end

        function regionThresholdButtonPushed(obj, source, ~)
            thresholdKeyword = source.UserData;
            if obj.regionExists(thresholdKeyword)
                regionalImages = obj.generateRegionalImages();
                fig = generateFigure();
                newThresholds = AutoThresholdOpener.byKeyword(fig, regionalImages, thresholdKeyword);
                RegionUserData.setRegionsThresholds(obj, newThresholds);
            end
        end
    end
    methods (Access = private)
        function videoFilepathChanged(obj, ~, ~)
            filepath = obj.gui.getVideoFilepath();
            firstFrame = obj.getFirstFrame();

            obj.changeFullImage(firstFrame);
            obj.setFilepath(filepath); % must come before updating frame label
            updateFrameLabel(obj);
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
            set(regions, "Color", RegionColor.queueColor); % color regions as queued

            for index = 1:regionCount
                region = regions(index);
                result = trackAndProcessRegion(obj, region);
                results = [results, result];

                proportionComplete = index / regionCount;
                cancel = multiWaitbar(taskName, proportionComplete);
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

        function regionalImages = generateRegionalImages(obj)
            regions = obj.getRegions();
            im = obj.getFirstFrame();
            regionalImages = generateRegionalImages(regions, im);
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

function updateFrameLabel(obj)
label = generateFrameLabel(obj);
obj.setFrameLabel(label);
end

function label = generateFrameLabel(obj)
frameCount = obj.getFrameCount();
fps = obj.getFps();
label = sprintf("%d Frames (%d FPS)", frameCount, fps);
end

function fig = generateFigure()
fig = uifigure();
colormap(fig, "turbo");
end