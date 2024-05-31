classdef TrackingLinker < RegionPreviewer ...
        & VideoImporter ...
        & VideoSelector ...
        & AlertThrower

    properties (Constant)
        extensions = {'*.mat', "MATLAB Structure"};
        videoExtensions = { ...
            '*.avi', "Audio Video Interleave"; ...
            '*.mj2', "Motion JPEG 2000"; ...
            };
    end

    properties (Access = private)
        gui;
    end

    methods
        function obj = TrackingLinker(trackingGui)
            videoGui = trackingGui.getVideoGui();
            imageGui = trackingGui.getImageGui();
            regionGui = trackingGui.getRegionGui();

            obj@RegionPreviewer(regionGui, imageGui);
            obj@VideoImporter();
            obj@VideoSelector(videoGui);

            fig = trackingGui.getFigure();
            set(videoGui.getFilepathField(), "ValueChangedFcn", @obj.videoFilepathChanged);
            set(imageGui.getAxis(), "ContextMenu", generateImageMenu(obj, fig));
            set(regionGui.getAxis(), "ContextMenu", generateRegionMenu(obj, fig));
            set(fig, ...
                "WindowKeyPressFcn", @(src, ev) keyPress(obj, src, ev), ...
                "WindowButtonDownFcn", @(src, ev) buttonDown(obj, src, ev) ...
                );
            TrackingToolbar(fig, obj);
            TrackingMenu(fig, obj);

            obj.gui = trackingGui;
            drawnow;
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
                obj.importRegions(filepath);
            end
        end
        function exportImageButtonPushed(obj, ~, ~)
            obj.exportImage();
        end
        function exportRegionImageButtonPushed(obj, ~, ~)
            obj.exportRegionImage();
        end
        function saveRegionVideoButtonPushed(obj, ~, ~)
            obj.exportRegionVideo();
        end

        function trackButtonPushed(obj, ~, ~)
            if obj.regionExists("Start Tracking")
                obj.trackAndExportRegions();
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
                regionalImages = generateRegionalImages( ...
                    obj.getRegions(), ...
                    obj.getFirstFrame() ...
                    );
                newThresholds = AutoThresholdOpener.openFigure( ...
                    generateAutothresholdFigure(), ...
                    regionalImages ...
                    );
                RegionUserData.setRegionsThresholds(obj, newThresholds);
            end
        end

        function openWaterfallPlotPushed(obj, ~, ~)
            startingDirectory = obj.gui.getDirectoryPath();
            extensions = TrackingLinker.extensions;
            filepath = uigetfilepath(extensions, "Create Waterfall Plot", startingDirectory);
            if isfile(filepath)
                resultsParser = ResultsParser(filepath);
                WaterfallLinker.openFigure( ...
                    resultsParser.getProcessedTrace(), ...
                    resultsParser.getTime() ...
                    );
            end
        end
    end

    %% Functions to be called as part of API
    methods
        function importRegions(obj, filepath)
            resultsParser = ResultsParser(filepath);
            taskName = 'Importing Regions';
            multiWaitbar(taskName, 0, 'CanCancel', 'on');
            regionCount = resultsParser.getRegionCount();
            regions = images.roi.Rectangle.empty(0, regionCount);

            for index = 1:regionCount
                regionInfo = resultsParser.getRegion(index);
                region = obj.importRegion(regionInfo);
                obj.configureRegionToGui(region);
                RegionUserData.configureByResultsParser(region, resultsParser, index);
                regions(index) = region;

                proportionComplete = index / regionCount;
                cancel = multiWaitbar(taskName, proportionComplete);
                if cancel
                    deleteRegions(regions);
                    break;
                end
            end

            if ~cancel
                obj.setScaleFactor( ...
                    resultsParser.getScaleFactor(), ...
                    resultsParser.getScaleFactorError() ...
                    );
            end

            multiWaitbar(taskName, 'Close');
        end

        function exportImage(obj, path)
            if nargin < 2
                path = obj.gui.getDirectoryPath();
            end
            exportImage@RegionPreviewer(obj, path);
        end
        function exportRegionImage(obj, path)
            if nargin < 2
                path = obj.gui.getDirectoryPath();
            end
            exportRegionImage@RegionPreviewer(obj, path);
        end
        function exportRegionVideo(obj, path)
            if nargin < 2
                path = obj.gui.getDirectoryPath();
            end
            [filepath, isfilepath] = uiputfilepath( ...
                obj.videoExtensions, ...
                "Export as Video", ...
                path ...
                );

            if isfilepath
                activeRegion = obj.getActiveRegion();
                ims = obj.getVideoInRegion(activeRegion);
                profile = generateProfile(filepath);
                videoWriter = VideoWriter(filepath, profile);
                set(videoWriter, "FrameRate", obj.getFps());
                
                imClass = determineImageClass(profile, class(ims));
                ims = Preprocessor.fromRegion(activeRegion).preprocess(ims);
                ims = imageToClass(ims, imClass);
                export3dMatrixAsVideo(ims, videoWriter);
            end
        end

        function trackAndExportRegions(obj, filepath)
            [cancel, results] = obj.trackAndProcess();
            if cancel
                obj.throwAlertMessage("Tracking Canceled!", "Start Tracking");
                return;
            end

            if nargin == 1
                obj.trackingCompleted(results);
            elseif nargin == 2
                save(filepath, "results");
            end
        end
    end
    methods (Access = private)
        function videoFilepathChanged(obj, ~, ~)
            filepath = obj.gui.getVideoFilepath();
            if numel(filepath) >= 1 && isfile(filepath)
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
        end
        function setScaleFactor(obj, scaleFactor, scaleFactorError)
            gui = obj.gui;
            factorElement = gui.getScaleFactorElement();
            errorElement = gui.getScaleFactorErrorElement();
            set(factorElement, "Value", scaleFactor);
            set(errorElement, "Value", scaleFactorError);
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

            saveResults(results, resultsFilepath);
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
    end

    %% Helper functions to call methods from properties
    methods (Access = protected)
        function fig = getFigure(obj)
            fig = obj.gui.getFigure();
        end
    end
end



function label = generateFrameLabel(videoReader)
frameCount = get(videoReader, "NumFrames");
fps = get(videoReader, "FrameRate");
h = get(videoReader, "Height");
w = get(videoReader, "Width");
label = sprintf("%d Frames (%d FPS, %dx%d)", frameCount, fps, h, w);
end
function maxIntensity = getMaximumIntensity(videoProfile)
switch string(videoProfile)
    case {"Mono8 Signed", "RGB24 Signed"}, maxIntensity = 2^7;
    case {"Mono8", "RGB24", "Grayscale"}, maxIntensity = 2^8;
    case {"Mono16 Signed", "RGB48 Signed"}, maxIntensity = 2^15;
    case {"Mono16", "RGB48"}, maxIntensity = 2^16;
end
end

function profile = generateProfile(filepath)
[~, ~, fileExtension] = fileparts(filepath);
switch string(fileExtension)
    case ".avi"
        profile = "Grayscale AVI";
    case ".mj2"
        profile = "Archival";
end
end
function imClass = determineImageClass(profile, imClass)
switch string(profile)
    case "Archival"
        if strcmp(imClass, "double")
            imClass = "uint16";
        end
    case "Grayscale AVI"
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
function fig = generateBlobDetectionFigure()
figDefaults = namedargs2cell(SettingsParser.getBlobDetectionFigureDefaults());
fig = generateFigure(figDefaults{:});
end
function fig = generateAutothresholdFigure()
figDefaults = namedargs2cell(SettingsParser.getAutothresholdFigureDefaults());
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

function saveResults(results, resultsFilepath)
if ischar(resultsFilepath) || isstring(resultsFilepath)
    save(resultsFilepath, "results");
end
end
function export3dMatrixAsVideo(ims, videoWriter)
frameCount = size(ims, 3);
open(videoWriter);
for frameIndex = 1:frameCount
    im = ims(:, :, frameIndex);
    writeVideo(videoWriter, im);
end
close(videoWriter);
end



function cm = generateImageMenu(obj, fig)
cm = uicontextmenu(fig);
uimenu(cm, ...
    "Text", "Export as Image", ...
    "MenuSelectedFcn", @obj.exportImageButtonPushed ...
    );
end
function cm = generateRegionMenu(obj, fig)
cm = uicontextmenu(fig);
uimenu(cm, ...
    "Text", "Export as Image", ...
    "MenuSelectedFcn", @obj.exportRegionImageButtonPushed ...
    );
uimenu(cm, ...
    "Text", "Export as Video", ...
    "MenuSelectedFcn", @obj.saveRegionVideoButtonPushed ...
    );
end
