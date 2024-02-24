classdef TrackingGui < RegionTracker & RegionPreviewer & DirectorySelector
    properties (Constant)
        rowHeight = 25;
    end

    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>

        % main window components
        gridLayout; % uigridlayout containing GUI components
        rightGridLayout % uigridlayout for rightside column

        % components to set processing and tracking methods
        trackingSelection;
        kinociliumLocation;
        scaleFactorInputElement;
        fpsInputElement;

        % components to start tracking and save results
        trackButton;
        saveImageButton;
        saveFilestemElement;
    end

    methods
        function obj = TrackingGui(varargin)
            p = inputParser;
            addOptional(p, "StartingDirectory", "");
            addOptional(p, "EnableZoom", true);
            parse(p, varargin{:});
            startingDirpath = p.Results.StartingDirectory;
            enableZoom = p.Results.EnableZoom;

            gl = generateGridLayout([2, 2]);
            rgl = generateRightGridLayout(gl);
            
            obj@RegionTracker();
            obj@DirectorySelector(gl, {1, [1, 2]});
            obj@RegionPreviewer(gl, {2, 1}, "EnableZoom", enableZoom);
            
            obj.gridLayout = gl;
            obj.rightGridLayout = rgl;

            obj.generateSimpleElements(rgl);
            obj.configureDirectorySelector(startingDirpath)
            layoutElements(obj);

            fig = obj.getFigure();
            TrackingToolbar(fig, obj);
        end
    end

    %% Functions to generate GUI elements
    methods (Access = private)
        function configureDirectorySelector(obj, startingDirpath)
            obj.setDirectoryValueChangedFcn(@obj.directoryValueChanged);
            obj.setDirectory(startingDirpath);
        end
        function generateSimpleElements(obj, gl)
            obj.generateTrackingElements(gl);
            obj.generatePostTrackingElements(gl);
        end
        function generateTrackingElements(obj, gl)
            obj.trackingSelection = generateTrackingSelection(gl);
            obj.kinociliumLocation = KinociliumLocation(gl);
            obj.scaleFactorInputElement = generateScaleFactorElement(gl);
            obj.fpsInputElement = generateFpsInputElement(gl);
            obj.saveFilestemElement = generateSaveFilestemElement(gl);
        end
        function generatePostTrackingElements(obj, gl)
            obj.trackButton = obj.generateTrackButton(gl);
            obj.saveImageButton = obj.generateSaveImageButton(gl);
        end
        function trackButton = generateTrackButton(obj, gl)
            trackButton = generateTrackButton(gl);
            set(trackButton, "ButtonPushedFcn", @obj.trackButtonPushed);
        end
        function saveImageButton = generateSaveImageButton(obj, gl)
            saveImageButton = generateSaveImageButton(gl);
            set(saveImageButton, "ButtonPushedFcn", @obj.saveImageButtonPushed);
            obj.saveImageButton = saveImageButton;
        end
    end

    %% Functions to retrieve GUI elements
    methods (Access = protected)
        function fig = getFigure(obj)
            gl = obj.getGridLayout();
            fig = ancestor(gl, "figure");
        end
        function elem = getDirectorySelectionElement(obj)
            elem = getDirectorySelectionElement@DirectorySelector(obj);
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

        % components to set postprocessing methods
        function elem = getTrackingSelectionElement(obj)
            elem = obj.trackingSelection;
        end
        function elem = getKinociliumLocationElement(obj)
            elem = obj.kinociliumLocation.getElement();
        end
        function elem = getScaleFactorInputElement(obj)
            elem = obj.scaleFactorInputElement;
        end
        function elem = getFpsInputElement(obj)
            elem = obj.fpsInputElement;
        end

        % button to starting tracking and elements for saving
        function elem = getTrackButton(obj)
            elem = obj.trackButton;
        end
        function elem = getSaveImageButton(obj)
            elem = obj.saveImageButton;
        end
        function elem = getSaveFilestemElement(obj)
            elem = obj.saveFilestemElement;
        end
    end

    %% Functions to retrieve state information
    methods (Access = private)
        function val = getTrackingSelection(obj)
            val = obj.trackingSelection.Value;
        end

        % ...for postprocessing
        function loc = getKinociliumLocation(obj)
            loc = obj.kinociliumLocation.getLocation();
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
    methods (Access = private)
        function trackButtonPushed(obj, ~, ~)
            if obj.regionExists()
                obj.trackAndSaveRegions();
            end
        end
        function exists = regionExists(obj)
            regions = obj.getRegions();
            count = numel(regions);
            exists = count >= 1;
            if ~exists
                obj.throwAlertMessage("No cells selected!", "Track");
            end
        end
        function trackAndSaveRegions(obj)
            results = obj.trackAndProcess();
            obj.saveResults(results)
            obj.exportImageIfPossible();
        end
        function results = trackAndProcess(obj)
            obj.prepareTracking();
            regions = obj.getRegions();
            results = obj.trackAndProcessRegions(regions);
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
                "KinociliumLocation", obj.getKinociliumLocation(), ...
                "ScaleFactor", obj.getScaleFactor(), ...
                "ScaleFactorError", obj.getScaleFactorError(), ...
                "Fps", obj.getFps() ...
                );
        end
        function saveResults(obj, results)
            filepath = obj.generateSaveFilepath();
            save(filepath, "results");
        end

        function saveImageButtonPushed(obj, ~, ~)
            obj.exportImageIfPossible();
        end
        function exportImageIfPossible(obj)
            imageGui = obj.getImageGui();
            directoryPath = obj.getDirectoryPath();
            imageGui.exportImageIfPossible(directoryPath);
        end

        function directoryValueChanged(obj, ~, ~)
            obj.clearRegions();
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
set(directorySelector, ...
    "RowHeight", rowHeight, ...
    "ColumnWidth", {'7x', '1x', '2x', '2x'} ...
    );
end
function layoutRightsideElements(gui)
rowHeight = TrackingGui.rowHeight;
rgl = gui.getRightGridLayout();

kinociliumLocationGroup = gui.getKinociliumLocationElement();
scaleFactorElement = gui.getScaleFactorInputElement();
fpsInputElement = gui.getFpsInputElement();
trackingDropdown = gui.getTrackingSelectionElement();
saveFilestemElement = gui.getSaveFilestemElement();
trackButton = gui.getTrackButton();
saveImageButton = gui.getSaveImageButton();

trackingDropdown.Layout.Row = 1;
kinociliumLocationGroup.Layout.Row = 2;
scaleFactorElement.Layout.Row = 3;
fpsInputElement.Layout.Row = 4;
saveFilestemElement.Layout.Row = 5;
trackButton.Layout.Row = 6;
saveImageButton.Layout.Row = 7;

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

rgl.RowHeight = num2cell(rowHeight * ones(1, 7));
rgl.RowHeight{2} = KinociliumLocation.height;
end

function gl = generateGridLayout(size)
fig = uifigure;
fig.Name = "Hair-Bundle Tracking";
gl = uigridlayout(fig, size);
end

function rgl = generateRightGridLayout(gl)
rgl = uigridlayout(gl, [7, 1]);
rgl.Layout.Row = 2;
rgl.Layout.Column = 2;
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

%% Function to generate save image button
% Generates button allowing user to save displayed bundle image with
% selected regions
%
% Arguments
%
% * uigridlayout |gl|: layout to add button in
%
% Returns uibutton
function button = generateSaveImageButton(gl)
% Button to save displayed image of bundle
button = uibutton(gl);
button.Text = "Save Image";
end

%% Function to generate track button
% Generates button allowing user to starting tracking of selected regions
% on bundle image
%
% Arguments
%
% * uigridlayout |gl|: layout to add button in
%
% Returns uibutton
function button = generateTrackButton(gl)
% Button to start tracking selected regions on image
button = uibutton(gl);
button.Text = "Track";
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
% Generates edit fields (with labels) allowing user to set scaling (in
% nm/px) with error
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
lbl1.Text = "nm/px:"; % label for scaling
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

