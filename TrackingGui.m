classdef TrackingGui < handle
    properties (Constant)
        queueColor = "red";
        workingColor = "yellow";
        finishedColor = "green";
        rowHeight = 25;
    end

    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>

        % main window components
        figure; % uifigure containing GUI
        gridLayout; % uigridlayout containing GUI components
        leftGridLayout % uigridlayout for leftside column
        rightGridLayout % uigridlayout for rightside column

        % components to select and display bundle images
        regionPreviewer; % RegionPreviewer object
        directorySelector; % DirectorySelector object

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

            gl = obj.generateGridLayout([2, 2]);
            set(gl, ...
                "ColumnWidth", {'3x', '1x'}, ...
                "RowHeight", {TrackingGui.rowHeight, '1x'} ...
                );

            lgl = uigridlayout(gl, [2, 1]);
            rgl = uigridlayout(gl, [7, 1]);
            lgl.Layout.Row = 2;
            lgl.Layout.Column = 1;
            rgl.Layout.Row = 2;
            rgl.Layout.Column = 2;

            obj.gridLayout = gl;
            obj.leftGridLayout = lgl;
            obj.rightGridLayout = rgl;

            obj.generateSimpleElements(rgl);
            
            regionGui = RegionGui(lgl);
            imageGui = ImageGui(lgl, "EnableZoom", enableZoom);
            obj.regionPreviewer = RegionPreviewer(imageGui, regionGui);

            obj.generateDirectorySelector(gl, startingDirpath); % must come last
            layoutElements(obj);
        end
    end

    %% Functions to generate GUI elements
    methods (Access = private)
        function gl = generateGridLayout(obj, size)
            fig = uifigure;
            fig.Name = "Hair-Bundle Tracking";
            gl = uigridlayout(fig, size);
            obj.figure = fig;
        end
        function generateDirectorySelector(obj, gl, startingDirpath)
            obj.directorySelector = DirectorySelector( ...
                gl, ...
                "ValueChangedFcn", @obj.directoryValueChanged ...
                );
            obj.directorySelector.setDirectory(startingDirpath);
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
    methods (Access = private)
        function fig = getFigure(obj)
            fig = obj.figure;
        end
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function lgl = getLeftGridLayout(obj)
            lgl = obj.leftGridLayout;
        end
        function rgl = getRightGridLayout(obj)
            rgl = obj.rightGridLayout;
        end

        % complex class objects for visual components
        function previewer = getRegionPreviewer(obj)
            previewer = obj.regionPreviewer;
        end
        function gui = getImageGui(obj)
            regionPreviewer = obj.getRegionPreviewer();
            gui = regionPreviewer.getImageGui();
        end
        function gui = getRegionGui(obj)
            regionPreviewer = obj.getRegionPreviewer();
            gui = regionPreviewer.getRegionGui();
        end
        function elem = getImageElement(obj)
            imageGui = obj.getImageGui();
            elem = imageGui.getGridLayout();
        end
        function elem = getRegionElement(obj)
            regionGui = obj.getRegionGui();
            elem = regionGui.getGridLayout();
        end
        function elem = getDirectorySelectionElement(obj)
            elem = obj.directorySelector.getGridLayout();
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
        % ...bundle display
        function dirpath = getDirectoryPath(obj)
            elem = obj.directorySelector;
            dirpath = elem.getDirectoryPath();
        end
        function filepath = getFirstFilepath(obj)
            filepath = obj.directorySelector.getFirstFilepath();
        end
        function filepath = generateSaveFilepath(obj)
            directoryPath = obj.getDirectoryPath();
            filestem = obj.getSaveFilestem();
            filename = sprintf("%s%s.mat", filestem);
            filepath = fullfile(directoryPath, filename);
        end
        function count = getFilecount(obj)
            count = obj.directorySelector.getFilecount();
        end

        % ...for tracking
        function regions = getTrackingRegions(obj)
            imageGui = obj.getImageGui();
            regions = imageGui.getRegions();
        end
        function paths = getFilepaths(obj)
            paths = obj.directorySelector.getFilepaths();
        end
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
    
        function has = directoryHasImage(obj)
            count = obj.getFilecount();
            directory = obj.getDirectoryPath();
            has = count >= 1 && isfolder(directory);
            if ~has
                obj.throwAlertMessage("No valid images found!", "Choose Directory");
            end
        end
        function im = getImage(obj)
            if obj.directoryHasImage()
                filepath = obj.getFirstFilepath();
                im = imread(filepath);
            else
                im = [];
            end
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
            regions = obj.getTrackingRegions();
            count = numel(regions);
            exists = count >= 1;
            if ~exists
                obj.throwAlertMessage("No cells selected!", "Track");
            end
        end
        function trackAndSaveRegions(obj)
            regions = obj.getTrackingRegions();
            set(regions, "Color", obj.queueColor);
            results = obj.trackRegions(regions);
            obj.saveResults(results)
            obj.exportImageIfPossible();
        end
        function results = trackRegions(obj, regions)
            results = [];
            bundleCount = numel(regions);
            for index = bundleCount:-1:1
                region = regions(index);
                result = obj.trackAndTagRegion(region);
                results = [results, result];
            end
        end
        function result = trackAndTagRegion(obj, region)
            set(region, "Color", obj.workingColor); % color region as in-process
            result = obj.trackRegion(region);
            result = obj.appendMetadata(result, region);
            result = postprocessResults(result);
            set(region, "Color", obj.finishedColor); % color region as finished
        end
        function results = trackRegion(obj, region)
            preprocessor = Preprocessor.fromRegion(region);
            trackingMode = obj.getTrackingSelection();
            filepaths = obj.getFilepaths();
            results = TrackRegion( ...
                region, ...
                filepaths, ...
                trackingMode, ...
                preprocessor ...
                ); % preprocess and track
        end
        function result = appendMetadata(obj, result, region)  
            regionParser = RegionParser(region);
            result = regionParser.appendMetadata(result);

            result.DirectoryPath = obj.getDirectoryPath();
            result.TrackingMode = obj.getTrackingSelection();
            result.KinociliumLocation = obj.getKinociliumLocation();
            result.ScaleFactor = obj.getScaleFactor();
            result.ScaleFactorError = obj.getScaleFactorError();
            result.Fps = obj.getFps();
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
        function clearRegions(obj)
            imageGui = obj.getImageGui();
            imageGui.clearRegions();
        end
        function updateImageForDirectory(obj)
            im = obj.getImage();
            regionPreviewer = obj.getRegionPreviewer();
            regionPreviewer.changeFullImage(im);
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
layoutTopElements(gui);
layoutLeftsideElements(gui);
layoutRightsideElements(gui);
end
function layoutTopElements(gui)
rowHeight = TrackingGui.rowHeight;
directorySelector = gui.getDirectorySelectionElement();

directorySelector.Layout.Row = 1;
directorySelector.Layout.Column = [1, 2];
set(directorySelector, ...
    "RowHeight", rowHeight, ...
    "ColumnWidth", {'7x', '1x', '2x', '2x'} ...
    );
end
function layoutLeftsideElements(gui)
lgl = gui.getLeftGridLayout();

imageGui = gui.getImageElement();
regionGui = gui.getRegionElement();
imageGui.Layout.Row = 1;
regionGui.Layout.Row = 2;
set(lgl, "RowHeight", {'2x', '1x'})
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

%% Miscellaneous helper functions
% Postprocess raw XY traces, i.e. |results|
function results = postprocessResults(results)
postprocessor = Postprocessor(results);
postprocessor.process();
results = postprocessor.getPostprocessedResults();
end