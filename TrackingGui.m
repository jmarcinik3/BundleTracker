classdef TrackingGui < RegionTracker & DirectorySelector

    properties (Constant)
        rowHeight = 25;
    end

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
        % main window components
        gridLayout; % uigridlayout containing GUI components
        rightGridLayout % uigridlayout for rightside column

        % components to set processing and tracking methods
        imageLinker;
        regionGuiPanel;
        trackingSelection;
        positiveDirection;
        scaleFactorInputElement;
        fpsInputElement;

        % components to start tracking and save results
        saveFilestemElement;

        % inherited functions
        getRegions;
        changeFullImage;
    end

    methods
        function obj = TrackingGui(varargin)
            p = inputParser;
            addOptional(p, "StartingDirectory", "");
            parse(p, varargin{:});
            startingDirpath = p.Results.StartingDirectory;

            [fig, gl] = generateGridLayout([2, 2]);
            rgl = generateRightGridLayout(gl);
            
            imageGl = ImageGui.generateGridLayout(gl);
            imageGl.Layout.Row = 2;
            imageGl.Layout.Column = 1;
            imageGui = ImageGui(imageGl);
            
            regionGuiPanel = uipanel(rgl, ...
                "Title", "Region Editor", ...
                "TitlePosition", "centertop" ...
                );
            imageLinker = ImageLinker(imageGui);
            regionPreviewer = RegionPreviewer(imageLinker, regionGuiPanel);

            obj@RegionTracker();
            obj@DirectorySelector(gl, {1, [1, 2]});

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

            obj.gridLayout = gl;
            obj.rightGridLayout = rgl;
            obj.imageLinker = imageLinker;
            obj.regionGuiPanel = regionGuiPanel;

            obj.generateTrackingElements(rgl);
            obj.configureDirectorySelector(startingDirpath)
            layoutElements(obj);

            TrackingToolbar(fig, obj);
            figureKeyPressFcn = @(src, ev) keyPressed(obj, src, ev);
            set(fig, "WindowKeyPressFcn", figureKeyPressFcn);
        end
    end

    %% Functions to generate GUI elements
    methods (Access = private)
        function configureDirectorySelector(obj, startingDirpath)
            obj.setDirectoryValueChangedFcn(@obj.directoryValueChanged);
            obj.setDirectory(startingDirpath);
        end
        function generateTrackingElements(obj, gl)
            obj.trackingSelection = generateTrackingSelection(gl);
            obj.positiveDirection = DirectionGui(gl);
            obj.scaleFactorInputElement = generateScaleFactorElement(gl);
            obj.fpsInputElement = generateFpsInputElement(gl);
            obj.saveFilestemElement = generateSaveFilestemElement(gl);
        end
    end

    %% Functions to retrieve GUI elements
    methods (Access = protected)
        function fig = getFigure(obj)
            gl = obj.getGridLayout();
            fig = ancestor(gl, "figure");
        end
    end
    methods (Access = private)
        % grid layouts
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function rgl = getRightGridLayout(obj)
            rgl = obj.rightGridLayout;
        end
        function imageGui = getImageLinker(obj)
            imageGui = obj.imageLinker;
        end
        function panel = getRegionPanel(obj)
            panel = obj.regionGuiPanel;
        end

        % components to set postprocessing methods
        function elem = getTrackingSelectionElement(obj)
            elem = obj.trackingSelection;
        end
        function elem = getPositiveDirectionElement(obj)
            elem = obj.positiveDirection.getGridLayout();
        end
        function elem = getScaleFactorInputElement(obj)
            elem = obj.scaleFactorInputElement;
        end
        function elem = getFpsInputElement(obj)
            elem = obj.fpsInputElement;
        end

        % other components
        function elem = getSaveFilestemElement(obj)
            elem = obj.saveFilestemElement;
        end
    end

    %% Functions to retrieve state information
    methods (Access = private)
        function val = getTrackingSelection(obj)
            val = string(obj.trackingSelection.Value);
        end

        % ...for postprocessing
        function loc = getPositiveDirection(obj)
            loc = obj.positiveDirection.getLocation();
        end
        function factor = getScaleFactor(obj)
            gl = obj.scaleFactorInputElement;
            textbox = gl.Children(2);
            factor = textbox.Value;
        end
        function err = getScaleFactorError(obj)
            gl = obj.scaleFactorInputElement;
            textbox = gl.Children(4);
            err = textbox.Value;
        end
        function fps = getFps(obj)
            gl = obj.fpsInputElement;
            textbox = gl.Children(2);
            fps = textbox.Value;
        end
        function stem = getSaveFilestem(obj)
            gl = obj.saveFilestemElement;
            textbox = gl.Children(2);
            stem = textbox.Value;
        end

        % ...for image
        function filepath = generateSaveFilepath(obj)
            directoryPath = obj.getDirectoryPath();
            filestem = obj.getSaveFilestem();
            filename = sprintf("%s%s.mat", filestem);
            filepath = fullfile(directoryPath, filename);
        end
    end

    %% Functions to update state of GUI
    methods
        function exportImageIfPossible(obj, ~, ~)
            imageLinker = obj.getImageLinker();
            directoryPath = obj.getDirectoryPath();
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
                obj.throwAlertMessage( ...
                    "No cells selected!", ...
                    "Start Tracking" ...
                    );
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
            results= obj.trackAndProcessRegions(regions);
        end
        function prepareTracking(obj)
            filepaths = obj.getFilepaths();
            trackingMode = obj.getTrackingSelection();
            initialResult = obj.generateInitialResult();
            obj.setFilepaths(filepaths);
            obj.setTrackingMode(trackingMode);
            obj.setInitialResult(initialResult);
        end
        function result = generateInitialResult(obj)
            result = struct( ...
                "DirectoryPath", obj.getDirectoryPath(), ...
                "TrackingMode", obj.getTrackingSelection(), ...
                "Direction", obj.getPositiveDirection(), ...
                "ScaleFactor", obj.getScaleFactor(), ...
                "ScaleFactorError", obj.getScaleFactorError(), ...
                "Fps", obj.getFps() ...
                );
        end
        function filepath = saveResults(obj, results)
            filepath = obj.generateSaveFilepath();
            save(filepath, "results");
        end

        function directoryValueChanged(obj, ~, ~)
            obj.updateImageForDirectory();
        end
        function updateImageForDirectory(obj)
            im = obj.getFirstImage();
            obj.changeFullImage(im);
        end
        function throwAlertMessage(obj, message, title)
            fig = obj.getFigure();
            uialert(fig, message, title);
        end
    end
end



%% Function to lay out elements in GUI
% Lays out elements in GUI. Elements are instantiated and stored in
% constructor of TrackingGui.
%
% Arguments
%
% * TrackingGui |gui|: GUI to lay out elements in
%
% Returns void
function layoutElements(gui)
gl = gui.getGridLayout();
set(gl, ...
    "ColumnWidth", {'3x', '1x'}, ...
    "RowHeight", {TrackingGui.rowHeight, '1x'} ...
    );

layoutTopElements(gui);
layoutRightsideElements(gui);
end

function layoutTopElements(gui)
rowHeight = TrackingGui.rowHeight;
directorySelector = gui.getDirectorySelectionElement();
set(directorySelector, "RowHeight", rowHeight);
end

function layoutRightsideElements(gui)
rowHeight = TrackingGui.rowHeight;
rgl = gui.getRightGridLayout();

positiveDirectionGroup = gui.getPositiveDirectionElement();
scaleFactorElement = gui.getScaleFactorInputElement();
fpsInputElement = gui.getFpsInputElement();
trackingDropdown = gui.getTrackingSelectionElement();
saveFilestemElement = gui.getSaveFilestemElement();
regionGuiPanel = gui.getRegionPanel();

trackingDropdown.Layout.Row = 1;
positiveDirectionGroup.Layout.Row = 2;
scaleFactorElement.Layout.Row = 3;
fpsInputElement.Layout.Row = 4;
saveFilestemElement.Layout.Row = 5;
regionGuiPanel.Layout.Row = 6;

set(scaleFactorElement, ...
    "RowHeight", rowHeight, ...
    "ColumnWidth", {'3x', '3x', '1x', '2x'} ...
    );
set(fpsInputElement, ...
    "RowHeight", rowHeight, ...
    "ColumnWidth", {'1x', '2x'} ...
    );
set(saveFilestemElement, ...
    "RowHeight", rowHeight, ...
    "ColumnWidth", {'1x', '2x'} ...
    );

rgl.RowHeight = num2cell(rowHeight * ones(1, 6));
rgl.RowHeight{2} = 'fit';
rgl.RowHeight{6} = '1x';
end

function [fig, gl] = generateGridLayout(size)
fig = uifigure;
position = [300, 200, 1000, 700];
set(fig, ...
    "Name", "Hair-Bundle Tracking", ...
    "Position", position ...
    );
gl = uigridlayout(fig, size);
end

function rgl = generateRightGridLayout(gl)
rgl = uigridlayout(gl, [6, 1]);
rgl.Layout.Row = 2;
rgl.Layout.Column = 2;
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

%% Function to generate tracking method dropdown
% Generates dropdown menu allowing user to select tracking method (e.g.
% "Centroid")
%
% Arguments
%
% * uigridlayout |gl|: layout to add dropdown in
%
% Returns uiddropdown
function dropdown = generateTrackingSelection(gl)
dropdown = uidropdown(gl);
dropdown.Items = TrackingAlgorithms.keywords;
end

%% Function to generate FPS input
% Generates edit field (with label) allowing user to set FPS
%
% Arguments
%
% * uigridlayout |parent|: layout to add edit fields in
%
% Returns uigridlayout composed of [uilabel, uieditfield("numeric")]
function gl = generateFpsInputElement(parent)
gl = uigridlayout(parent, [1 2]);
gl.Padding = [0 0 0 0];

lbl = uilabel(gl);
lbl.Text = "FPS:"; % label
tb = uieditfield(gl, "numeric");
tb.Value = 1000; % default FPS

lbl.Layout.Column = 1;
tb.Layout.Column = 2;
end

%% Function to generate scale factor input
% Generates edit fields (with labels) allowing user to set scaling
%
% Arguments
%
% * uigridlayout |parent|: layout to add edit fields in
%
% Returns uigridlayout composed of [uilabel, uieditfield("numeric"),
% uilabel, uieditfield("numeric")]
function gl = generateScaleFactorElement(parent)
gl = uigridlayout(parent, [1 4]);
gl.Padding = [0 0 0 0];

lbl1 = uilabel(gl);
lbl1.Text = "length/px:"; % label for scaling
tb1 = uieditfield(gl, "numeric");
tb1.Value = 108.3; % default scaling

lbl2 = uilabel(gl);
lbl2.Text = "±"; % label for error
tb2 = uieditfield(gl, "numeric");
tb2.Value = 0.8; % default error

lbl1.Layout.Column = 1;
tb1.Layout.Column = 2;
lbl2.Layout.Column = 3;
tb2.Layout.Column = 4;
end

%% Function to generate save filestem input
% Generates edit field (with label) allowing user to set FPS
%
% Arguments
%
% * uigridlayout |parent|: layout to add edit field in
%
% Returns uigridlayout composed of [uilabel, uieditfield("text")]
function gl = generateSaveFilestemElement(parent)
gl = uigridlayout(parent, [1 2]);
gl.Padding = [0 0 0 0];

lbl = uilabel(gl);
lbl.Text = "Filestem:"; % label
tb = uieditfield(gl, "text");
tb.Value = "results"; % default value

lbl.Layout.Column = 1;
tb.Layout.Column = 2;
end
