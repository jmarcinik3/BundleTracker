classdef TrackingLinker < RegionPreviewer ...
        & VideoImporter ...
        & VideoSelector ...
        & AlertThrower

    properties (Constant)
        extensions = {'*.mat', "MATLAB Structure"};
        videoExtensions = { ...
            '*.gif', "Graphic Interchange Format"; ...
            '*.avi', "Audio Video Interleave"; ...
            '*.mj2', "Motion JPEG 2000"; ...
            };
    end

    properties
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
            set(imageGui.getAxis(), "ContextMenu", generateImageGuiMenu(obj, fig));
            set(regionGui.getAxis(), "ContextMenu", generateRegionGuiMenu(obj, fig));
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
        function applyRegionsButtonPushed(obj, source, ~)
            title = SettingsParser.getApplyRegionLabel();
            if obj.regionExists(title)
                applyKeyword = source.UserData;
                regions = obj.getRegions();
                obj.applyRegions(regions, applyKeyword);
            end
        end
        function resetRegionsButtonPushed(obj, source, ~)
            title = SettingsParser.getResetRegionLabel();
            if obj.regionExists(title)
                resetKeyword = source.UserData;
                regions = obj.getRegions();
                obj.resetRegionsToDefaults(regions, resetKeyword);
            end
        end

        function importRegionsButtonPushed(obj, ~, ~)
            previousDirectoryPath = obj.gui.getDirectoryPath();
            extensions = TrackingLinker.extensions;
            title = SettingsParser.getImportRegionsLabel();
            filepath = uigetfilepath(extensions, title, previousDirectoryPath);
            if isfile(filepath)
                obj.importRegions(filepath);
            end
        end
        function exportImageButtonPushed(obj, ~, ~)
            obj.exportFullImage();
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
                newThresholds = AutoThresholderOpener.openFigure( ...
                    generateAutothresholdFigure(), ...
                    regionalImages ...
                    );
                RegionUserData.setRegionsThresholds(obj, newThresholds);
            end
        end
        
        function openProbeCalibratorPushed(obj, ~, ~)
            startingDirectory = obj.gui.getDirectoryPath();
            filepath = uigetfilepath( ...
                TrackingLinker.extensions, ...
                "Calibrate Probe", ...
                startingDirectory ...
                );
            if isfile(filepath)
                resultsParser = ResultsParser(filepath);
                regionCount = resultsParser.getRegionCount();
                if regionCount ~= 1
                    obj.throwAlertMessage( ...
                        "Please select a file with exactly one ROI!", ...
                        "Probe Calibrator" ...
                        );
                    return;
                end
                ProbeCalibratorLinker.openFigure(resultsParser);
            end
        end
        function openRoiPlotPushed(obj, ~, ~)
            startingDirectory = obj.gui.getDirectoryPath();
            filepath = uigetfilepath( ...
                TrackingLinker.extensions, ...
                "Create ROI Plot", ...
                startingDirectory ...
                );
            if isfile(filepath)
                resultsParser = ResultsParser(filepath);
                fig = uifigure("Name", "ROI Plot");
                RoiArrowPlot(fig, resultsParser);
            end
        end
        function openWaterfallPlotPushed(obj, ~, ~)
            startingDirectory = obj.gui.getDirectoryPath();
            filepath = uigetfilepath( ...
                TrackingLinker.extensions, ...
                "Create Waterfall Plot", ...
                startingDirectory ...
                );
            if isfile(filepath)
                resultsParser = ResultsParser(filepath);
                WaterfallLinker.openFigure( ...
                    resultsParser.getProcessedTrace(), ...
                    resultsParser.getTime() ...
                    );
            end
        end
        function openDetrenderButtonPushed(obj, ~, ~)
            startingDirectory = obj.gui.getDirectoryPath();
            title = SettingsParser.getDetrendFigureDefaults().Name;
            filepath = uigetfilepath( ...
                TrackingLinker.extensions, ...
                title, ...
                startingDirectory ...
                );
            if isfile(filepath)
                DetrenderOpener.openFigure( ...
                    generateDetrendFigure(), ...
                    filepath ...
                    );
            end
        end
        function openRotatorButtonPushed(obj, ~, ~)
            startingDirectory = obj.gui.getDirectoryPath();
            title = SettingsParser.getRotateFigureDefaults().Name;
            filepath = uigetfilepath( ...
                TrackingLinker.extensions, ...
                title, ...
                startingDirectory ...
                );
            if isfile(filepath)
                Rotator2dOpener.openFigure( ...
                    generateRotateFigure(), ...
                    filepath ...
                    );
            end
        end
    end

    %% Functions to be called as part of API
    methods
        function applyRegions(obj, regions, keyword)
            for index = 1:numel(regions)
                region = regions(index);
                applyByKeyword(obj, keyword, region);
            end
        end
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

        function exportFullImage(obj, path)
            if nargin < 2
                path = obj.gui.getDirectoryPath();
            end
            exportFullImage@RegionPreviewer(obj, path);
        end
        function exportRegionImage(obj, path)
            if nargin < 2
                path = obj.gui.getDirectoryPath();
            end
            exportRegionImage@RegionPreviewer(obj, path);
        end
        function exportRegionVideo(obj)            
            [cancel, ims] = generatePreprocessedRegion( ...
                obj, ...
                obj.getActiveRegion() ...
                );
            if cancel
                return;
            end

            fig = obj.getFigure();
            ax = generateAnimatorAxis("Export as Video");

            delayTime = 1 / obj.getFps();
            duration = obj.getDuration();
            t = 0:delayTime:duration-delayTime;

            ims = gray2rgb(ims, fig);
            AxisVideoAnimator( ...
                ax, ...
                t, ...
                ims, ...
                "PlaybackFps", obj.getFps() ...
                );
        end

        function trackAndExportRegions(obj, filepath)
            if ~obj.videoIsImported()
                obj.throwAlertMessage("Video is still importing!", "Start Tracking");
                return;
            end

            [cancel, results] = trackAndProcess(obj);
            if cancel
                obj.throwAlertMessage("Tracking Canceled!", "Start Tracking");
                return;
            end

            metadata = obj.generateMetadata();
            if nargin == 1
                trackingCompleted(obj, results, metadata);
            elseif nargin == 2
                resultsParser = ResultsParser.fromSeparate(results, metadata);
                resultsParser.export(filepath);
            end
        end
    end
    methods (Access = private)
        function videoFilepathChanged(obj, ~, ~)
            filepath = obj.gui.getVideoFilepath();
            if numel(filepath) >= 1 && isfile(filepath)
                videoReader = VideoReader(filepath);
                firstFrame = read(videoReader, 1);
                label = generateFrameLabel(videoReader);

                obj.changeImage(firstFrame);
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
                "ScaleFactor", gui.getScaleFactor(), ...
                "ScaleFactorError", gui.getScaleFactorError(), ...
                "Fps", obj.getFps() ...
                );
        end
        function result = generateMetadata(obj)
            result = struct("FirstFrame", obj.getFirstFrame());
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

    %% Helper functions to call methods from properties
    methods (Access = protected)
        function fig = getFigure(obj)
            fig = obj.gui.getFigure();
        end
        function gui = getImageGui(obj)
            gui = obj.gui.getImageGui();
        end

        function angleMode = getAngleMode(obj)
            angleMode = obj.getImageGui().getAngleMode();
        end
        function detrend = getDetrendMode(obj)
            detrend = obj.getImageGui().getDetrendMode();
        end
        function invert = getInvert(obj)
            invert = obj.getImageGui().getInvert();
        end
        function direction = getPositiveDirection(obj)
            direction = obj.getImageGui().getPositiveDirection();
        end
        function thresholds = getThresholds(obj)
            thresholds = obj.getImageGui().getThresholds();
        end
        function trackingMode = getTrackingMode(obj)
            trackingMode = obj.getImageGui().getTrackingMode();
        end
        function smoothing = getSmoothing(obj)
            smoothing = obj.getImageGui().getSmoothing();
        end
    end
end



function label = generateFrameLabel(videoReader)
frameCount = get(videoReader, "NumFrames");
fps = get(videoReader, "FrameRate");
w = get(videoReader, "Width");
h = get(videoReader, "Height");
bitDepth = get(videoReader, "BitsPerPixel");
label = sprintf( ...
    "%d Frames (%d FPS, %dx%d, %d-bit)", ...
    frameCount, fps, w, h, bitDepth ...
    );
end
function [cancel, ims] = generatePreprocessedRegion(obj, region)
ims = obj.getVideoInRegion(region);
imClass = class(ims);
[cancel, ims] = preprocessRegion( ...
    im2double(ims), ...
    Preprocessor.fromRegion(region) ...
    );
ims = imageToClass(ims, imClass);
end

function ax = generateAnimatorAxis(title)
    fig = generateFigure("Name", title);
    gl = uigridlayout(fig, [1, 1]);
    ax = uiaxes(gl);
end

function fig = generateBlobDetectionFigure()
figDefaults = namedargs2cell(SettingsParser.getBlobDetectionFigureDefaults());
fig = generateFigure(figDefaults{:});
end
function fig = generateAutothresholdFigure()
figDefaults = namedargs2cell(SettingsParser.getAutothresholdFigureDefaults());
fig = generateFigure(figDefaults{:});
end
function fig = generateDetrendFigure()
figDefaults = namedargs2cell(SettingsParser.getDetrendFigureDefaults());
fig = generateFigure(figDefaults{:});
end
function fig = generateRotateFigure()
figDefaults = namedargs2cell(SettingsParser.getRotateFigureDefaults());
fig = generateFigure(figDefaults{:});
end

function cm = generateImageGuiMenu(obj, fig)
cm = uicontextmenu(fig);
generateApplyMenu(cm, obj);
generateResetMenu(cm, obj);
uimenu(cm, ...
    "Text", SettingsParser.getExportAxisLabel(), ...
    "MenuSelectedFcn", @obj.exportImageButtonPushed, ...
    "Accelerator", "S" ...
    );
uimenu(cm, ...
    "Text", "Remove All Regions     Ctrl+Shift+Del", ...
    "MenuSelectedFcn", @obj.clearRegions ...
    );
end
function generateApplyMenu(parentMenu, obj)
applyKeywords = RegionUserData.keywords;
m = uimenu(parentMenu, "Text", SettingsParser.getApplyRegionLabel());
for index = 1:numel(applyKeywords)
    applyKeyword = applyKeywords(index);
    uimenu(m, ...
        "Text", applyKeyword, ...
        "MenuSelectedFcn", @obj.applyRegionsButtonPushed, ...
        "UserData", applyKeyword ...
        );
end
end
function generateResetMenu(parentMenu, obj)
resetKeywords = RegionUserData.keywords;
m = uimenu(parentMenu, "Text", SettingsParser.getResetRegionLabel());
for index = 1:numel(resetKeywords)
    resetKeyword = resetKeywords(index);
    uimenu(m, ...
        "Text", resetKeyword, ...
        "MenuSelectedFcn", @obj.resetRegionsButtonPushed, ...
        "UserData", resetKeyword ...
        );
end
end

function cm = generateRegionGuiMenu(obj, fig)
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

function applyByKeyword(obj, keywords, region)
if keywords == RegionUserData.allKeyword
    applyByKeyword(obj, RegionUserData.keywords(2:end), region);
    return;
end
if numel(keywords) >= 2
    for keyword = keywords
        applyByKeyword(obj, keyword, region);
    end
    return;
end

value = getByKeyword(obj, keywords);
RegionUserData(region).setByKeyword(keywords, value);
end

function value = getByKeyword(obj, keyword)
switch keyword
    case RegionUserData.angleModeKeyword
        value = obj.getAngleMode();
    case RegionUserData.detrendModeKeyword
        value = obj.getDetrendMode();
    case RegionUserData.invertKeyword
        value = obj.getInvert();
    case RegionUserData.positiveDirectionKeyword
        value = obj.getPositiveDirection();
    case RegionUserData.smoothingKeyword
        value = obj.getSmoothing();
    case RegionUserData.thresholdsKeyword
        value = obj.getThresholds();
    case RegionUserData.trackingModeKeyword
        value = obj.getTrackingMode();
end
end
