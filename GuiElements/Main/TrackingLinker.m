classdef TrackingLinker < RegionTracker
    properties
        getActiveRegion;
        setPreviousRegionVisible;
        setNextRegionVisible;
        setRegionShape;
        bringRegionToFront;
        bringRegionForward;
        sendRegionBackward;
        sendRegionToBack;
    end

    properties (Access = private)
        % GUI components
        gui;
        videoSelector;
        imageLinker;

        % inherited functions
        getRegions;
        changeFullImage;
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
            regionPreviewer = RegionPreviewer(imageLinker, regionGuiPanel);

            obj@RegionTracker();
            obj.videoSelector = VideoSelector( ...
                directoryGui, ...
                @obj.videoFilepathChanged ...
                );

            % inherited getters
            obj.getActiveRegion = @regionPreviewer.getActiveRegion;
            obj.getRegions = @regionPreviewer.getRegions;

            % inherited setters
            obj.changeFullImage = @regionPreviewer.changeFullImage;
            obj.setPreviousRegionVisible = @regionPreviewer.setPreviousRegionVisible;
            obj.setNextRegionVisible = @regionPreviewer.setNextRegionVisible;
            obj.setRegionShape = @regionPreviewer.setRegionShape;

            obj.bringRegionToFront = @regionPreviewer.bringRegionToFront;
            obj.bringRegionForward = @regionPreviewer.bringRegionForward;
            obj.sendRegionBackward = @regionPreviewer.sendRegionBackward;
            obj.sendRegionToBack = @regionPreviewer.sendRegionToBack;

            obj.gui = trackingGui;
            obj.imageLinker = imageLinker;

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
    methods (Access = private)
        function linker = getImageLinker(obj)
            linker = obj.imageLinker;
        end
    end

    %% Functions to update state of GUI
    methods
        function exportImageIfPossible(obj, ~, ~)
            imageLinker = obj.getImageLinker();
            directoryPath = obj.gui.getDirectoryPath();
            imageLinker.exportImageIfPossible(directoryPath);
        end
        function trackButtonPushed(obj, ~, ~)
            if obj.regionExists()
                obj.trackAndSaveRegions();
            end
        end
    end
    methods (Access = private)
        function exists = regionExists(obj)
            regions = obj.getRegions();
            count = numel(regions);
            exists = count >= 1;
            if ~exists
                obj.throwAlertMessage("No cells selected!", "Start Tracking");
            end
        end
        function trackAndSaveRegions(obj)
            results = obj.trackAndProcess();
            if obj.trackingWasCompleted()
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
            obj.prepareTracking();
            regions = obj.getRegions();
            results = obj.trackAndProcessRegions(regions);
        end
        function prepareTracking(obj)
            trackingMode = obj.gui.getTrackingMode();
            initialResult = obj.generateInitialResult();
            obj.setTrackingMode(trackingMode);
            obj.setInitialResult(initialResult);
        end
        function filepath = saveResults(obj, results)
            filepath = obj.gui.generateSaveFilepath();
            save(filepath, "results");
        end
        function result = generateInitialResult(obj)
            gui = obj.gui;
            result = struct( ...
                "DirectoryPath", gui.getDirectoryPath(), ...
                "TrackingMode", gui.getTrackingMode(), ...
                "AngleMode", gui.getAngleMode(), ...
                "Direction", gui.getPositiveDirection(), ...
                "ScaleFactor", gui.getScaleFactor(), ...
                "ScaleFactorError", gui.getScaleFactorError(), ...
                "Fps", obj.getFps() ...
                );
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
count = resultsParser.getRegionCount();
title = sprintf("Tracking Completed (%d)", count);
message = trackingCompletedMessage(results, filepath);
msgbox(message, title);
end

function message = trackingCompletedMessage(results, filepath)
resultsParser = ResultsParser(results);
count = resultsParser.getRegionCount();
trackingMode = resultsParser.getTrackingMode();
positiveDirection = resultsParser.getPositiveDirection();
fps = resultsParser.getFps();

savedMsg = sprintf("Results saved to %s", filepath);
countMsg = sprintf("Cell Count: %d", count);
modeMsg = sprintf("Tracking Algorithm: %s", trackingMode);
fpsMsg = sprintf("FPS: %d", fps);
directionMsg = sprintf("Positive Direction: %s", positiveDirection);
message = [savedMsg, countMsg, modeMsg, directionMsg, fpsMsg];
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
